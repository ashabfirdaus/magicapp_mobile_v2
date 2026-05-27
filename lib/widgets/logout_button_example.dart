import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../config/routes.dart';

/// Contoh implementasi Logout Button di halaman Profile/Settings
class LogoutButtonExample extends StatefulWidget {
  const LogoutButtonExample({super.key});

  @override
  State<LogoutButtonExample> createState() => _LogoutButtonExampleState();
}

class _LogoutButtonExampleState extends State<LogoutButtonExample> {
  final authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setState(() => _isLoading = true);

    try {
      // Call logout dari AuthService
      await authService.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout berhasil'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate ke login page
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Logout', style: TextStyle(color: Colors.white)),
    );
  }
}

/// Contoh penggunaan di Profile Page:
///
/// ```dart
/// class ProfilePage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Profile')),
///       body: Column(
///         children: [
///           // ... user info widgets ...
///           const SizedBox(height: 32),
///           const LogoutButtonExample(),
///         ],
///       ),
///     );
///   }
/// }
/// ```

/// Alternative: Simple logout tanpa confirmation dialog
class SimpleLogoutButton extends StatefulWidget {
  const SimpleLogoutButton({super.key});

  @override
  State<SimpleLogoutButton> createState() => _SimpleLogoutButtonState();
}

class _SimpleLogoutButtonState extends State<SimpleLogoutButton> {
  final authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    try {
      await authService.logout();

      if (mounted) {
        // Navigate ke login page
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Logout'),
      onTap: _isLoading ? null : _handleLogout,
    );
  }
}
