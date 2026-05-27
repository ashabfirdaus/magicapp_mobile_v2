## 📁 PROJECT STRUCTURE - MAGIC LAUNDRY APP

```
magicapp_mobile_v2/
├── android/                          # Android native code
├── ios/                              # iOS native code
├── lib/
│   ├── main.dart                     # Entry point aplikasi
│   │
│   ├── config/                       # 📋 Konfigurasi Aplikasi
│   │   ├── api_config.dart           # API configuration dengan environment settings
│   │   ├── app_config.dart           # Simple app configuration
│   │   ├── app_constants.dart        # Konstanta aplikasi global
│   │   ├── index.dart                # Barrel file - export semua config
│   │   └── USAGE_EXAMPLE.dart        # Contoh penggunaan
│   │
│   ├── services/                     # 🔧 Business Logic & API Services
│   │   └── auth_service.dart         # Authentication service
│   │       ├── CheckAccountResponse
│   │       ├── LoginResponse
│   │       ├── SendOtpResponse
│   │       ├── checkAccount()
│   │       ├── login()
│   │       ├── sendOtp()
│   │       └── verifyOtp()
│   │
│   ├── pages/                        # 📄 UI Pages
│   │   └── login_page.dart           # Halaman login dengan multi-channel auth
│   │       ├── _LoginPageState
│   │       ├── _checkAccount()
│   │       ├── _handleLogin()
│   │       ├── _sendOtp()
│   │       └── _showOtpDialog()
│   │
│   ├── DOKUMENTASI_LOGIN.md          # 📚 Dokumentasi login system
│   └── (future folders akan ditambahkan)
│       ├── models/                   # Data models & DTOs
│       ├── repositories/             # Repository pattern
│       ├── state_management/         # Provider/GetX/Bloc
│       ├── themes/                   # App themes & styles
│       ├── utils/                    # Helper functions & utilities
│       └── widgets/                  # Reusable widgets
│
├── test/                             # Unit & Widget Tests
│   └── widget_test.dart
│
├── pubspec.yaml                      # Project dependencies
│   ├── flutter
│   ├── cupertino_icons: ^1.0.8
│   └── http: ^1.1.0                  # ✨ NEW - untuk API calls
│
├── analysis_options.yaml             # Lint rules
└── README.md                         # Project README

```

## 🔄 REQUEST FLOW

```
┌─────────────────┐
│  User Interface │  (LoginPage)
│  - InputFields  │
│  - Buttons      │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│   LoginPage (State Management)       │
│   - _checkAccount()                 │
│   - _handleLogin()                  │
│   - _sendOtp()                      │
│   - _verifyOtp()                    │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│   AuthService (Singleton)           │
│   - checkAccount()                  │
│   - login()                         │
│   - sendOtp()                       │
│   - verifyOtp()                     │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│   ApiConfig + HTTP Client           │
│   - Construct URL                   │
│   - Add Headers                     │
│   - Make Request                    │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│   Magic Laundry API Server          │
│   - Check Account                   │
│   - Login                           │
│   - Send OTP                        │
│   - Verify OTP                      │
└─────────────────────────────────────┘
```

## 📊 LOGIN FLOW DIAGRAM

```
START
  │
  ├─► Select Login Method
  │   ├─ Username/Email
  │   └─ Phone Number
  │
  ├─► Enter Username/Email/Phone
  │
  ├─► Click "Lanjutkan"
  │
  ├─► API: POST /auth/check-account
  │   └─ Response: CheckAccountResponse
  │
  ├─► Account Found?
  │   ├─ NO  → Show Error → RESET
  │   └─ YES → Continue
  │
  ├─► Display Account Info
  │
  ├─► Choose Login Method
  │   │
  │   ├─► Option 1: Login with Password
  │   │   ├─ Input Password
  │   │   ├─ Click "Masuk"
  │   │   ├─ API: POST /auth/login
  │   │   └─ Response: LoginResponse (with token)
  │   │
  │   └─► Option 2: Login with OTP
  │       ├─ Click "Login dengan OTP WhatsApp"
  │       ├─ API: POST /auth/send-otp-input
  │       ├─ Response: SendOtpResponse (with reference)
  │       ├─ Show OTP Dialog
  │       ├─ Input OTP
  │       ├─ API: POST /auth/verify-otp
  │       └─ Response: LoginResponse (with token)
  │
  ├─► Success?
  │   ├─ YES → Navigate to Home → END
  │   └─ NO  → Show Error → Reset
  │
  END
```

