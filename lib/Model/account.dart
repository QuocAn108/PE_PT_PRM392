import 'package:student_management/Model/base_model.dart';

class Account extends BaseModel {
  final int accountID;
  final String username;
  final String passwordHash;
  final int studentID;
  final String? role; // new column: Role TEXT

  Account({
    required this.accountID,
    required this.username,
    required this.passwordHash,
    required this.studentID,
    this.role,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'AccountID': accountID,
      'Username': username,
      'PasswordHash': passwordHash,
      'StudentID': studentID,
    };
    if (role != null) map['Role'] = role;
    return map;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountID: json['AccountID'],
      username: json['Username'],
      passwordHash: json['PasswordHash'],
      studentID: json['StudentID'],
      role: json['Role'],
    );
  }
}
