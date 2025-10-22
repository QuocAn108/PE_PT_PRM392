import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../Model/major.dart';
import '../../Model/student.dart';
import '../../Repository/major_repository.dart';
import '../../Repository/student_repository.dart';
import '../../Repository/account_repository.dart';

class StudentViewmodel extends ChangeNotifier {
  final StudentRepository _studentRepo = StudentRepository();
  final MajorRepository _majorRepo = MajorRepository();
  final AuthRepository _authRepo = AuthRepository();
  final ImagePicker _picker = ImagePicker();

  List<Student> _students = [];
  List<Major> _majors = [];
  bool _isLoading = false;
  File? _pickedImage;

  List<Student> get students => _students;
  List<Major> get majors => _majors;
  bool get isLoading => _isLoading;
  File? get pickedImage => _pickedImage;

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchStudents(),
      fetchMajors(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStudents() async {
    try {
      _students = await _studentRepo.getAllStudents();
    } catch (e) {
      debugPrint("Error loading student list: $e");
    }
    notifyListeners();
  }

  Future<void> fetchMajors() async {
    try {
      _majors = await _majorRepo.getAllMajors();
    } catch (e) {
      debugPrint("Error loading majors: $e");
    }
    notifyListeners();
  }

  Future<void> deleteStudent(String maSV) async {
    await _studentRepo.deleteStudent(maSV);
    await fetchStudents();
  }

  // --- Major Management ---
  Future<void> addNganh(Major nganh) async {
    await _majorRepo.insertMajor(nganh);
    await fetchMajors();
  }

  Future<void> updateNganh(Major nganh) async {
    await _majorRepo.updateMajor(nganh);
    await fetchMajors();
  }

  Future<void> deleteNganh(String maNganh) async {
    try {
      // Clear major references in students first so no student points to a deleted major
      await _studentRepo.clearMajorReferences(maNganh);
    } catch (e) {
      debugPrint('Failed to clear major references from students: $e');
      // proceed to attempt delete anyway
    }

    await _majorRepo.deleteMajor(maNganh);
    // Refresh both students and majors so UI shows up-to-date data
    await fetchMajors();
    await fetchStudents();
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
        // Get application storage directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String avatarsDir = path.join(appDir.path, 'avatars');
        
        // Create avatars directory if not exists
        await Directory(avatarsDir).create(recursive: true);
        
        // Create new file name: {maSV}_{timestamp}.jpg
        final String fileName = '${maSV}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = path.join(avatarsDir, fileName);
        
        // Copy file from temp path to permanent storage
        await _pickedImage!.copy(newPath);
        finalAvatarPath = newPath;
        
        // Delete old avatar if exists (to avoid wasting storage)
        if (currentAvatarPath != null &&
            currentAvatarPath.isNotEmpty && 
            File(currentAvatarPath).existsSync()) {
          try {
            await File(currentAvatarPath).delete();
          } catch (e) {
            debugPrint('Failed to delete old avatar: $e');
          }
        }
      } catch (e) {
        debugPrint('Error saving avatar: $e');
        // On error, keep old path
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
      // When adding a new student, automatically create an account with password "123"
      final success = await _authRepo.createStudentWithAccount(sv, defaultPassword: '123');
      if (!success) {
        // If account already exists, just insert the student
        await _studentRepo.insertStudent(sv);
      }
    }

    _pickedImage = null;
    _isLoading = false;
    await fetchStudents();
  }


  /// Open camera to take a photo
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _pickedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  /// Open gallery to pick an image
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image from gallery: $e");
    }
  }

  /// Open contacts to pick a phone number
  /// This function returns the phone number; the View will assign it to a TextField
  Future<String?> pickContactPhone() async {
    try {
      // Request permission first
      if (await FlutterContacts.requestPermission()) {
        // Open contacts to pick a contact
        Contact? contact = await FlutterContacts.openExternalPick();
        
        if (contact != null) {
          // openExternalPick() only returns contact with id and displayName
          // Need to fetch full contact to get phone numbers
          final fullContact = await FlutterContacts.getContact(contact.id);
          
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            // Return the first phone number
            return fullContact.phones.first.number;
          }
        }
      } else {
        debugPrint('Contacts permission denied');
      }
    } catch (e) {
      debugPrint('Error selecting from contacts: $e');
    }

    // Return null if not selected or permission denied
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