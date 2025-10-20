import 'package:sqflite/sqflite.dart';
import 'package:student_management/Model/student.dart';
import 'package:student_management/Data/Database/base_dao.dart';
import 'package:student_management/Data/Database/student_management_database.dart';

class StudentDao extends BaseDao<Student, String> {
  final StudentManagementDatabase _database = StudentManagementDatabase();

  @override
  String get tableName => 'Student';

  @override
  String get primaryKey => 'Id';

  @override
  Future<Database> get database => _database.database;

  @override
  Student fromMap(Map<String, dynamic> map) {
    return Student.fromJson(map);
  }
}
