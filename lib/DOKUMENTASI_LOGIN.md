# Dokumentasi Magic Laundry Login System

## Ringkasan Fitur
Halaman login MagicApp telah diupdate dengan sistem login yang canggih yang mendukung:
1. Login dengan Username/Email atau Nomor Telepon
2. Verifikasi akun sebelum memasukkan password
3. Login dengan Password
4. Login dengan OTP via WhatsApp

## Struktur File

### Config Files
- **lib/config/api_config.dart** - Konfigurasi API dengan environment-based settings
- **lib/config/app_constants.dart** - Konstanta aplikasi
- **lib/config/app_config.dart** - Konfigurasi sederhana (legacy)
- **lib/config/index.dart** - Barrel file untuk export semua config

### Services
- **lib/services/auth_service.dart** - Service untuk handle semua API calls authentication

### Pages
- **lib/pages/login_page.dart** - Halaman login dengan flow yang kompleks

## Flow Login

### 1. Pilih Metode Login
User dapat memilih antara:
- **Username/Email** - Login menggunakan username atau email
- **Nomor Telepon** - Login menggunakan nomor telepon

### 2. Check Account
Sebelum user memasukkan password, sistem akan mengecek apakah akun ada di database melalui endpoint:
```
POST /api/auth/check-account
Body: {
  "username": "email@example.com atau +62812345678"
}

Response: {
  "success": true,
  "username": "...",
  "email": "...",
  "phone": "...",
  "isemail": true/false,  // true jika input adalah email
  "islogin": true/false,  // true jika akun ada
  "message": "..."
}
```

### 3A. Login dengan Password
Jika `islogin = true`, tampilkan input password dan tombol login:
```
POST /api/auth/login
Body: {
  "username": "email@example.com atau +62812345678",
  "password": "password123",
  "isemail": true/false
}

Response: {
  "success": true,
  "token": "jwt_token",
  "refresh_token": "refresh_token",
  "user_id": "...",
  "email": "...",
  "phone": "...",
  "name": "...",
  "message": "..."
}
```

### 3B. Login dengan OTP WhatsApp
User dapat klik tombol "Login dengan Kode OTP WhatsApp":
```
POST /api/auth/send-otp-input
Body: {
  "input": "email@example.com atau +62812345678",
  "type": "email" atau "phone",
  "isemail": true/false
}

Response: {
  "success": true,
  "message": "...",
  "reference": "reference_code"
}
```

Setelah mendapat referensi, user akan diminta untuk memasukkan kode OTP:
```
POST /api/auth/verify-otp
Body: {
  "reference": "reference_code",
  "otp": "123456"
}

Response: {
  "success": true,
  "token": "jwt_token",
  "refresh_token": "refresh_token",
  "user_id": "...",
  "email": "...",
  "phone": "...",
  "name": "...",
  "message": "..."
}
```

## API Configuration

### Environment Settings
Environment dapat diubah di `main.dart`:
```dart
// Development
ApiConfig.setEnvironment(Environment.development);
// http://localhost:3000

// Staging
ApiConfig.setEnvironment(Environment.staging);
// https://staging-api.magiclaundry.biz.id/api

// Production
ApiConfig.setEnvironment(Environment.production);
// https://app.magiclaundry.biz.id/api
```

### Base URLs
```dart
// Gunakan helper methods dari ApiConfig
ApiConfig.checkAccountUrl    // https://app.magiclaundry.biz.id/api/auth/check-account
ApiConfig.loginUrl           // https://app.magiclaundry.biz.id/api/auth/login
ApiConfig.sendOtpUrl         // https://app.magiclaundry.biz.id/api/auth/send-otp-input
ApiConfig.verifyOtpUrl       // https://app.magiclaundry.biz.id/api/auth/verify-otp
```

## Penggunaan

### Di Halaman Lain
```dart
import 'package:magicapp_mobile_v2/services/auth_service.dart';

final authService = AuthService();

// Check account
final response = await authService.checkAccount('email@example.com');

// Login
final loginResponse = await authService.login(
  username: 'email@example.com',
  password: 'password123',
  isEmail: true,
);

// Send OTP
final otpResponse = await authService.sendOtp(
  input: 'email@example.com',
  type: 'email',
  isEmail: true,
);

// Verify OTP
final verifyResponse = await authService.verifyOtp(
  reference: 'ref123',
  otp: '123456',
);
```

### Akses Konstanta
```dart
import 'package:magicapp_mobile_v2/config/index.dart';

AppConstants.appName                    // "MagicApp"
AppConstants.minPasswordLength          // 6
AppConstants.loginSuccessMessage        // "Login berhasil!"
```

## State Management di LoginPage

### State Variables
- `_usePhoneNumber` - Toggle antara phone/email login
- `_accountChecked` - Apakah sudah cek akun
- `_accountExists` - Apakah akun ada di database
- `_isEmailLogin` - Apakah input adalah email
- `_isLoading` - Loading state untuk login
- `_otpLoading` - Loading state untuk OTP
- `_otpReference` - Reference dari server untuk verifikasi OTP

### Methods
- `_checkAccount()` - Cek apakah akun ada
- `_handleLogin()` - Proses login dengan password
- `_sendOtp()` - Kirim OTP ke WhatsApp
- `_showOtpDialog()` - Dialog untuk verifikasi OTP
- `_resetForm()` - Reset form ke state awal

## Error Handling
Semua error akan ditampilkan sebagai snackbar dengan warna merah:
- "Masukkan username, email, atau nomor telepon"
- "Akun tidak ditemukan. Silakan daftar terlebih dahulu."
- "Masukkan password"
- "Login gagal"
- "Gagal mengirim OTP"
- "Verifikasi OTP gagal"

## Next Steps (TODO)
1. Implementasi navigation ke halaman home setelah login sukses
2. Implementasi penyimpanan token ke secure storage
3. Implementasi refresh token mechanism
4. Implementasi halaman registrasi
5. Implementasi halaman lupa password
6. Implementasi halaman OTP verification dengan UI yang lebih baik

## Debugging
Untuk melihat konfigurasi API saat startup, check console:
```
=== API Configuration ===
Environment: Environment.production
API Domain: https://app.magiclaundry.biz.id/api
Connect Timeout: 30000 ms
Receive Timeout: 30000 ms
======================
```
