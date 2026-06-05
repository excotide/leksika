# Leksika API Documentation

**Base URL:** `http://<host>:8000/api`  
**Auth:** Laravel Sanctum (Bearer Token)  
**Format:** `application/json`

---

## Authentication

### Register
```
POST /register
```
**Body:**
| Field | Type | Rules |
|---|---|---|
| `name` | string | required |
| `email` | string | required, email |
| `password` | string | required, min 8 |
| `password_confirmation` | string | required, same as password |

**Response:**
```json
{
  "status": true,
  "message": "Register berhasil",
  "token": "1|abc123...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "email_verified_at": null
  }
}
```

---

### Login
```
POST /login
```
**Body:**
| Field | Type | Rules |
|---|---|---|
| `email` | string | required, email |
| `password` | string | required |

**Response:**
```json
{
  "status": true,
  "message": "Login berhasil",
  "token": "1|abc123...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "email_verified_at": null
  }
}
```

> ⚠️ Jika email belum diverifikasi, response `403 Forbidden`

---

## Email Verification (Bearer Token, belum perlu verified)

### Verify OTP
```
POST /email/verify-otp
```
**Header:** `Authorization: Bearer <token>`

**Body:**
| Field | Type | Rules |
|---|---|---|
| `otp` | string | required, 6 digit |

**Response:**
```json
{
  "status": true,
  "message": "Email berhasil diverifikasi"
}
```

---

### Resend OTP
```
POST /email/resend-otp
```
**Header:** `Authorization: Bearer <token>`

**Body:** *(tidak wajib)*

**Response:**
```json
{
  "status": true,
  "message": "OTP berhasil dikirim ulang"
}
```

---

## Protected Endpoints (Bearer Token + Email Verified)

### Logout
```
POST /logout
```
**Header:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": true,
  "message": "Logout berhasil"
}
```

---

### Get Current User
```
GET /user
```
**Header:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": true,
  "message": "OK",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "email_verified_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### Get All Documents
```
GET /documents
```
**Header:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": true,
  "message": "OK",
  "data": [
    {
      "id": 1,
      "filename": "materi.pdf",
      "summary": "Isi rangkuman...",
      "quiz_count": 5,
      "created_at": "2024-01-01T00:00:00.000000Z"
    }
  ]
}
```

---

### Get Document by ID
```
GET /documents/{id}
```
**Header:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": true,
  "message": "OK",
  "data": {
    "id": 1,
    "filename": "materi.pdf",
    "summary": "Isi rangkuman...",
    "quiz_count": 5,
    "created_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### Upload Document
```
POST /documents
```
**Header:** `Authorization: Bearer <token>`  
**Content-Type:** `multipart/form-data`

**Body:**
| Field | Type | Rules |
|---|---|---|
| `file` | file | required, pdf/txt/docx, max 20MB |
| `length` | string | optional, default `"Sedang (5-7 Paragraf)"` |
| `make_quiz` | string | optional, `"true"` / `"false"` |
| `quiz_count` | string | optional, default `"5 Soal"` |

**Response:**
```json
{
  "status": true,
  "message": "Dokumen berhasil diproses",
  "document": {
    "id": 1,
    "filename": "materi.pdf",
    "created_at": "2024-01-01T00:00:00.000000Z"
  },
  "summary": "Isi rangkuman..."
}
```

---

## Profile (Bearer Token + Email Verified)

### Get Profile
```
GET /profile
```
**Header:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "status": true,
  "message": "Profil berhasil diambil.",
  "data": {
    "name": "John Doe",
    "email": "john@example.com",
    "bio": "Mahasiswa Teknik Informatika",
    "institution": "Politeknik Elektronika Negeri Surabaya",
    "address": "Karanggeneng, Lamongan",
    "avatar_url": "http://<host>:8000/storage/avatars/abc123.jpg",
    "total_summary": 10,
    "total_streak": 7
  }
}
```

> `avatar_url` bernilai `null` jika user belum upload foto profil.

---

### Update Profile
```
PUT /profile
```
**Header:** `Authorization: Bearer <token>`

**Body:**
| Field | Type | Rules |
|---|---|---|
| `name` | string | optional, max 255 |
| `bio` | string | optional, max 1000 |
| `institution` | string | optional, max 255 |
| `address` | string | optional, max 255 |

> Field `email` tidak dapat diubah lewat endpoint ini.

**Response:**
```json
{
  "status": true,
  "message": "Profil berhasil diperbarui.",
  "data": {
    "name": "John Doe",
    "email": "john@example.com",
    "bio": "Mahasiswa Teknik Informatika",
    "institution": "Politeknik Elektronika Negeri Surabaya",
    "address": "Karanggeneng, Lamongan",
    "avatar_url": null
  }
}
```

---

### Upload Profile Photo
```
POST /profile/photo
```
**Header:** `Authorization: Bearer <token>`  
**Content-Type:** `multipart/form-data`

**Body:**
| Field | Type | Rules |
|---|---|---|
| `photo` | file | required, jpeg/jpg/png, max 5MB |

**Response:**
```json
{
  "status": true,
  "message": "Foto profil berhasil diperbarui.",
  "data": {
    "name": "John Doe",
    "email": "john@example.com",
    "bio": "Mahasiswa Teknik Informatika",
    "institution": "Politeknik Elektronika Negeri Surabaya",
    "address": "Karanggeneng, Lamongan",
    "avatar_url": "http://<host>:8000/storage/avatars/abc123.jpg"
  }
}
```

---

## HTTP Status Codes

| Code | Keterangan |
|---|---|
| `200` | OK |
| `201` | Created |
| `401` | Unauthorized — token tidak valid / tidak ada |
| `403` | Forbidden — email belum diverifikasi |
| `422` | Unprocessable — validasi gagal |
| `500` | Server error |

---

## Catatan

- Semua request butuh header `Accept: application/json`
- Token didapat dari response `register` atau `login`, simpan di secure storage
- OTP dikirim ke email saat register, berlaku sekali pakai