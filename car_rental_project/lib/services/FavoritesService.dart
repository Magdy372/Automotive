import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  static Database? _database;

  factory FavoritesService() {
    return _instance;
  }

  FavoritesService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'favorites.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carId TEXT UNIQUE,
        name TEXT,
        brand TEXT,
        price REAL,
        image TEXT
      )
    ''');
  }

  // Add a car to favorites
  Future<void> addFavorite(Map<String, dynamic> car) async {
    final db = await database;
    await db.insert(
      'favorites',
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove a car from favorites
  Future<void> removeFavorite(String carId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'carId = ?',
      whereArgs: [carId],
    );
  }

  // Get all favorite cars
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return await db.query('favorites');
  }

  // Check if a car is favorited
  Future<bool> isFavorite(String carId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'carId = ?',
      whereArgs: [carId],
    );
    return result.isNotEmpty;
  }
}