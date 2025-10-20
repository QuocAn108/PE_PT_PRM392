import '../../Model/student.dart';
import '../../Model/major.dart';
import 'base_viewmodel.dart';
import 'package:student_management/Repository/student_repository.dart';
import 'package:student_management/Data/Database/major_dao.dart';

class HomeViewModel extends BaseViewModel {
  final StudentRepository _repo = StudentRepository();
  final MajorDao _majorDao = MajorDao();
  List<Student> _students = [];
  List<Major> _majors = [];

  List<Student> get students => _students;
  List<Major> get majors => _majors;

  @override
  void init() {
    super.init();
    _loadStudentsFromDb();
    _loadMajorsFromDb();
  }

  Future<void> _loadStudentsFromDb() async {
    setLoading(true);
    try {
      final list = await _repo.getAllStudents();
      _students = list;
      clearError();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
    notifyListeners();
  }

  Future<void> _loadMajorsFromDb() async {
    // load majors but do not toggle the global loading state to avoid interfering with UI spinners
    try {
      final list = await _majorDao.getAll();
      _majors = list;
      clearError();
    } catch (e) {
      setError(e.toString());
    }
    notifyListeners();
  }

  String? getMajorNameById(String? id) {
    if (id == null) return null;
    final m = _majors.firstWhere((e) => e.id == id, orElse: () => Major(id: id, majorName: id));
    return m.majorName;
  }

  Future<void> addStudent(Student student) async {
    setLoading(true);
    try {
      final id = await _repo.insertStudent(student);
      final added = Student(
        id: id,
        fullName: student.fullName,
        majorID: student.majorID,
        address: student.address,
        phoneNumber: student.phoneNumber,
        avatarURL: student.avatarURL,
        latitude: student.latitude,
        longitude: student.longitude,
      );
      _students.add(added);
      clearError();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
    notifyListeners();
  }

  Future<void> removeStudent(String id) async {
    setLoading(true);
    try {
      await _repo.deleteStudent(id);
      _students.removeWhere((student) => student.id == id);
      clearError();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    setLoading(true);
    try {
      await _repo.updateStudent(student);
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
      }
      clearError();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
    notifyListeners();
  }
}
