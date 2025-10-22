import 'package:student_management/Model/student.dart';
import 'user_role.dart';

class AuthUser {
  final Student student;
  final UserRole role;

  AuthUser({
    required this.student,
    required this.role,
  });

  // Các getter tiện dụng
  String? get studentId => student.id;
  String get fullName => student.fullName;
  String? get avatarPath => student.avatarPath;

  // Check role
  bool get isAdmin => role == UserRole.admin;
  bool get isStudent => role == UserRole.student;
}

