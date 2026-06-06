# Panduan Menjalankan Project Leksika

Panduan ini dipakai setiap anggota tim agar backend Laravel dan frontend Flutter bisa saling terhubung di laptop masing-masing.

## 1. Persiapan Backend Laravel

Masuk ke folder backend:

```bash
cd backend
```

Install dependency Laravel:

```bash
composer install
```

Copy atau gunakan file `.env` yang sudah dibagikan di grup. Pastikan file tersebut berada di:

```txt
backend/.env
```

Jika belum ada `APP_KEY`, jalankan:

```bash
php artisan key:generate
```

Setelah `.env` sudah benar, jalankan:

```bash
php artisan config:clear
php artisan migrate
```

## 2. Setup Firebase Backend

File `firebase-service-account.json` yang dibagikan di grup dipakai oleh backend untuk mengirim notifikasi FCM.

Letakkan file tersebut di:

```txt
backend/storage/app/firebase-service-account.json
```

Lalu pastikan bagian Firebase di `backend/.env` terisi seperti ini:

```env
FIREBASE_PROJECT_ID=leksika-dff74
FIREBASE_CREDENTIALS=C:\Users\NAMA_USER\PENS\Semester-4\leksika\backend\storage\app\firebase-service-account.json
FIREBASE_CREDENTIALS_JSON=
```

Sesuaikan path `FIREBASE_CREDENTIALS` dengan lokasi project di laptop masing-masing.

Setelah mengubah `.env`, jalankan:

```bash
php artisan config:clear
```

## 3. Menjalankan Backend

Jalankan server Laravel agar bisa diakses dari HP:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Untuk fitur reminder flashcard terjadwal, buka terminal backend kedua lalu jalankan:

```bash
php artisan queue:work
```

Jadi minimal ada dua terminal backend:

Terminal 1:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Terminal 2:

```bash
php artisan queue:work
```

## 4. Cek IP Laptop

Karena Flutter dijalankan di HP fisik, API base URL harus memakai IP laptop masing-masing.

Di Windows, jalankan:

```bash
ipconfig
```

Cari bagian Wi-Fi yang sedang dipakai, lalu ambil nilai:

```txt
IPv4 Address
```

Contoh:

```txt
IPv4 Address . . . . . . . . . . . : 192.168.0.115
```

Berarti API base URL-nya:

```txt
http://192.168.0.115:8000/api
```

Pastikan HP dan laptop berada di jaringan Wi-Fi yang sama.

## 5. Persiapan Frontend Flutter

Masuk ke folder frontend:

```bash
cd frontend
```

Install dependency Flutter:

```bash
flutter pub get
```

File `google-services.json` yang dibagikan di grup dipakai oleh frontend Android untuk Firebase.

Letakkan file tersebut di:

```txt
frontend/android/app/google-services.json
```

## 6. Menjalankan Frontend

Jalankan Flutter dengan `API_BASE_URL` sesuai IP laptop masing-masing.

Contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.115:8000/api
```

Jika IP laptop berbeda, ganti `192.168.0.115` dengan IPv4 dari hasil `ipconfig`.

Contoh lain:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000/api
```

## 7. Urutan Menjalankan Project

1. Jalankan backend:

```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```

2. Jalankan queue worker backend:

```bash
cd backend
php artisan queue:work
```

3. Cek IP laptop:

```bash
ipconfig
```

4. Jalankan Flutter:

```bash
cd frontend
flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP:8000/api
```

Ganti `IP_LAPTOP` dengan IPv4 masing-masing.

## 8. Catatan Penting

- Jangan commit file rahasia berikut:
  - `backend/.env`
  - `backend/storage/app/firebase-service-account.json`
  - `frontend/android/app/google-services.json`
- Jika `.env` diubah, jalankan:

```bash
php artisan config:clear
```

- Jika HP tidak bisa terhubung ke backend, cek:
  - HP dan laptop sudah satu Wi-Fi.
  - Laravel dijalankan dengan `--host=0.0.0.0`.
  - IP di `API_BASE_URL` sesuai hasil `ipconfig`.
  - Firewall Windows tidak memblokir port `8000`.
- Untuk Android emulator, API base URL biasanya:

```txt
http://10.0.2.2:8000/api
```

Tetapi untuk HP fisik, tetap gunakan IPv4 laptop.
