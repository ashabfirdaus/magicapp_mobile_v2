# RINGKASAN IMPLEMENTASI LOGIN SYSTEM MAGIC LAUNDRY

## Tanggal Update
26 Mei 2026

## Perubahan yang Dilakukan

### 1. Konfigurasi API (lib/config/)
✅ **api_config.dart** - Konfigurasi environment-based API
   - Domain API: `https://app.magiclaundry.biz.id/api`
   - Support 3 environment: Development, Staging, Production
   - Endpoint yang tersedia:
     - `/auth/check-account` - Cek keberadaan akun
     - `/auth/login` - Login dengan password
     - `/auth/send-otp-input` - Kirim OTP via WhatsApp
     - `/auth/verify-otp` - Verifikasi kode OTP
     - Plus endpoint auth lainnya

✅ **app_constants.dart** - Konstanta aplikasi
   - App info, storage keys, validation rules
   - Error dan success messages dalam bahasa Indonesia

✅ **app_config.dart** - Konfigurasi sederhana (legacy)

✅ **index.dart** - Barrel file untuk kemudahan import

### 2. Authentication Service (lib/services/)
✅ **auth_service.dart** - Service untuk handle API calls
   - Class `CheckAccountResponse` - Parse response check account
   - Class `LoginResponse` - Parse response login
   - Class `SendOtpResponse` - Parse response send OTP
   - Method `checkAccount()` - Cek akun
   - Method `login()` - Login dengan password
   - Method `sendOtp()` - Kirim OTP
   - Method `verifyOtp()` - Verifikasi OTP
   - Singleton pattern untuk AuthService

### 3. Halaman Login (lib/pages/)
✅ **login_page.dart** - Update dengan flow kompleks
   - 2 opsi login: Username/Email atau Nomor Telepon
   - Validasi akun terlebih dahulu
   - Display informasi akun yang sudah diverifikasi
   - Input password setelah akun diverifikasi
   - Opsi login dengan OTP via WhatsApp
   - Dialog untuk input dan verifikasi kode OTP
   - Error handling dan snackbar notifications
   - Loading indicators untuk setiap action

### 4. Main Setup (lib/main.dart)
✅ Update main.dart
   - Import config modules
   - Inisialisasi API environment ke Production
   - Print konfigurasi untuk debug

### 5. Dependencies (pubspec.yaml)
✅ Tambah http package v1.1.0 untuk API calls

### 6. Dokumentasi
✅ **DOKUMENTASI_LOGIN.md** - Dokumentasi lengkap sistem login
   - Ringkasan fitur
   - Flow login step-by-step
   - Endpoint API documentation
   - Contoh penggunaan
   - Troubleshooting

## State Flow Login

```
Start
  ↓
[Pilih Metode Login: Email/Username atau Phone]
  ↓
[Input Username/Email/Phone]
  ↓
[Click "Lanjutkan"]
  ↓
API: POST /auth/check-account
  ↓
Is Account Found? 
  ├─ NO → Show Error + Reset
  └─ YES & islogin = true
       ↓
       [Display Account Info]
       ↓
       [Input Password]
       ↓
       Choose Path:
       ├─ Click "Masuk" → Login with Password
       │  └─ API: POST /auth/login → Success/Error
       │
       └─ Click "Login dengan OTP WhatsApp"
          └─ API: POST /auth/send-otp-input
             ↓
             [Dialog: Input OTP]
             ↓
             API: POST /auth/verify-otp → Success/Error
```

## API Endpoints yang Digunakan

### 1. Check Account
```
POST https://app.magiclaundry.biz.id/api/auth/check-account
Content-Type: application/json

Request:
{
  "username": "email@example.com atau +62812345678"
}

Response Success:
{
  "success": true,
  "username": "...",
  "email": "...",
  "phone": "...",
  "isemail": true/false,
  "islogin": true/false,
  "message": "..."
}
```

### 2. Login with Password
```
POST https://app.magiclaundry.biz.id/api/auth/login
Content-Type: application/json

Request:
{
  "username": "email@example.com atau +62812345678",
  "password": "password123",
  "isemail": true/false
}

Response Success:
{
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

### 3. Send OTP
```
POST https://app.magiclaundry.biz.id/api/auth/send-otp-input
Content-Type: application/json

Request:
{
  "input": "email@example.com atau +62812345678",
  "type": "email" atau "phone",
  "isemail": true/false (optional)
}

