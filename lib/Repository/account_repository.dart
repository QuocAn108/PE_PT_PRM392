import 'package:student_management/Data/Database/account_dao.dart';
import 'package:student_management/Data/Database/student_dao.dart';
import 'package:student_management/Model/auth_user.dart';
import 'package:student_management/Model/student.dart';
import 'package:student_management/Model/account.dart';
import 'package:student_management/Model/user_role.dart';

class AuthRepository {
  final AccountDao _accountDao = AccountDao();
  final StudentDao _studentDao = StudentDao();

  /// Xử lý logic Đăng nhập
  /// Trả về thông tin AuthUser (bao gồm Student và Role) nếu đăng nhập thành công
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

    // Tạo tài khoản với role mặc định là student
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
    // Xóa account trước, do cascade sẽ xóa student nếu cần
    await _accountDao.delete(username);
  }

  /// Lấy thông tin user theo studentId để refresh data
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

  /// Tạo sinh viên mới kèm tài khoản với mật khẩu mặc định
  /// Được sử dụng khi Admin tạo sinh viên mới
  Future<bool> createStudentWithAccount(Student student, {String defaultPassword = '123'}) async {
    final existingAccount = await _accountDao.getById(student.id!);
    if (existingAccount != null) {
      return false; // Tài khoản đã tồn tại
    }

    // Tạo tài khoản với role mặc định là student
    Account newAccount = Account(
      username: student.id!,
      password: defaultPassword,
      studentId: student.id!,
      role: 'student',
    );

    // Insert student trước
    await _studentDao.insert(student);
    // Sau đó insert account
    await _accountDao.insert(newAccount);

    return true;
  }

  /// Đổi mật khẩu cho user hiện tại
  Future<bool> changePassword(String username, String oldPassword, String newPassword) async {
    // Kiểm tra mật khẩu cũ
    final account = await _accountDao.getById(username);
    if (account == null || account.password != oldPassword) {
      return false; // Mật khẩu cũ không đúng
    }

    // Cập nhật mật khẩu mới
    Account updatedAccount = Account(
      username: username,
      password: newPassword,
      studentId: account.studentId,
      role: account.role,
    );

    await _accountDao.update(updatedAccount, username);
    return true;
  }

  /// Kiểm tra xem sinh viên có phải admin không
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