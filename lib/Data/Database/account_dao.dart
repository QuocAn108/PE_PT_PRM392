import 'package:sqflite/sqflite.dart';
import 'package:student_management/Model/account.dart';
import 'package:student_management/Data/Database/base_dao.dart';
import 'package:student_management/Data/Database/student_management_database.dart';

class AccountDao extends BaseDao<Account, int> {
  final StudentManagementDatabase _database = StudentManagementDatabase();

  @override
  String get tableName => 'Account';

  @override
  String get primaryKey => 'AccountID';

  @override
  Future<Database> get database => _database.database;

  @override
  Account fromMap(Map<String, dynamic> map) {
    return Account.fromJson(map);
  }
}
