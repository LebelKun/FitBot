import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'my_database.db';

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
         CREATE TABLE DietEntries(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           date TEXT,
           calories INTEGER
         )
       ''');
    await db.execute('''
         CREATE TABLE SoloTasks(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           name TEXT,
           completed INTEGER
         )
       ''');
  }

  Future<void> deleteEntry(String tableName, int id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
