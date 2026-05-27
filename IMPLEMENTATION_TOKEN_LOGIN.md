# Login System dengan Token Storage Implementation

## Overview

Sistem login ini mengikuti format response dari backend Laravel dengan struktur:

```json
{
  "status": "success",
  "message": "Berhasil masuk akun",
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "name": "John Doe",
    "username": "johndoe",
    "email": "john@example.com",
    "phone": "081234567890",
    "address": "Jakarta",
    "role": "user",
    "path": "https://api.example.com/storage/avatars/...",
    "key": "123",
    "referral_code": "REF123"
  }
}
```

## Architecture

### 1. Models
- **UserModel** (`lib/models/user_model.dart`): Menyimpan data user
- **LoginResponseModel** (`lib/models/login_response_model.dart`): Response dari login endpoint

### 2. Services
- **TokenManager** (`lib/services/token_manager.dart`): Menyimpan dan mengakses token/user dari SharedPreferences
- **AuthService** (`lib/services/auth_service.dart`): Menangani API calls untuk login/OTP
- **AuthenticatedHttpClient** (`lib/services/http_client.dart`): HTTP client dengan interceptor untuk menambahkan Authorization header

### 3. Pages
- **LoginPage** (`lib/pages/login_page.dart`): UI untuk login dan OTP verification

## Flow

### Login Flow
1. User memasukkan username/email/phone dan password
2. `AuthService.login()` dipanggil dengan credentials
3. Backend mengembalikan response dengan token dan user data
4. `AuthService` secara otomatis menyimpan token dan user ke `TokenManager` via `SharedPreferences`
5. User diarahkan ke Home page

### Token Storage
Token disimpan di `SharedPreferences` dengan keys:
- `access_token`: JWT token
- `token_type`: Bearer
- `user_data`: JSON string dari UserModel
- `expires_in`: Token expiration time in seconds

## Menggunakan Token untuk Request

### Method 1: Menggunakan AuthenticatedHttpClient (Recommended)

```dart
import 'package:http/http.dart' as http;
import 'services/http_client.dart';

// Get authenticated client yang otomatis menambahkan Authorization header
var client = HttpClientFactory.getAuthenticatedClient();

// Setiap request akan otomatis menyertakan token
var response = await client.post(
  Uri.parse('https://api.example.com/orders'),
  body: jsonEncode({'amount': 50000}),
);
```

### Method 2: Menambahkan token manual ke header

```dart
import 'services/token_manager.dart';

final tokenManager = TokenManager();

// Ambil authorization header (format: "bearer {token}")
final authHeader = tokenManager.getAuthorizationHeader();

var response = await http.post(
  Uri.parse('https://api.example.com/orders'),
  headers: {
    'Authorization': authHeader!,
    'Content-Type': 'application/json',
  },
  body: jsonEncode({'amount': 50000}),
);
```

### Method 3: Mengakses token langsung

```dart
import 'services/token_manager.dart';

final tokenManager = TokenManager();

// Ambil token
String? token = tokenManager.getAccessToken();
String? tokenType = tokenManager.getTokenType(); // 'bearer'

// Gunakan untuk membuat Authorization header
String authHeader = '$tokenType $token'; // 'bearer eyJ0eXA...'
```

## Mengakses User Data

```dart
import 'services/token_manager.dart';

final tokenManager = TokenManager();

// Ambil user data
final user = tokenManager.getUser();
print(user?.name);
print(user?.email);
print(user?.role);

// Check apakah user sudah login
if (tokenManager.isAuthenticated()) {
  print('User sudah login');
}
```

## Logout

```dart
import 'services/token_manager.dart';

final tokenManager = TokenManager();

// Clear semua token dan user data
await tokenManager.clearToken();
```

## Integration dengan Existing API Calls

Untuk menggunakan token dalam API calls yang sudah ada, update request untuk menggunakan `AuthenticatedHttpClient`:

**Sebelum:**
```dart
final response = await http.post(
  Uri.parse(ApiConfig.someUrl),
  headers: {...},
  body: jsonEncode(...),
);
```

**Sesudah:**
```dart
final client = HttpClientFactory.getAuthenticatedClient();
final response = await client.post(
  Uri.parse(ApiConfig.someUrl),
  body: jsonEncode(...),
);
```

## Debugging

Untuk melihat token yang tersimpan:

```dart
import 'services/token_manager.dart';

final tokenManager = TokenManager();
print('Token: ${tokenManager.getAccessToken()}');
print('User: ${tokenManager.getUser()}');
print('Authorization Header: ${tokenManager.getAuthorizationHeader()}');
print('Is Authenticated: ${tokenManager.isAuthenticated()}');
```

## Dependencies

- `shared_preferences: ^2.2.2` - Untuk menyimpan token dan user data di local storage
- `http: ^1.1.0` - Untuk HTTP requests

## Notes

- Token otomatis ditambahkan ke setiap request via `AuthenticatedHttpClient`
- Token disimpan secara persistent di local storage
- Token tetap tersimpan meski app di-close dan buka kembali
- Pada logout, token harus dihapus dari storage
- Perhatikan expiration time dari token (field `expires_in`)
