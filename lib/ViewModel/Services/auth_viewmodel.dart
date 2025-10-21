import 'package:flutter/material.dart';

import '../../Model/auth_user.dart';
import '../../Model/student.dart';
import '../../Model/user_role.dart';
import '../../Repository/account_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  AuthUser? _loggedInUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get loggedInUser => _loggedInUser;
  Student? get currentSinhvien => _loggedInUser?.student;
  UserRole? get currentRole => _loggedInUser?.role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _loggedInUser != null;
  bool get isAdmin => _loggedInUser?.isAdmin ?? false;


  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        _loggedInUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Sai tên đăng nhập hoặc mật khẩu";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Student sv, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.register(sv, password);
      if (success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Tên đăng nhập (MaSV) đã tồn tại";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _loggedInUser = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_loggedInUser != null) {
      _isLoading = true;
      notifyListeners();

      await _authRepository.deleteAccount(_loggedInUser!.student.id!);
      _loggedInUser = null;

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới thông tin user hiện tại sau khi cập nhật
  Future<void> refreshCurrentUser() async {
    if (_loggedInUser != null) {
      try {
        final refreshedUser = await _authRepository.getUserByStudentId(_loggedInUser!.student.id!);
        if (refreshedUser != null) {
          _loggedInUser = refreshedUser;
          notifyListeners();
        }
      } catch (e) {
        print('Error refreshing user: $e');
      }
    }
  }

  /// Kiểm tra xem user hiện tại có quyền edit sinh viên này không
  bool canEditStudent(String maSV) {
    if (_loggedInUser == null) return false;
    // Admin có thể sửa tất cả
    if (_loggedInUser!.isAdmin) return true;
    // Sinh viên chỉ được sửa chính mình
    return _loggedInUser!.student.id == maSV;
  }

  /// Kiểm tra xem user hiện tại có quyền xóa sinh viên này không
  /// CHỈ ADMIN mới có quyền xóa
  bool canDeleteStudent(String maSV) {
    if (_loggedInUser == null) return false;
    // Chỉ Admin mới được xóa
    return _loggedInUser!.isAdmin;
  }

  /// Đổi mật khẩu cho user hiện tại
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_loggedInUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.changePassword(
        _loggedInUser!.student.id!,
        oldPassword,
        newPassword,
      );

      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = "Mật khẩu cũ không đúng";
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = "Đã xảy ra lỗi: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}