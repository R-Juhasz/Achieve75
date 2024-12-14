import 'dart:convert';
import 'package:http/http.dart' as http;

class FatSecretApiService {
  static const String _baseUrl = 'https://oauth.fatsecret.com/connect/token';
  static const String _clientId = '912620e95cd1404e9899b258315dbd55'; // Replace with your Client ID
  static const String _clientSecret = 'c9c507a6b3294e3e834223f83a3cf7a2'; // Replace with your Client Secret

  String? _accessToken;

  /// Fetch access token using client credentials
  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'scope': 'basic',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate with FatSecret: ${response.body}');
    }
  }

  /// Fetch diet plans
  Future<List<dynamic>> fetchDietPlans(String query) async {
    if (_accessToken == null) {
      await authenticate();
    }

    final response = await http.get(
      Uri.parse('https://platform.fatsecret.com/rest/v2.0/foods.search?search_expression=$query'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['foods']['food'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch diet plans: ${response.body}');
    }
  }
}

