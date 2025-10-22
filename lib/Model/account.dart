import '../Model/base_model.dart';

class Account extends BaseModel {
  final String username;
  final String password;
  final String studentId;
  final String role;

  Account({
    required this.username,
    required this.password,
    required this.studentId,
    this.role = 'student',
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Password': password,
      'StudentId': studentId,
      'Role': role,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      username: json['Username'].toString(),
      password: json['Password'],
      studentId: json['StudentId'].toString(),
      role: json['Role'] ?? 'student',
    );
  }
}
