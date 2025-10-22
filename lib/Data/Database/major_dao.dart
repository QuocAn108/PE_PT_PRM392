import 'package:sqflite/sqflite.dart';
import 'package:student_management/Model/major.dart';
import 'package:student_management/Data/Database/base_dao.dart';
import 'package:student_management/Data/Database/student_management_database.dart';

class MajorDao extends BaseDao<Major, String> {
  final StudentManagementDatabase _database = StudentManagementDatabase();

  @override
  String get tableName => 'Major';

  @override
  String get primaryKey => 'Id';

  @override
  Future<Database> get database => _database.database;

  @override
  Major fromMap(Map<String, dynamic> map) {
    return Major.fromJson(map);
  }
}
