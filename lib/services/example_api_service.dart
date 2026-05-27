import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_client.dart';
import 'token_manager.dart';

/// Example API Service yang menggunakan token untuk authenticated requests
class ExampleApiService {
  final http.Client _client;
  final TokenManager _tokenManager;

  // Constructor dengan dependency injection
  ExampleApiService({http.Client? client, TokenManager? tokenManager})
    : _client = client ?? HttpClientFactory.getAuthenticatedClient(),
      _tokenManager = tokenManager ?? TokenManager();

  /// Example: Fetch user profile dengan token
  /// Token otomatis ditambahkan ke Authorization header
  Future<Map<String, dynamic>> getUserProfile({
    required String userId,
    String baseUrl = 'https://api.example.com',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/$userId');

      // Authorization header otomatis ditambahkan oleh AuthenticatedHttpClient
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired atau invalid
        throw Exception('Unauthorized - Token mungkin expired');
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  /// Example: Create order dengan token
  Future<Map<String, dynamic>> createOrder({
    required String serviceType,
    required int weight,
    required String deliveryAddress,
    String baseUrl = 'https://api.example.com',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/orders');

      final body = jsonEncode({
        'service_type': serviceType,
        'weight': weight,
        'delivery_address': deliveryAddress,
      });

      // Authorization header otomatis ditambahkan oleh AuthenticatedHttpClient
      final response = await _client.post(url, body: body);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token mungkin expired');
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  /// Example: Update user profile dengan token
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String phone,
    required String address,
    String baseUrl = 'https://api.example.com',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/$userId');

      final body = jsonEncode({
        'name': name,
        'phone': phone,
        'address': address,
      });

      // Authorization header otomatis ditambahkan oleh AuthenticatedHttpClient
      final response = await _client.put(url, body: body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token mungkin expired');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Example: Delete order dengan token
  Future<void> cancelOrder({
    required String orderId,
    String baseUrl = 'https://api.example.com',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/orders/$orderId');

      // Authorization header otomatis ditambahkan oleh AuthenticatedHttpClient
      final response = await _client.delete(url);

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token mungkin expired');
      } else {
        throw Exception('Failed to cancel order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error canceling order: $e');
    }
  }

  /// Example: Logout (clear token)
  Future<void> logout() async {
    try {
      // Clear token dari local storage
      await _tokenManager.clearToken();
      print('Logged out successfully');
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }
}

/// EXAMPLE USAGE IN WIDGETS:
/// 
/// ```dart
/// class OrderPage extends StatefulWidget {
///   @override
///   State<OrderPage> createState() => _OrderPageState();
/// }
/// 
/// class _OrderPageState extends State<OrderPage> {
///   final apiService = ExampleApiService();
/// 
///   Future<void> _createOrder() async {
///     try {
///       final result = await apiService.createOrder(
///         serviceType: 'regular',
///         weight: 10,
///         deliveryAddress: 'Jl. Raya No. 123',
///       );
///       print('Order created: $result');
///     } catch (e) {
///       print('Error: $e');
///     }
///   }
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: ElevatedButton(
///         onPressed: _createOrder,
///         child: const Text('Create Order'),
///       ),
///     );
///   }
/// }
/// ```
