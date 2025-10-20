import 'package:sqflite/sqflite.dart';
import '../../Model/base_model.dart';

abstract class BaseDao<T extends BaseModel> {
  String get tableName;
  String get primaryKey;

  Future<int> insert(T item) async {
    final db = await database;
    return await db.insert(tableName, item.toJson());
  }

  Future<List<T>> getAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<T?> getById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(T item, int id) async {
    final db = await database;
    return await db.update(
      tableName,
      item.toJson(),
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$primaryKey = ?',
      whereArgs: [id],
    );
  }

  Future<Database> get database;

  T fromMap(Map<String, dynamic> map);
}
