import 'package:student_management/Data/Database/major_dao.dart';
import 'package:student_management/Model/major.dart';

class MajorRepository {
  final MajorDao _dao = MajorDao();

  Future<String> insertMajor(Major major) async {
    final id = major.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final majorWithId = Major(
      id: id,
      majorName: major.majorName,
      description: major.description,
    );
    await _dao.insert(majorWithId);
    return id;
  }

  Future<List<Major>> getAllMajors() async {
    return await _dao.getAll();
  }

  Future<Major?> getMajorById(String id) async {
    return await _dao.getById(id);
  }

  Future<int> updateMajor(Major major) async {
    return await _dao.update(major, major.id);
  }

  Future<int> deleteMajor(String id) async {
    return await _dao.delete(id);
  }
}
