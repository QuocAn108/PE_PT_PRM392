import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class BaseDatabase {
  static Database? _database;

  String get databaseName;
  int get databaseVersion;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // made public so subclasses (in other files) can override to customize initialization
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  // Public lifecycle methods so subclasses can override them across files
  Future<void> onCreate(Database db, int version);
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion);
}
