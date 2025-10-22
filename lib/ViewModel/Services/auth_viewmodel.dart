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
        // Check login permission: only admin can log in
        if (user.role == UserRole.student) {
          _errorMessage = "No login permission";
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _loggedInUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Invalid username or password";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
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
        _errorMessage = "Username (MaSV) already exists";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
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

  /// Refresh current user info after update
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

  /// Check if the current user can edit this student
  bool canEditStudent(String maSV) {
    if (_loggedInUser == null) return false;
    // Admin can edit all
    if (_loggedInUser!.isAdmin) return true;
    // Student can only edit themselves
    return _loggedInUser!.student.id == maSV;
  }

  /// Check if current user can delete this student
  /// ONLY ADMIN can delete
  bool canDeleteStudent(String maSV) {
    if (_loggedInUser == null) return false;
    // Only Admin can delete
    return _loggedInUser!.isAdmin;
  }

  /// Change password for current user
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
        _errorMessage = "Old password is incorrect";
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check if a student is admin
  Future<bool> isStudentAdmin(String maSV) async {
    return await _authRepository.isStudentAdmin(maSV);
  }
}