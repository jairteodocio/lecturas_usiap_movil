import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE lecturas (
      num_c TEXT PRIMARY KEY,
      lecrura_a TEXT,
      lecrura_n TEXT
    )
  '''); // Creación de la tabla importe
  }

  Future<void> insertProducto(Map<String, dynamic> producto) async {
    final db = await database;
    await db.insert(
      'lecturas',
      producto,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ FUNCIÓN PARA OBTENER LA LECTURA ANTERIOR POR ID
  Future<Map<String, dynamic>?> getLecturaById(String numC) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'lecturas',
      where: 'num_c = ?',
      whereArgs: [numC],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // ✅ FUNCIÓN PARA ACTUALIZAR LA LECTURA NUEVA
  Future<void> updateLectura(String numC, String nuevaLectura) async {
    final db = await database;
    await db.update(
      'lecturas',
      {'lecrura_n': nuevaLectura},
      where: 'num_c = ?',
      whereArgs: [numC],
    );
  }

  // ✅ FUNCIÓN PARA INSERTAR UN NUEVO REGISTRO (SI NO EXISTE)
  Future<void> insertLectura(Map<String, dynamic> lectura) async {
    final db = await database;
    await db.insert(
      'lecturas',
      lectura,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
