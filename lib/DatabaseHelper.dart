import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cats_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        weight TEXT,
        breed TEXT,
        gender TEXT,
        image_path TEXT
      )
    ''');
  }

  Future<int> insertData(Map<String,
      dynamic> data,) async {
    Database db = await database;
    return await db.insert('cats_data', data);
  }

  Future<List<Map<String, dynamic>>> getData() async {
    Database db = await database;
    return await db.query('cats_data');
  }

  Future<int> deleteSingleDataItem(int id,) async {
    Database db = await database;
    return await db.delete('cats_data', where:'id = ?',whereArgs: [id]);
  }
}
