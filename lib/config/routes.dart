import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

/// Centralized routing configuration
class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String home = '/home';

  /// Generate routes based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
          settings: settings,
        );
    }
  }

  /// List of all routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {login: (_) => const LoginPage(), home: (_) => const HomePage()};
  }
}
