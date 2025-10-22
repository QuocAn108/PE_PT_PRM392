import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../Model/major.dart';
import '../../Model/student.dart';
import '../../Repository/major_repository.dart';
import '../../Repository/student_repository.dart';
import '../../Repository/account_repository.dart';

class SinhVienViewModel extends ChangeNotifier {
  final StudentRepository _studentRepo = StudentRepository();
  final MajorRepository _nganhRepo = MajorRepository();
  final AuthRepository _authRepo = AuthRepository();
  final ImagePicker _picker = ImagePicker();

  List<Student> _students = [];
  List<Major> _nganhs = [];
  bool _isLoading = false;
  File? _pickedImage;

  List<Student> get students => _students;
  List<Major> get nganhs => _nganhs;
  bool get isLoading => _isLoading;
  File? get pickedImage => _pickedImage;

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchStudents(),
      fetchNganhs(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    try {
      _students = await _studentRepo.getAllStudents();
    } catch (e) {
      debugPrint("Lỗi khi tải danh sách sinh viên: $e");
    }
    notifyListeners();
  }

  Future<void> fetchNganhs() async {
    try {
      _nganhs = await _nganhRepo.getAllMajors();
    } catch (e) {
      debugPrint("Lỗi khi tải danh sách ngành: $e");
    }
    notifyListeners();
  }

  Future<void> deleteStudent(String maSV) async {
    await _studentRepo.deleteStudent(maSV);
    await fetchStudents();
  }

  // --- Nganh Management ---
  Future<void> addNganh(Major nganh) async {
    await _nganhRepo.insertMajor(nganh);
    await fetchNganhs();
  }

  Future<void> updateNganh(Major nganh) async {
    await _nganhRepo.updateMajor(nganh);
    await fetchNganhs();
  }

  Future<void> deleteNganh(String maNganh) async {
    await _nganhRepo.deleteMajor(maNganh);
    await fetchNganhs();
  }

  void clearPickedImage() {
    _pickedImage = null;
    notifyListeners();
  }

  Future<void> saveStudent({
    required String maSV,
    required String hoTen,
    required String? diaChi,
    required String? soDT,
    required String? maNganh,
    required String? currentAvatarPath,
    bool isEditing = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    String? finalAvatarPath = currentAvatarPath;

    if (_pickedImage != null) {
      try {
        // Lấy thư mục lưu trữ app
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String avatarsDir = path.join(appDir.path, 'avatars');
        
        // Tạo thư mục avatars nếu chưa có
        await Directory(avatarsDir).create(recursive: true);
        
        // Tạo tên file mới: maSV_timestamp.jpg
        final String fileName = '${maSV}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = path.join(avatarsDir, fileName);
        
        // Copy file từ đường dẫn tạm sang permanent storage
        await _pickedImage!.copy(newPath);
        finalAvatarPath = newPath;
        
        // Xóa ảnh cũ nếu có (để tránh lãng phí bộ nhớ)
        if (currentAvatarPath != null && 
            currentAvatarPath.isNotEmpty && 
            File(currentAvatarPath).existsSync()) {
          try {
            await File(currentAvatarPath).delete();
          } catch (e) {
            debugPrint('Không thể xóa ảnh cũ: $e');
          }
        }
      } catch (e) {
        debugPrint('Lỗi khi lưu avatar: $e');
        // Nếu lỗi, giữ nguyên đường dẫn cũ
      }
    }

    final sv = Student(
      id: maSV,
      fullName: hoTen,
      majorId: maNganh,
      address: diaChi,
      phoneNumber: soDT,
      avatarPath: finalAvatarPath,
    );

    if (isEditing) {
      await _studentRepo.updateStudent(sv);
    } else {
      // Khi thêm sinh viên mới, tự động tạo tài khoản với mật khẩu "123"
      final success = await _authRepo.createStudentWithAccount(sv, defaultPassword: '123');
      if (!success) {
        // Nếu tài khoản đã tồn tại, chỉ insert sinh viên
        await _studentRepo.insertStudent(sv);
      }
    }

    _pickedImage = null;
    _isLoading = false;
    await fetchStudents();
  }


  /// Mở Camera để chụp ảnh
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _pickedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi khi chụp ảnh: $e");
    }
  }

  /// Mở Thư viện để chọn ảnh
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh từ thư viện: $e");
    }
  }

  /// Mở Danh bạ để chọn SĐT
  /// Hàm này trả về SĐT, View sẽ nhận và gán vào TextField
  Future<String?> pickContactPhone() async {
    try {
      // Request permission trước
      if (await FlutterContacts.requestPermission()) {
        // Mở danh bạ để chọn contact
        Contact? contact = await FlutterContacts.openExternalPick();
        
        if (contact != null) {
          // openExternalPick() chỉ trả về contact với id và displayName
          // Cần fetch lại contact đầy đủ để lấy số điện thoại
          final fullContact = await FlutterContacts.getContact(contact.id);
          
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            // Trả về số điện thoại đầu tiên
            return fullContact.phones.first.number;
          }
        }
      } else {
        debugPrint('Quyền truy cập danh bạ bị từ chối');
      }
    } catch (e) {
      debugPrint('Lỗi khi chọn từ danh bạ: $e');
    }

    // Trả về null nếu không chọn hoặc bị từ chối quyền
    return null;
  }

  Future<Student?> getStudentById(String id) async {
    try {
      return await _studentRepo.getStudentById(id);
    } catch (e) {
      return null;
    }
  }
}