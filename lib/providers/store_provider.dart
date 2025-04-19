import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import '../models/store.dart';
import '../services/database_helper.dart';
import '../services/tomtom_service.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  List<Store> _favoriteStores = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TomTomService _tomtomService = TomTomService();
  Position? _currentPosition;

  List<Store> get stores => _stores;
  List<Store> get favoriteStores => _favoriteStores;
  Position? get currentPosition => _currentPosition;

  Future<void> loadStores() async {
    _stores = await _dbHelper.getAllStores();
    _favoriteStores = await _dbHelper.getFavoriteStores();
    notifyListeners();
  }

  Future<void> addStore(Store store) async {
    await _dbHelper.insertStore(store);
    await loadStores();
  }

  Future<void> toggleFavorite(Store store) async {
    store.isFavorite = !store.isFavorite;
    await _dbHelper.updateStoreFavorite(store);
    await loadStores();
  }

  Future<void> updateCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    notifyListeners();
  }

  Future<void> fetchNearbyStores() async {
    try {
      await updateCurrentPosition();
      if (_currentPosition == null) {
        throw Exception('Could not get current position');
      }

      final nearbyStores = await _tomtomService.fetchNearbyStores(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      // Calculate distances for all stores
      final stores = await Future.wait(
        nearbyStores.map((store) async {
          final distanceData = await getDistanceToStore(store);
          return store.copyWith(
            distance: distanceData['straight_distance'],
            direction: distanceData['direction'],
          );
        }),
      );

      // Save stores to local database
      for (var store in stores) {
        await addStore(store);
      }

      await loadStores();
    } catch (e) {
      // If API fails, try to load cached stores
      _stores = await _tomtomService.loadSavedStores();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDistanceToStore(Store store) async {
    if (_currentPosition == null) {
      await updateCurrentPosition();
    }

    if (_currentPosition == null) {
      throw Exception('Could not get current position');
    }
    
    // Calculate straight-line distance using Geolocator
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      store.latitude,
      store.longitude,
    );

    // Calculate road distance using Maps Toolkit (Spherical)
    double sphericalDistance = maps_toolkit.SphericalUtil.computeDistanceBetween(
      maps_toolkit.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      maps_toolkit.LatLng(store.latitude, store.longitude),
    ).toDouble();

    // Calculate bearing (direction) to the store
    double bearing = maps_toolkit.SphericalUtil.computeHeading(
      maps_toolkit.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      maps_toolkit.LatLng(store.latitude, store.longitude),
    ).toDouble();

    // Convert bearing to cardinal direction
    String direction = _getCardinalDirection(bearing);

    return {
      'straight_distance': distanceInMeters / 1000, // Convert to kilometers
      'spherical_distance': sphericalDistance / 1000, // Convert to kilometers
      'direction': direction,
      'bearing': bearing,
    };
  }

  String _getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    var index = ((bearing + 22.5) % 360) ~/ 45;
    return directions[index];
  }
} 