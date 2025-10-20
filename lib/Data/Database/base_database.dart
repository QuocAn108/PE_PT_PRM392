import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class BaseDatabase {
  static Database? _database;

  String get databaseName;
  int get databaseVersion;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version);
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion);
}
