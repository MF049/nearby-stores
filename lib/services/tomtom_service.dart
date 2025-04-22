import 'dart:convert';
import 'package:http/http.dart' as http;

class TomTomService {
  final String apiKey = 'YOUR_TOMTOM_API_KEY'; // Replace with your actual API key
  final String baseUrl = 'https://api.tomtom.com/search/2/nearbySearch/.json';

  Future<double> getDistance(double startLat, double startLon, double endLat, double endLon) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?key=$apiKey&lat=$startLat&lon=$startLon&categorySet=7315&limit=1'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['dist'] / 1000; // Convert to km
        }
      }
      return 0.0;
    } catch (e) {
      print('Error getting distance: $e');
      return 0.0;
    }
  }
}
