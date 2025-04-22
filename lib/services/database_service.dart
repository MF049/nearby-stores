import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user.dart';
import '../models/store.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  // Private constructor
  DatabaseService._internal();

  // Database instance
  Database? _database;

  // Stores
  final _userStore = intMapStoreFactory.store('users');
  final _storeStore = intMapStoreFactory.store('stores');
  final _favoriteStoreStore = intMapStoreFactory.store('favorite_stores');



  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web
      final factory = databaseFactoryWeb;
      return await factory.openDatabase('store_finder_db');
    } else {
      // For mobile
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentDir.path, 'store_finder.db');
      final factory = databaseFactoryIo;
      return await factory.openDatabase(dbPath);
    }
  }

  // User operations
  Future<String> insertUser(User user) async {
    final db = await database;
    final id = await _userStore.add(db, user.toMap());
    return id.toString();
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('email', email));
    final snapshot = await _userStore.findFirst(db, finder: finder);
    if (snapshot != null) {
      return User.fromMap(snapshot.key.toString(), snapshot.value);
    }
    return null;
  }

  Future<bool> authenticateUser(String email, String password) async {
    final db = await database;
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('email', email),
        Filter.equals('password', password),
      ]),
    );
    final snapshot = await _userStore.findFirst(db, finder: finder);
    return snapshot != null;
  }

  // Store operations
  Future<List<Store>> getAllStores() async {
    final db = await database;
    final snapshots = await _storeStore.find(db);
    return snapshots.map((snapshot) => 
      Store.fromMap(snapshot.key.toString(), snapshot.value)
    ).toList();
  }

  Future<String> insertStore(Store store) async {
    final db = await database;
    final id = await _storeStore.add(db, store.toMap());
    return id.toString();
  }

  // Favorite store operations
  Future<List<Store>> getFavoriteStores() async {
    final db = await database;
    final snapshots = await _favoriteStoreStore.find(db);
    return snapshots.map((snapshot) => 
      Store.fromMap(snapshot.key.toString(), snapshot.value)
    ).toList();
  }

  Future<void> addToFavorites(Store store) async {
    final db = await database;
    final updatedStore = store.copyWith(isFavorite: true);
    await _favoriteStoreStore.add(db, updatedStore.toMap());
  }

  Future<void> removeFromFavorites(String id) async {
    final db = await database;
    final finder = Finder(filter: Filter.byKey(int.parse(id)));
    await _favoriteStoreStore.delete(db, finder: finder);
  }

  // Add this at the bottom of your DatabaseService class

// Initialize database with sample data
Future<void> initializeDatabase() async {
  final db = await database;
  
  // Clear existing data (optional)
  await _userStore.delete(db);
  await _storeStore.delete(db);
  await _favoriteStoreStore.delete(db);

  // Add sample users
  final sampleUsers = [
    User(
      id: '1',
      username: 'admin',
      email: 'admin@storefinder.com',
      password: 'admin',
    ),
    User(
      id: '2',
      username: 'user',
      email: 'user@example.com',
      password: 'password',
    ),
  ];

  for (final user in sampleUsers) {
    await insertUser(user);
  }

  // Add sample stores
  final sampleStores = [
    Store(
      id: '101',
      name: 'Shoe Store',
      address: 'Mall of Egypt shop no:502',
      latitude: 30.101479,
      longitude: 31.230603,
      isFavorite: true,
    ),
    Store(
      id: '102',
      name: 'Tech Haven',
      address: '456 Tech Boulevard',
      latitude: 30.128428,
      longitude: 31.323850,
      isFavorite: true,
    ),
    Store(
      id: '103',
      name: 'Fashion Mall',
      address: '789 Style Avenue',
      latitude: 29.980815,
      longitude: 31.185608,
      isFavorite: false,
    ),
    Store(
      id: '104',
      name: 'Cairo Uni BurgerHut',
      address: 'Inside cairo university main campus',
      latitude: 30.027641,
      longitude: 31.209064,
      isFavorite: true,
    ),
    Store(
      id: '105',
      name: 'Book Paradise',
      address: '321 Knowledge Road',
      latitude: 30.095242,
      longitude: 31.348719,
      isFavorite: true,
    ),
  ];

  for (final store in sampleStores) {
    await insertStore(store);
    if (store.isFavorite) {
      await addToFavorites(store);
    }
  }
}

// Check if database is empty (helper method)
Future<bool> isDatabaseEmpty() async {
  final db = await database;
  final usersCount = await _userStore.count(db);
  final storesCount = await _storeStore.count(db);
  return usersCount == 0 && storesCount == 0;
}
}
