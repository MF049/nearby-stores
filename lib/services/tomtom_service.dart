import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import '../models/store.dart';

class TomTomService {
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getLocalFile() async {
    final path = await _getLocalPath();
    return File('$path/nearby_stores.json');
  }

  Future<void> saveNearbyStores(List<Store> stores) async {
    final file = await _getLocalFile();
    final storesJson = stores.map((store) => store.toMap()).toList();
    await file.writeAsString(jsonEncode(storesJson));
  }

  Future<List<Store>> loadSavedStores() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final List<dynamic> storesJson = jsonDecode(contents);
      return storesJson.map((json) => Store.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Store>> fetchNearbyStores(double latitude, double longitude) async {
    final Uri uri = Uri.parse(ApiConfig.baseUrl).replace(queryParameters: {
      'key': ApiConfig.tomtomApiKey,
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'radius': ApiConfig.searchRadius.toString(),
      'limit': ApiConfig.resultsLimit.toString(),
    });

    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        
        final stores = results.map((result) {
          final poi = result['poi'];
          final address = result['address'];
          final position = result['position'];
          
          return Store(
            name: poi['name'],
            address: address['freeformAddress'],
            latitude: position['lat'],
            longitude: position['lon'],
          );
        }).toList();

        // Save stores to local file
        await saveNearbyStores(stores);
        
        return stores;
      } else {
        throw Exception('Failed to fetch nearby stores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby stores: $e');
    }
  }
} 