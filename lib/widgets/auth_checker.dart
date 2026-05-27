import 'package:flutter/material.dart';
import '../services/token_manager.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

/// Widget untuk mengecek authentication status dan mengarahkan ke halaman yang sesuai
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    _authCheckFuture = _checkAuthentication();
  }

  /// Cek apakah user sudah login (ada token di localStorage)
  Future<bool> _checkAuthentication() async {
    try {
      final tokenManager = TokenManager();
      // TokenManager sudah di-initialize di main()
      final isAuthenticated = tokenManager.isAuthenticated();

      print('[AuthChecker] User authenticated: $isAuthenticated');
      if (isAuthenticated) {
        final user = tokenManager.getUser();
        print('[AuthChecker] Logged in user: ${user?.name}');
      }

      return isAuthenticated;
    } catch (e) {
      print('[AuthChecker] Error checking authentication: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authCheckFuture,
      builder: (context, snapshot) {
        // Sedang loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error saat cek auth
        if (snapshot.hasError) {
          print('[AuthChecker] Error: ${snapshot.error}');
          return const LoginPage();
        }

        // Data available
        if (snapshot.hasData) {
          final isAuthenticated = snapshot.data ?? false;

          // Ada token → arahkan ke Home
          if (isAuthenticated) {
            return const HomePage();
          }
          // Tidak ada token → arahkan ke Login
          else {
            return const LoginPage();
          }
        }

        // Default to login jika tidak ada data
        return const LoginPage();
      },
    );
  }
}
