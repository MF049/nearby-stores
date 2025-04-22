import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/store.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  final Map<String, double> _storeDistances = {};
  final String _tomTomApiKey = 'q0XVWYmmGkUW4oWMWvlFxD0AVOdmxtXl'; // Replace with your API key

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, double> get storeDistances => _storeDistances;

  // Get current location
  Future<Position?> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions were denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition();
      _isLoading = false;
      notifyListeners();
      return _currentPosition;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Calculate distance using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final startPoint = maps_toolkit.LatLng(lat1, lon1);
    final endPoint = maps_toolkit.LatLng(lat2, lon2);
    
    // Calculate distance in meters
    final distanceInMeters = maps_toolkit.SphericalUtil.computeDistanceBetween(startPoint, endPoint);
    
    // Convert to kilometers
    return distanceInMeters / 1000;
  }

  // Get distance to a store
  Future<double> getDistanceToStore(Store store) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }
    
    if (_currentPosition == null) {
      throw Exception('Unable to get current location');
    }
    
    final distance = calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      store.latitude,
      store.longitude
    );
    
    _storeDistances[store.id] = distance;
    notifyListeners();
    
    return distance;
  }

  // Get nearby stores using TomTom API
  Future<List<Store>> getNearbyStores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentPosition == null) {
        await getCurrentLocation();
      }
      
      if (_currentPosition == null) {
        throw Exception('Unable to get current location');
      }
      
      final lat = _currentPosition!.latitude;
      final lon = _currentPosition!.longitude;
      
      final url = 'https://api.tomtom.com/search/2/nearbySearch/.json'
          '?lat=$lat&lon=$lon'
          '&radius=10000'
          '&categorySet=7315'  // Retail category
          '&key=$_tomTomApiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        final stores = results.map((result) {
          final position = result['position'];
          final poi = result['poi'];
          final address = result['address'];
          
          return Store(
            id: result['id'].toString(),
            name: poi['name'],
            address: '${address['freeformAddress']}',
            latitude: position['lat'],
            longitude: position['lon'],
          );
        }).toList();
        
        _isLoading = false;
        notifyListeners();
        return stores.cast<Store>();
      } else {
        throw Exception('Failed to load nearby stores');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Clear current position and stored distances
  void clear() {
    _currentPosition = null;
    _storeDistances.clear();
    notifyListeners();
  }
}