## 🎨 UI COMPONENTS

### LoginPage Sections
```
┌──────────────────────────────────┐
│                                  │
│        Logo (Magic Laundry)      │
│                                  │
│        Title & Subtitle          │
│                                  │
├──────────────────────────────────┤
│                                  │
│  Login Type Selection (optional) │
│  ┌─────────────┐  ┌───────────┐ │
│  │ Email/Name  │  │ Phone     │ │
│  └─────────────┘  └───────────┘ │
│                                  │
│  Username/Email/Phone Input      │
│  [___________________________]    │
│                                  │
│  "Lanjutkan" Button    (or)      │
│  ┌─────────────────────────────┐ │
│  │         LANJUTKAN           │ │
│  └─────────────────────────────┘ │
│                                  │
├──────────────────────────────────┤
│  (After Account Verified)        │
│                                  │
│  Account Info Box                │
│  ✓ email@example.com             │
│    +62812345678                  │
│                                  │
│  Password Input                  │
│  [___________________________] 👁 │
│                                  │
│  "Masuk" Button                  │
│  ┌─────────────────────────────┐ │
│  │        MASUK                │ │
│  └─────────────────────────────┘ │
│                                  │
│  "Kembali" Button                │
│  ┌─────────────────────────────┐ │
│  │        KEMBALI              │ │
│  └─────────────────────────────┘ │
│                                  │
├──────────────────────────────────┤
│  Divider "Atau"                  │
│                                  │
│  "Login dengan OTP WhatsApp"     │
│  ┌─────────────────────────────┐ │
│  │ 💬 LOGIN DENGAN OTP WHATSAPP│ │
│  └─────────────────────────────┘ │
│                                  │
├──────────────────────────────────┤
│  "Belum punya akun?"             │
│  Daftar di sini (link)           │
│                                  │
└──────────────────────────────────┘
```

## 🔐 API SECURITY

- ✅ HTTPS Only (https://app.magiclaundry.biz.id/api)
- ✅ Content-Type: application/json
- ✅ Standard HTTP timeouts (30s)
- ⏳ TODO: Token-based authentication headers
- ⏳ TODO: JWT token refresh mechanism
- ⏳ TODO: CSRF protection
- ⏳ TODO: Rate limiting handling

## 📦 DEPENDENCIES

### Current
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.1.0  # 🆕 For API calls
```

### Recommended for Future
```yaml
  # Secure storage
  flutter_secure_storage: ^9.0.0
  
  # Local storage
  shared_preferences: ^2.2.0
  
  # JWT handling
  jwt_decoder: ^2.0.0
  
  # Service locator
  get_it: ^7.6.0
  
  # State management
  provider: ^6.0.0
  # OR
  get: ^4.6.5
  # OR
  bloc: ^8.1.0
  flutter_bloc: ^8.1.0
  
  # Database
  sqflite: ^2.3.0
  hive: ^2.2.3
  
  # UI/Animation
  lottie: ^2.7.0
  shimmer: ^3.0.0
  
  # Image handling
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
```

## 🚀 GETTING STARTED

### 1. Installation
```bash
cd magicapp_mobile_v2
flutter pub get
```

### 2. Configuration
- API domain sudah di-set ke Production: https://app.magiclaundry.biz.id/api
- Edit di lib/main.dart jika perlu change environment

### 3. Run
```bash
flutter run
```

### 4. Build
```bash
flutter build apk              # Android
flutter build ipa              # iOS
flutter build web              # Web
flutter build windows          # Windows
```

## 📝 NOTES

- Login flow mendukung 3 metode: Username/Email, Phone, OTP via WhatsApp
- Semua error message dalam Bahasa Indonesia
- Loading indicator untuk semua long-running operations
- Responsive design untuk berbagai ukuran device
- Material Design 3 dengan color scheme Deep Purple

---

Updated: 26 May 2026
Version: 1.0.0
Status: Ready for Development ✅
