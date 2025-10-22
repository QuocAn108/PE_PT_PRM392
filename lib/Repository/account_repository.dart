import 'package:student_management/Data/Database/account_dao.dart';
import 'package:student_management/Data/Database/student_dao.dart';
import 'package:student_management/Model/auth_user.dart';
import 'package:student_management/Model/student.dart';
import 'package:student_management/Model/account.dart';
import 'package:student_management/Model/user_role.dart';

class AuthRepository {
  final AccountDao _accountDao = AccountDao();
  final StudentDao _studentDao = StudentDao();

  /// Handle login logic
  /// Returns AuthUser (includes Student and Role) if login succeeds
  Future<AuthUser?> login(String username, String password) async {
    final account = await _accountDao.getById(username);
    if (account != null && account.password == password) {
      final student = await _studentDao.getById(account.studentId);
      if (student != null) {
        return AuthUser(
          student: student,
          role: account.role == 'admin' ? UserRole.admin : UserRole.student,
        );
      }
    }
    return null;
  }

  Future<bool> register(Student student, String password) async {
    final existingAccount = await _accountDao.getById(student.id!);
    if (existingAccount != null) {
      return false;
    }

    // Create account with default role = student
    Account newAccount = Account(
      username: student.id!,
      password: password,
      studentId: student.id!,
      role: 'student',
    );

    await _studentDao.insert(student);
    await _accountDao.insert(newAccount);

    return true;
  }

  Future<void> deleteAccount(String username) async {
    // Delete account first; cascade may delete student if configured
    await _accountDao.delete(username);
  }

  /// Get user info by studentId to refresh data
  Future<AuthUser?> getUserByStudentId(String studentId) async {
    final account = await _accountDao.getById(studentId);
    if (account != null) {
      final student = await _studentDao.getById(account.studentId);
      if (student != null) {
        return AuthUser(
          student: student,
          role: account.role == 'admin' ? UserRole.admin : UserRole.student,
        );
      }
    }
    return null;
  }

  /// Create a new student with an account using a default password
  /// Used when Admin creates a new student
  Future<bool> createStudentWithAccount(Student student, {String defaultPassword = '123'}) async {
    final existingAccount = await _accountDao.getById(student.id!);
    if (existingAccount != null) {
      return false; // Account already exists
    }

    // Create account with default role = student
    Account newAccount = Account(
      username: student.id!,
      password: defaultPassword,
      studentId: student.id!,
      role: 'student',
    );

    // Insert student first
    await _studentDao.insert(student);
    // Then insert account
    await _accountDao.insert(newAccount);

    return true;
  }

  /// Change password for the current user
  Future<bool> changePassword(String username, String oldPassword, String newPassword) async {
    // Check old password
    final account = await _accountDao.getById(username);
    if (account == null || account.password != oldPassword) {
      return false; // Old password incorrect
    }

    // Update with new password
    Account updatedAccount = Account(
      username: username,
      password: newPassword,
      studentId: account.studentId,
      role: account.role,
    );

    await _accountDao.update(updatedAccount, username);
    return true;
  }

  /// Check if a student is admin
  Future<bool> isStudentAdmin(String maSV) async {
    if (maSV.isEmpty) return false;
    try {
      final account = await _accountDao.getById(maSV);
      return account != null && account.role == 'admin';
    } catch (e) {
      return false;
    }
  }
}