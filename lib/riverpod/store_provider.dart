import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/store.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/tomtom_service.dart';

part 'store_provider.g.dart';

// Store list provider
@riverpod
class StoreNotifier extends _$StoreNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  final LocationService _locationService = LocationService();
  final TomTomService _tomTomService = TomTomService();

  @override
  Future<List<Store>> build() async {
    return _databaseService.getAllStores();
  }

  Future<void> addStore(Store store) async {
    state = const AsyncValue.loading();
    try {
      final storeId = await _databaseService.insertStore(store);
      final newStore = store.copyWith(id: storeId);
      state = AsyncValue.data([...state.value ?? [], newStore]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<double> getDistanceToStore(Store store, Position? currentPosition) async {
    Position? position = currentPosition;
    
    if (position == null) {
      try {
        position = await _locationService.getCurrentLocation();
      } catch (e) {
        return 0.0;
      }
    }
    
    // Try TomTom API first
    double apiDistance = await _tomTomService.getDistance(
      position.latitude,
      position.longitude,
      store.latitude,
      store.longitude
    );
    
    // If API fails, calculate locally
    if (apiDistance <= 0) {
      return _locationService.calculateDistance(
        position.latitude,
        position.longitude,
        store.latitude,
        store.longitude
      );
    }
    
    return apiDistance;
      
    return 0.0;
  }
}

// Favorite stores provider
@riverpod
class FavoriteStoresNotifier extends _$FavoriteStoresNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  Future<List<Store>> build() async {
    return _databaseService.getFavoriteStores();
  }

  Future<void> addToFavorites(Store store) async {
    state = const AsyncValue.loading();
    try {
      await _databaseService.addToFavorites(store);
      final updatedStore = store.copyWith(isFavorite: true);
      state = AsyncValue.data([...state.value ?? [], updatedStore]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeFromFavorites(String id) async {
    state = const AsyncValue.loading();
    try {
      await _databaseService.removeFromFavorites(id);
      state = AsyncValue.data(
        (state.value ?? []).where((store) => store.id != id).toList()
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Current location provider
@riverpod
class LocationNotifier extends _$LocationNotifier {
  final LocationService _locationService = LocationService();

  @override
  Future<Position?> build() async {
    try {
      return await _locationService.getCurrentLocation();
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    try {
      final position = await _locationService.getCurrentLocation();
      state = AsyncValue.data(position);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 