# app_ohia

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# OHIA - Location Sharing Marketplace

## Fase 1: Auth & Registrasi

### Arsitektur Project

```
ohia-project/
├── laravel-api/                    # Backend API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/Api/
│   │   │   │   └── AuthController.php      # Register, OTP, Login, KYC, Switch Role
│   │   │   └── Requests/Auth/
│   │   │       ├── RegisterRequest.php      # Validasi registrasi
│   │   │       ├── VerifyOtpRequest.php     # Validasi OTP
│   │   │       └── VerifikasiAkhirRequest.php # Validasi upload KTP
│   │   ├── Models/
│   │   │   └── User.php                     # Model user lengkap
│   │   ├── Services/
│   │   │   └── OtpService.php               # Generate, verify, kirim OTP
│   │   └── Traits/
│   │       └── ApiResponse.php              # Helper response JSON
│   ├── database/migrations/
│   │   └── 2026_03_07_000001_create_users_table.php
│   └── routes/
│       └── api.php                          # Semua API routes
│
└── flutter-app/                    # Mobile App
    ├── pubspec.yaml                         # Dependencies
    └── lib/
        ├── core/
        │   ├── theme/
        │   │   └── app_theme.dart           # Colors, Typography, Theme
        │   └── network/
        │       └── api_client.dart          # Dio client + interceptor
        └── features/
            └── auth/
                ├── data/
                │   └── auth_repository.dart # API calls auth
                └── presentation/screens/
                    ├── login_screen.dart         # Login
                    ├── register_step1_screen.dart # Data Pribadi
                    ├── register_step2_screen.dart # Kontak & OTP
                    └── register_step3_screen.dart # Verifikasi Akhir (KYC)
```

---

## API Endpoints

| Method | Endpoint                    | Auth | Deskripsi                    |
|--------|-----------------------------|------|------------------------------|
| POST   | `/api/auth/register`        | -    | Registrasi + kirim OTP       |
| POST   | `/api/auth/otp/send`        | -    | Kirim ulang OTP              |
| POST   | `/api/auth/otp/verify`      | -    | Verifikasi OTP → dapat token |
| POST   | `/api/auth/login`           | -    | Login (HP/email + password)  |
| POST   | `/api/auth/verifikasi-akhir`| Yes  | Upload selfie+KTP            |
| POST   | `/api/auth/logout`          | Yes  | Logout (revoke token)        |
| GET    | `/api/auth/me`              | Yes  | Get profile                  |
| PATCH  | `/api/auth/switch-role`     | Yes  | Switch Pencari ↔ Pembagi     |

---

## Setup Laravel

```bash
# 1. Buat project Laravel baru
composer create-project laravel/laravel ohia-api
cd ohia-api

# 2. Install Sanctum (sudah include di Laravel 11+)
# Jika Laravel 10:
# composer require laravel/sanctum
# php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# 3. Copy file-file dari laravel-api/ ke project:
#    - app/Models/User.php
#    - app/Http/Controllers/Api/AuthController.php
#    - app/Http/Requests/Auth/*.php
#    - app/Services/OtpService.php
#    - app/Traits/ApiResponse.php
#    - database/migrations/*
#    - routes/api.php

# 4. Setup .env
DB_CONNECTION=pgsql       # atau mysql
DB_DATABASE=ohia_db
DB_USERNAME=postgres
DB_PASSWORD=secret

# 5. Migrate
php artisan migrate

# 6. Setup storage link (untuk foto KTP)
php artisan storage:link

# 7. Jalankan
php artisan serve
```

---

## Setup Flutter

```bash
# 1. Buat project Flutter baru
flutter create ohia_app
cd ohia_app

# 2. Replace pubspec.yaml dengan yang disediakan

# 3. Copy folder lib/ dari flutter-app/ ke project

# 4. Buat folder assets
mkdir -p assets/{images,icons,fonts}

# 5. Download font Poppins dari Google Fonts ke assets/fonts/

# 6. Install dependencies
flutter pub get

# 7. Jalankan
flutter run
```

---

## Flow Registrasi (sesuai PPT slide 3-7)

```
┌──────────────────┐
│  Slide 3          │
│  Step 1: Data     │──→ Nama, NIK, No KK, Kota Lahir,
│  Pribadi          │    Tanggal Lahir, Alamat
└────────┬─────────┘
         │
┌────────▼─────────┐
│  Slide 4          │
│  Step 2: Kontak   │──→ No HP, Email, Password
│  & OTP            │    Kirim OTP → Input OTP → Verify
└────────┬─────────┘
         │
┌────────▼─────────┐
│  Slide 5-6        │
│  Step 3: Verifi-  │──→ Foto selfie + KTP
│  kasi Akhir       │    Upload → Submit → Waiting approval
└────────┬─────────┘
         │
┌────────▼─────────┐
│  Slide 7          │
│  Sukses!          │──→ Bisa gunakan app dengan fitur terbatas
│  Buka Aplikasi    │    sambil tunggu verifikasi admin
└──────────────────┘
```

---

## Catatan Penting

### SMS Gateway (OTP)
File `OtpService.php` sudah disiapkan placeholder untuk integrasi:
- **Zenziva** (provider lokal Indonesia, murah)
- **Twilio** (international, lebih mahal)
- **Firebase Auth** (gratis tapi terbatas)

### File Storage (Foto KTP)
Saat ini menggunakan local storage Laravel (`storage/app/public`).
Untuk production, ganti ke:
- **S3** atau **DigitalOcean Spaces**
- Config di `config/filesystems.php`

### Security
- OTP di-hash (bcrypt) sebelum disimpan ke DB
- Token menggunakan Laravel Sanctum
- Password di-hash otomatis via Eloquent cast
- Foto KTP disimpan di path private per user

---

## Fase Selanjutnya

- **Fase 4**: Profil Pembagi Setup (form untuk user isi profil Pembagi)
- **Fase 5**: Komunikasi (Chat, VoIP)
- **Fase 6**: Fitur Darurat + Find My Device