Response Success:
{
  "success": true,
  "message": "...",
  "reference": "reference_code"
}
```

### 4. Verify OTP
```
POST https://app.magiclaundry.biz.id/api/auth/verify-otp
Content-Type: application/json

Request:
{
  "reference": "reference_code",
  "otp": "123456"
}

Response Success:
{
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

## Fitur Utama

✅ **Multi-channel Login**
   - Username/Email login
   - Nomor telepon login
   - OTP via WhatsApp

✅ **Account Verification**
   - Check akun sebelum input password
   - Display info akun yang sudah diverifikasi

✅ **Error Handling**
   - User-friendly error messages
   - Toast notifications untuk feedback
   - Retry mechanism

✅ **Loading States**
   - Visual feedback saat loading
   - Disable buttons saat processing
   - Progressive indicators

✅ **Responsive Design**
   - Support berbagai ukuran layar
   - Modern UI dengan Material Design 3
   - Color scheme: Deep Purple (primary)

## File Structure
```
lib/
├── main.dart
├── config/
│   ├── api_config.dart
│   ├── app_config.dart
│   ├── app_constants.dart
│   ├── index.dart
│   └── USAGE_EXAMPLE.dart
├── services/
│   └── auth_service.dart
├── pages/
│   └── login_page.dart
└── DOKUMENTASI_LOGIN.md
```

## Testing Checklist

### Unit Tests Needed
- [ ] AuthService.checkAccount() - success case
- [ ] AuthService.checkAccount() - error case
- [ ] AuthService.login() - success case
- [ ] AuthService.login() - error case
- [ ] AuthService.sendOtp() - success case
- [ ] AuthService.sendOtp() - error case
- [ ] AuthService.verifyOtp() - success case
- [ ] AuthService.verifyOtp() - error case

### Widget Tests Needed
- [ ] LoginPage initial state
- [ ] Toggle between email/phone input
- [ ] Check account validation
- [ ] Password input after account verified
- [ ] OTP dialog functionality
- [ ] Error snackbar display
- [ ] Reset form functionality

### Manual Testing Checklist
- [ ] Input username/email validation
- [ ] Input phone number validation
- [ ] API call check account (success)
- [ ] API call check account (account not found)
- [ ] Login with password flow
- [ ] Login with OTP flow
- [ ] Back button functionality
- [ ] Sign up navigation
- [ ] Network timeout handling
- [ ] All error messages display correctly

## Next Steps (TODO)

### High Priority
1. [ ] Implementasi penyimpanan token ke secure storage (flutter_secure_storage)
2. [ ] Navigasi ke home page setelah login sukses
3. [ ] Implementasi logout functionality
4. [ ] Implementasi refresh token mechanism
5. [ ] Create HTTP interceptor untuk attach token di request

### Medium Priority
1. [ ] Create halaman registrasi
2. [ ] Create halaman lupa password
3. [ ] Implementasi remember me checkbox
4. [ ] Implementasi biometric login (fingerprint, face)
5. [ ] Add unit dan widget tests

### Low Priority
1. [ ] Implementasi analitik untuk login events
2. [ ] Create halaman tambah/ganti nomor telepon
3. [ ] Support social login (Google, Facebook, WhatsApp)
4. [ ] Implementasi rate limiting protection
5. [ ] Enhanced security measures (CSRF token, request signing)

## Dependencies Added
- **http: ^1.1.0** - HTTP client untuk API calls

## Optional Dependencies untuk Future
- **flutter_secure_storage: ^9.0.0** - Secure token storage
- **shared_preferences: ^2.2.0** - Local preferences
- **jwt_decoder: ^2.0.0** - JWT token parsing
- **get_it: ^7.6.0** - Service locator
- **provider: ^6.0.0** - State management

## Catatan Penting

1. **Token Management**
   - Saat ini token hanya disimpan di memory
   - Diperlukan implementasi secure storage untuk production

2. **Error Handling**
   - Semua error diberikan message yang user-friendly
   - Server-side error messages ditampilkan ke user

3. **Security**
   - Pastikan backend validasi semua input
   - Implementasi rate limiting pada API
   - Use HTTPS untuk semua API calls

4. **API Configuration**
   - Saat ini environment di-set ke Production
   - Untuk development, ubah di main.dart ke Environment.development

5. **Testing**
   - Gunakan mock server atau stub untuk testing
   - Test dengan berbagai skenario edge case

## Contact & Support
Untuk update atau pertanyaan lebih lanjut, hubungi tim development.
