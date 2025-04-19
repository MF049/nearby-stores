import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/store.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stores.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        isFavorite INTEGER NOT NULL
      )
    ''');
  }

  Future<Store> insertStore(Store store) async {
    final db = await database;
    final id = await db.insert('stores', store.toMap());
    return store;
  }

  Future<List<Store>> getAllStores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('stores');
    return List.generate(maps.length, (i) => Store.fromMap(maps[i]));
  }

  Future<List<Store>> getFavoriteStores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stores',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Store.fromMap(maps[i]));
  }

  Future<int> updateStoreFavorite(Store store) async {
    final db = await database;
    return db.update(
      'stores',
      {'isFavorite': store.isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [store.id],
    );
  }
} 