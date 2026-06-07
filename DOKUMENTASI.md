# Dokumentasi Teknis — Leksika

## Daftar Isi

1. [Gambaran Arsitektur](#1-gambaran-arsitektur)
2. [Backend — Setup Laravel](#2-backend--setup-laravel)
3. [Docker — Konfigurasi & Cara Kerja](#3-docker--konfigurasi--cara-kerja)
4. [Nginx — Konfigurasi & Peran](#4-nginx--konfigurasi--peran)
5. [Deployment Backend](#5-deployment-backend)
6. [Frontend — Clean Architecture](#6-frontend--clean-architecture)
7. [Frontend — Struktur Kode](#7-frontend--struktur-kode)
8. [Frontend — Build & Release](#8-frontend--build--release)

---

## 1. Gambaran Arsitektur

```
┌─────────────────────────────────────┐
│         Flutter App (Android)        │
│  BLoC → UseCase → Repository → Dio  │
└────────────────┬────────────────────┘
                 │ HTTPS / HTTP
                 ▼
┌─────────────────────────────────────┐
│         Docker Container            │
│  ┌──────────┐    ┌───────────────┐  │
│  │  Nginx   │───▶│   PHP-FPM     │  │
│  │  :80     │    │   :9000       │  │
│  └──────────┘    └──────┬────────┘  │
│                         │           │
│                  ┌──────▼────────┐  │
│                  │  Laravel App  │  │
│                  └──────┬────────┘  │
└─────────────────────────┼──────────┘
                          │
          ┌───────────────┼───────────┐
          ▼               ▼           ▼
   ┌────────────┐  ┌──────────┐  ┌────────┐
   │  Supabase  │  │  Groq AI │  │Firebase│
   │ PostgreSQL │  │   API    │  │  FCM   │
   └────────────┘  └──────────┘  └────────┘
```

**Stack teknologi:**

| Komponen | Teknologi |
|----------|-----------|
| Mobile App | Flutter + BLoC |
| HTTP Client | Dio |
| Backend | Laravel 11 + PHP 8.4 |
| Web Server | Nginx |
| Process Manager | PHP-FPM |
| Database | PostgreSQL (Supabase) |
| AI Summarizer | Groq API |
| Push Notification | Firebase FCM |
| Containerisasi | Docker |

---

## 2. Backend — Setup Laravel

### Prasyarat

- PHP 8.4
- Composer
- PostgreSQL (atau akun Supabase)

### Instalasi manual (tanpa Docker)

```bash
cd backend

# Install dependency
composer install

# Salin file environment
cp .env.example .env

# Generate app key
php artisan key:generate

# Jalankan migrasi database
php artisan migrate

# Buat symlink storage (agar foto profil bisa diakses via URL)
php artisan storage:link

# Jalankan server
php artisan serve --host=0.0.0.0 --port=8000
```

### Konfigurasi `.env` penting

```env
APP_URL=http://localhost          # URL publik server (ganti saat production)

DB_CONNECTION=pgsql
DB_HOST=aws-1-ap-southeast-1.pooler.supabase.com
DB_PORT=5432
DB_DATABASE=postgres
DB_USERNAME=postgres.xxxxxxxx
DB_PASSWORD=xxxxxxxx
DB_SSLMODE=require

FILESYSTEM_DISK=local             # Penyimpanan file lokal
QUEUE_CONNECTION=database         # Queue menggunakan database

GROQ_API_KEY=gsk_xxxx             # API Key untuk AI summarizer
FIREBASE_PROJECT_ID=leksika-xxxx  # Firebase untuk push notification
```

### Penyimpanan file

| Jenis File | Disk | Lokasi di server | Akses |
|------------|------|-----------------|-------|
| Foto profil (avatar) | `public` | `storage/app/public/avatars/` | `{APP_URL}/storage/avatars/{file}` |
| PDF upload | `local` | Otomatis dihapus setelah teks diekstrak | Tidak publik |

### Limit upload

| Layer | Batas |
|-------|-------|
| Nginx (`client_max_body_size`) | 22 MB |
| PHP (`upload_max_filesize`) | 64 MB |
| Laravel — foto profil (`max:5120`) | 5 MB |
| Laravel — dokumen PDF (`max:20480`) | 20 MB |
| Flutter — validasi foto | 5 MB |

---

## 3. Docker — Konfigurasi & Cara Kerja

### Mengapa menggunakan Docker?

Docker memastikan environment server di production identik dengan environment development, menghilangkan masalah "works on my machine".

### Struktur file Docker

```
backend/
├── Dockerfile          ← definisi image
├── docker-compose.yml  ← orkestrasi container + volume
├── nginx.conf          ← konfigurasi web server
└── php.ini             ← konfigurasi PHP override
```

### Dockerfile

```dockerfile
FROM php:8.4-fpm
```

Menggunakan `php:8.4-fpm` karena:
- PHP-FPM (FastCGI Process Manager) memisahkan proses web server (Nginx) dari proses PHP
- Nginx menangani koneksi HTTP, PHP-FPM hanya aktif saat ada script PHP yang dieksekusi
- Lebih efisien untuk production dibanding `php:8.4-apache`

**Alur build image:**

```
1. Install dependency sistem (nginx, git, libpng, libpq, dll.)
2. Install PHP extensions (pdo_pgsql, mbstring, opcache, dll.)
3. Copy php.ini → /usr/local/etc/php/conf.d/laravel.ini
4. Install Composer
5. Install dependency Laravel (composer install)
6. Copy seluruh kode project
7. Copy nginx.conf
8. Set permission storage/
```

**CMD saat container start:**

```bash
php artisan migrate --force    # migrasi otomatis
php artisan config:cache       # cache konfigurasi
php artisan route:cache        # cache routing
php artisan view:cache         # cache blade views
php artisan storage:link       # symlink storage publik
php-fpm -D                     # jalankan PHP-FPM (background)
nginx -g "daemon off;"         # jalankan Nginx (foreground)
```

### docker-compose.yml

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:80"       # port host:port container
    env_file:
      - .env
    volumes:
      - ./storage/app/public:/var/www/storage/app/public   # foto profil (persisten)
      - ./storage/logs:/var/www/storage/logs               # Laravel logs
    restart: unless-stopped
```

**Penjelasan volume:**

| Volume | Tujuan |
|--------|--------|
| `./storage/app/public` | Foto profil tidak hilang saat container rebuild |
| `./storage/logs` | Log Laravel bisa dibaca dari host |

Tanpa volume, semua file di dalam container akan hilang saat `docker compose down` atau rebuild image.

### php.ini override

```ini
upload_max_filesize = 64M   # batas ukuran file yang bisa diupload
post_max_size = 64M         # batas total ukuran POST request
memory_limit = 256M         # batas memori per proses PHP
max_execution_time = 120    # batas waktu eksekusi script (detik)
```

File ini di-copy ke `/usr/local/etc/php/conf.d/laravel.ini` agar tidak menimpa seluruh konfigurasi default PHP, hanya meng-override nilai yang diperlukan.

---

## 4. Nginx — Konfigurasi & Peran

### Peran Nginx dalam arsitektur ini

```
Request HTTP masuk
       ↓
    [Nginx :80]
       ├── File statis (.jpg, .png, .css) → langsung dikirim ke client
       └── File .php → diteruskan ke [PHP-FPM :9000] via FastCGI
                              ↓
                       Laravel memproses
                              ↓
                       Response dikembalikan
```

Nginx **tidak bisa** menjalankan PHP secara langsung. Ia hanya meneruskan request ke PHP-FPM menggunakan protokol **FastCGI**.

### nginx.conf

```nginx
server {
    listen 80;
    root /var/www/public;       # root Laravel ada di folder public/
    index index.php;
    client_max_body_size 22M;   # batas ukuran request (harus >= limit Laravel)

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        # coba cari file statis dulu, jika tidak ada → lempar ke index.php
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;    # alamat PHP-FPM
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    }
}
```

### Mengapa `client_max_body_size` penting?

Nginx adalah lapisan pertama yang menerima request. Jika file yang diupload melebihi `client_max_body_size`, Nginx langsung menolak dengan error **413 Request Entity Too Large** sebelum request sampai ke PHP atau Laravel.

Nilai harus selalu sedikit **di atas** limit Laravel agar Laravel yang menentukan error, bukan Nginx.

---

## 5. Deployment Backend

### Perintah dasar

```bash
cd backend

# Build image dan jalankan container
docker compose up -d --build

# Cek status container
docker compose ps

# Lihat log real-time
docker compose logs -f

# Stop container
docker compose down
```

### Alur deployment lengkap

```
1. Pull kode terbaru
   git pull origin main

2. Pastikan .env sudah benar (APP_URL, DB, GROQ_API_KEY, dll.)

3. Build dan jalankan
   docker compose up -d --build

4. Migrasi otomatis dijalankan oleh CMD dalam Dockerfile
   (php artisan migrate --force)

5. Verifikasi
   docker compose logs app
   curl http://localhost:8000/api/health
```

### Update deployment (tanpa downtime)

```bash
# Pull kode baru
git pull origin main

# Rebuild dan restart
docker compose up -d --build

# Docker akan:
# - Build image baru
# - Stop container lama
# - Start container baru dengan image baru
# Volume (storage/app/public) tetap terjaga
```

### Troubleshooting

| Masalah | Perintah diagnosis |
|---------|-------------------|
| Container tidak start | `docker compose logs app` |
| Laravel error 500 | `docker compose exec app cat /var/www/storage/logs/laravel.log` |
| Permission error | `docker compose exec app chmod -R 775 /var/www/storage` |
| Migrasi gagal | `docker compose exec app php artisan migrate --force` |

---

## 6. Frontend — Clean Architecture

### Konsep dasar

Clean Architecture memisahkan kode menjadi lapisan-lapisan yang tidak bergantung satu sama lain ke arah luar. Aturannya: **lapisan dalam tidak boleh tahu tentang lapisan luar**.

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │  ← Widget, BLoC, State
│                                         │
│  ┌───────────────────────────────────┐  │
│  │          Domain Layer             │  │  ← UseCase, Entity, Repository (interface)
│  │                                   │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │        Data Layer           │  │  │  ← Model, DataSource, Repository (impl)
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Penjelasan tiap lapisan

**Data Layer** (paling luar, paling "kotor"):
- Berkomunikasi langsung dengan sumber data (API, database lokal)
- Berisi `Model` (class yang tahu cara parse JSON)
- Berisi `RemoteDataSource` (class yang panggil Dio/HTTP)
- Berisi implementasi `Repository`

**Domain Layer** (inti, paling "bersih"):
- Tidak tahu tentang Flutter, Dio, atau JSON
- Berisi `Entity` (object bisnis murni, plain Dart class)
- Berisi interface `Repository` (kontrak apa yang bisa dilakukan)
- Berisi `UseCase` (satu operasi bisnis, satu class)

**Presentation Layer** (paling luar dari sisi UI):
- Berisi Widget (tampilan)
- Berisi BLoC (state management)
- Tidak tahu tentang HTTP atau JSON, hanya memanggil UseCase

### Alur data: upload dokumen PDF

```
[User tekan tombol upload]
        ↓
[SummaryBloc] menerima event UploadDocument
        ↓
[UploadDocumentUsecase] dipanggil
        ↓
[SummaryRepository interface] dipanggil
        ↓
[SummaryRepositoryImpl] (implementasi nyata)
        ↓
[SummaryRemoteDataSource] kirim request via Dio
        ↓
[Laravel API] proses, return JSON
        ↓
[DocumentModel.fromJson()] parse JSON → DocumentModel
        ↓
[SummaryRepositoryImpl] konversi Model → Entity
        ↓
[Either<Failure, DocumentEntity>] dikembalikan ke BLoC
        ↓
[SummaryBloc] emit state baru
        ↓
[Widget] rebuild UI sesuai state
```

### Dependency Injection dengan GetIt

Semua dependency didaftarkan di `lib/core/di/injection_container.dart` menggunakan **GetIt**:

```dart
final GetIt sl = GetIt.instance;

// Urutan registrasi penting: dari bawah ke atas
sl.registerLazySingleton<DioClient>(() => DioClient(sl<SecureStorage>()));
sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

sl.registerLazySingleton<SummaryRemoteDataSource>(
  () => SummaryRemoteDataSourceImpl(sl<Dio>()),
);
sl.registerLazySingleton<SummaryRepository>(
  () => SummaryRepositoryImpl(sl<SummaryRemoteDataSource>()),
);
sl.registerLazySingleton<UploadDocumentUsecase>(
  () => UploadDocumentUsecase(sl<SummaryRepository>()),
);
sl.registerFactory<SummaryBloc>(
  () => SummaryBloc(uploadDocumentUsecase: sl<UploadDocumentUsecase>(), ...),
);
```

- `registerLazySingleton` → dibuat sekali, dipakai ulang (cocok untuk service, repository)
- `registerFactory` → dibuat baru setiap kali dipanggil (cocok untuk BLoC yang punya state)

---

## 7. Frontend — Struktur Kode

```
lib/
├── core/                          ← Shared infrastructure
│   ├── constants/
│   │   └── api_constants.dart     ← Base URL API dari --dart-define
│   ├── di/
│   │   └── injection_container.dart  ← Registrasi semua dependency (GetIt)
│   ├── errors/
│   │   ├── exceptions.dart        ← ServerException, UnauthorizedException, dll.
│   │   └── failures.dart          ← ServerFailure, NetworkFailure, dll.
│   ├── network/
│   │   └── dio_client.dart        ← Setup Dio (timeout, interceptor token)
│   ├── router/
│   │   └── app_router.dart        ← Daftar semua route navigasi
│   ├── services/
│   │   └── fcm_notification_service.dart  ← Registrasi token FCM ke backend
│   └── storage/
│       └── secure_storage.dart    ← Simpan/baca token dari FlutterSecureStorage
│
├── features/                      ← Fitur-fitur aplikasi
│   ├── auth/                      ← Autentikasi
│   │   ├── data/
│   │   │   ├── datasources/       ← Panggil API login/register/OTP
│   │   │   ├── models/            ← UserModel (parse JSON)
│   │   │   └── repositories/      ← AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          ← UserEntity (plain Dart)
│   │   │   ├── repositories/      ← AuthRepository (interface)
│   │   │   └── usecases/          ← LoginUsecase, RegisterUsecase, dll.
│   │   └── presentation/
│   │       ├── bloc/              ← AuthBloc, AuthEvent, AuthState
│   │       └── screens/           ← LoginScreen, RegisterScreen, OtpScreen, dll.
│   │
│   ├── summary/                   ← Fitur rangkuman & flashcard (fitur utama)
│   │   ├── data/
│   │   │   ├── datasources/       ← SummaryRemoteDataSource, NotificationRemoteDataSource
│   │   │   ├── models/            ← DocumentModel, FlashcardModel
│   │   │   └── repositories/      ← SummaryRepositoryImpl, NotificationRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          ← DocumentEntity, FlashcardEntity, NotificationEntity
│   │   │   ├── repositories/      ← SummaryRepository, NotificationRepository (interface)
│   │   │   └── usecases/          ← UploadDocumentUsecase, GetDocumentsUsecase,
│   │   │                             CreateFlashcardsUsecase, dll.
│   │   └── presentation/
│   │       ├── bloc/              ← SummaryBloc, NotificationBloc
│   │       ├── screens/           ← HomeScreen, DetailScreen, FlashcardPage,
│   │       │                         CreateRangkumanScreen, ProfileScreen, dll.
│   │       └── widgets/           ← Widget reusable khusus summary
│   │
│   └── profile/                   ← Profil pengguna
│       ├── data/
│       │   ├── datasources/       ← ProfileRemoteDataSource (get, update, upload foto)
│       │   ├── models/            ← ProfileModel
│       │   └── repositories/      ← ProfileRepositoryImpl
│       ├── domain/
│       │   ├── entities/          ← ProfileEntity
│       │   ├── repositories/      ← ProfileRepository (interface)
│       │   └── usecases/          ← GetProfileUsecase, UpdateProfileUsecase,
│       │                             UploadPhotoUsecase
│       └── presentation/
│           └── bloc/              ← ProfileBloc, ProfileEvent, ProfileState
│
└── shared/                        ← Widget & theme yang dipakai lintas fitur
    ├── theme/                     ← Warna, TextStyle, ThemeData
    └── widgets/                   ← LoadingWidget, PlaceholderScreen, dll.
```

### Contoh implementasi satu fitur: Upload Foto Profil

**1. Entity** (domain/entities/profile_entity.dart) — tidak tahu JSON:
```dart
class ProfileEntity {
  final String name;
  final String? avatarUrl;
  // ...
}
```

**2. Repository interface** (domain/repositories/profile_repository.dart):
```dart
abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> uploadPhoto(String filePath);
}
```

**3. UseCase** (domain/usecases/upload_photo_usecase.dart):
```dart
class UploadPhotoUsecase {
  final ProfileRepository repository;
  Future<Either<Failure, ProfileEntity>> call(String filePath) =>
      repository.uploadPhoto(filePath);
}
```

**4. Model** (data/models/profile_model.dart) — tahu JSON:
```dart
class ProfileModel extends ProfileEntity {
  factory ProfileModel.fromJson(Map<String, dynamic> json) { ... }
}
```

**5. DataSource** (data/datasources/profile_remote_datasource.dart) — panggil API:
```dart
Future<ProfileModel> uploadPhoto(String filePath) async {
  final formData = FormData.fromMap({
    'photo': await MultipartFile.fromFile(filePath),
  });
  final response = await dio.post('/profile/photo', data: formData);
  return ProfileModel.fromJson(response.data);
}
```

**6. Repository impl** (data/repositories/profile_repository_impl.dart):
```dart
Future<Either<Failure, ProfileEntity>> uploadPhoto(String filePath) async {
  try {
    final result = await remoteDataSource.uploadPhoto(filePath);
    return Right(result);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

**7. BLoC** (presentation/bloc/profile_bloc.dart):
```dart
Future<void> _onUploadPhoto(UploadPhoto event, Emitter emit) async {
  emit(ProfileSubmitting(_lastProfile!));
  final result = await uploadPhotoUsecase(event.filePath);
  result.fold(
    (failure) => emit(ProfileError(failure.message)),
    (profile)  => emit(ProfilePhotoUpdated(profile)),
  );
}
```

**8. Screen** (presentation/screens/edit_profile.dart) — hanya trigger event:
```dart
context.read<ProfileBloc>().add(UploadPhoto(_pickedImagePath!));
```

---

## 8. Frontend — Build & Release

### Prasyarat

- Flutter SDK `^3.10.7`
- Android SDK (untuk build Android)
- `google-services.json` di `frontend/android/app/`
- `assets/icon/icon.jpeg` tersedia

### Menjalankan untuk development

```bash
cd frontend

# Install dependency
flutter pub get

# Jalankan di device/emulator dengan API ke localhost
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api

# Jalankan ke HP fisik (ganti IP sesuai laptop)
flutter run --dart-define=API_BASE_URL=http://192.168.1.x:8000/api
```

### Build APK (Android)

```bash
cd frontend

# APK debug (untuk testing)
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://domain-production.com/api

# APK release (untuk distribusi)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://domain-production.com/api

# APK per-ABI (ukuran lebih kecil, satu file per arsitektur)
flutter build apk --split-per-abi --release \
  --dart-define=API_BASE_URL=https://domain-production.com/api
```

Output APK tersimpan di:
```
frontend/build/app/outputs/flutter-apk/
├── app-release.apk              ← semua arsitektur (universal)
├── app-arm64-v8a-release.apk   ← HP modern 64-bit
├── app-armeabi-v7a-release.apk ← HP lama 32-bit
└── app-x86_64-release.apk      ← emulator
```

### Build App Bundle (untuk Google Play Store)

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://domain-production.com/api
```

Output: `frontend/build/app/outputs/bundle/release/app-release.aab`

### Generate launcher icon

Icon dikonfigurasi di `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/icon.jpeg"
```

Jalankan:
```bash
dart run flutter_launcher_icons
```

### Checklist sebelum build release

- [ ] `API_BASE_URL` mengarah ke server production (bukan localhost)
- [ ] `google-services.json` adalah file production (bukan development)
- [ ] `backend/.env` `APP_URL` sudah diisi dengan domain production
- [ ] Docker container backend sudah berjalan di server
- [ ] Migrasi database sudah dijalankan (`php artisan migrate --force`)
- [ ] `storage:link` sudah dibuat (`php artisan storage:link`)
- [ ] Volume Docker `storage/app/public` sudah di-mount

### Variabel `API_BASE_URL`

URL API di-inject saat build menggunakan `--dart-define`, bukan hardcode di kode. Dibaca di `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
```

Ini memungkinkan satu codebase yang sama di-build untuk berbagai environment (development, staging, production) hanya dengan mengganti nilai `--dart-define`.
