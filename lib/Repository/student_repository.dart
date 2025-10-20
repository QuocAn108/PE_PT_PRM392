import 'package:student_management/Data/Database/student_dao.dart';
import 'package:student_management/Model/student.dart';

class StudentRepository {
  final StudentDao _dao = StudentDao();

  Future<int> insertStudent(Student student) async {
    return await _dao.insert(student);
  }

  Future<List<Student>> getAllStudents() async {
    return await _dao.getAll();
  }

  Future<Student?> getStudentById(int id) async {
    return await _dao.getById(id);
  }

  Future<int> updateStudent(Student student) async {
    if (student.id == null) throw ArgumentError('Student id is required for update');
    return await _dao.update(student, student.id!);
  }

  Future<int> deleteStudent(int id) async {
    return await _dao.delete(id);
  }
}

