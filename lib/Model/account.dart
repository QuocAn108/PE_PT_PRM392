import 'package:student_management/Model/base_model.dart';

class Account extends BaseModel {
  final int accountID;
  final String username;
  final String passwordHash;
  final int studentID;

  Account({
    required this.accountID,
    required this.username,
    required this.passwordHash,
    required this.studentID,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'AccountID': accountID,
      'Username': username,
      'PasswordHash': passwordHash,
      'StudentID': studentID,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountID: json['AccountID'],
      username: json['Username'],
      passwordHash: json['PasswordHash'],
      studentID: json['StudentID'],
    );
  }
}

