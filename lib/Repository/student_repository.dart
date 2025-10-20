import 'package:student_management/Data/Database/student_dao.dart';
import 'package:student_management/Model/student.dart';

class StudentRepository {
  final StudentDao _dao = StudentDao();

  // If student.id is provided (String), return it; otherwise use the rowId returned by insert and convert to string.
  Future<String> insertStudent(Student student) async {
    final rowId = await _dao.insert(student);
    return student.id ?? rowId.toString();
  }

  Future<List<Student>> getAllStudents() async {
    return await _dao.getAll();
  }

  Future<Student?> getStudentById(String id) async {
    return await _dao.getById(id);
  }

  Future<int> updateStudent(Student student) async {
    if (student.id == null) throw ArgumentError('Student id is required for update');
    return await _dao.update(student, student.id!);
  }

  Future<int> deleteStudent(String id) async {
    return await _dao.delete(id);
  }
}
