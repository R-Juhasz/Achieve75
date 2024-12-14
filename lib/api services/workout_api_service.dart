import 'dart:convert';
import 'dart:async'; // For throttling requests
import 'package:http/http.dart' as http;

class WorkoutApiService {
  static const String _baseUrl = 'https://exercisedb.p.rapidapi.com';
  static const String _apiKey = 'e590bde11fmsh6d127800f1d9bc4p1396ffjsn3a124ab8a4df'; // Replace with your actual API key

  Future<List<dynamic>> fetchWorkouts({String? bodyPart, String? equipment}) async {
    try {
      // Throttle requests
      await Future.delayed(const Duration(seconds: 1));

      // Determine the endpoint based on provided parameters
      String endpoint = '';

      if (bodyPart != null && bodyPart.isNotEmpty) {
        final encodedBodyPart = Uri.encodeComponent(bodyPart);
        endpoint = '/exercises/bodyPart/$encodedBodyPart';
      } else if (equipment != null && equipment.isNotEmpty) {
        final encodedEquipment = Uri.encodeComponent(equipment);
        endpoint = '/exercises/equipment/$encodedEquipment';
      } else {
        endpoint = '/exercises';
      }

      // Construct the URL
      final url = Uri.parse('$_baseUrl$endpoint');

      print('Requesting URL: $url');

      // Make the GET request
      final response = await http.get(
        url,
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        print('Workouts fetched successfully!');
        return json.decode(response.body);
      } else {
        print('Failed to fetch workouts. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to fetch workouts');
      }
    } catch (e) {
      print('Error in fetchWorkouts: $e');
      throw Exception('Error fetching workouts: $e');
    }
  }
}
