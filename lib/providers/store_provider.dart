import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/store.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/tomtom_service.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  List<Store> _favoriteStores = [];
  bool _isLoading = false;
  Position? _currentPosition;

  List<Store> get stores => _stores;
  List<Store> get favoriteStores => _favoriteStores;
  bool get isLoading => _isLoading;
  Position? get currentPosition => _currentPosition;

  final DatabaseService _databaseService = DatabaseService.instance;
  final LocationService _locationService = LocationService();
  final TomTomService _tomTomService = TomTomService();

  StoreProvider() {
    loadStores();
    loadFavoriteStores();
    getCurrentLocation();
  }

  Future<void> loadStores() async {
    _isLoading = true;
    notifyListeners();

    _stores = await _databaseService.getAllStores();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFavoriteStores() async {
    _isLoading = true;
    notifyListeners();

    _favoriteStores = await _databaseService.getFavoriteStores();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStore(Store store) async {
    _isLoading = true;
    notifyListeners();

    final storeId = await _databaseService.insertStore(store);
    _stores.add(store.copyWith(id: storeId));
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToFavorites(Store store) async {
    _isLoading = true;
    notifyListeners();

    await _databaseService.addToFavorites(store);
    _favoriteStores.add(store.copyWith(isFavorite: true));
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeFromFavorites(String id) async {
    _isLoading = true;
    notifyListeners();

    await _databaseService.removeFromFavorites(id);
    _favoriteStores.removeWhere((store) => store.id == id);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<double> getDistanceToStore(Store store) async {
    if (_currentPosition == null) {
      await getCurrentLocation();
    }
    
    if (_currentPosition != null) {
      // Try TomTom API first
      double apiDistance = await _tomTomService.getDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        store.latitude,
        store.longitude
      );
      
      // If API fails, calculate locally
      if (apiDistance <= 0) {
        return _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          store.latitude,
          store.longitude
        );
      }
      
      return apiDistance;
    }
    
    return 0.0;
  }
}
