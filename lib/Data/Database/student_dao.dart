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

  // Clear MajorId (set to NULL) for all students that reference the given majorId.
  // This is used to avoid dangling foreign-key-like references when a Major is deleted.
  Future<int> clearMajorFromStudents(String majorId) async {
    final db = await database;
    // Use rawUpdate to set MajorId to NULL where it matches the provided id.
    return await db.rawUpdate('UPDATE $tableName SET MajorId = NULL WHERE MajorId = ?', [majorId]);
  }
}
