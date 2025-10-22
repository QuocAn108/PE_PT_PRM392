import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'base_database.dart';

class StudentManagementDatabase extends BaseDatabase {
  @override
  String get databaseName => 'StudentManagement.db';

  @override
  int get databaseVersion => 2;

  @override
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    print('Database path: $path');
    bool exists = await databaseExists(path);

    if (!exists) {
      // Copy prebuilt database from assets
      ByteData data = await rootBundle.load('assets/$databaseName');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).create(recursive: true);
      await File(path).writeAsBytes(bytes, flush: true);
      print('Database copied from assets');
    }

    return await openDatabase(
      path,
      version: databaseVersion,
      onUpgrade: onUpgrade,
    );
  }

  @override
  Future<void> onCreate(Database db, int version) async {
    print('Creating database tables...');

    // Create tables
    await db.execute('''
      CREATE TABLE Major (
        Id TEXT PRIMARY KEY,
        Name TEXT NOT NULL
      );
    ''');
    print('Major table created');

    await db.execute('''
      CREATE TABLE Student (
        Id TEXT PRIMARY KEY,
        FullName TEXT NOT NULL,
        Address TEXT,
        PhoneNumber TEXT,
        AvatarPath TEXT,
        MajorId TEXT,
        FOREIGN KEY (MajorId) REFERENCES Major(Id) ON DELETE SET NULL
      );
    ''');
    print('Student table created');

    await db.execute('''
      CREATE TABLE Account (
        Username TEXT PRIMARY KEY,
        Password TEXT NOT NULL,
        StudentId TEXT NOT NULL,
        Role TEXT NOT NULL DEFAULT 'student',
        FOREIGN KEY (StudentId) REFERENCES Student(Id) ON DELETE CASCADE
      );
    ''');
    print('Account table created');

    // Insert seed data
    print('Inserting seed data...');
    await db.execute("INSERT INTO Major (Id, Name) VALUES ('SE', 'Software Engineering');");
    await db.execute("INSERT INTO Major (Id, Name) VALUES ('GD', 'Graphic Design');");
    await db.execute("INSERT INTO Major (Id, Name) VALUES ('IB', 'International Business');");
    print('Majors inserted');

    await db.execute("INSERT INTO Student (Id, FullName, Address, PhoneNumber, AvatarPath, MajorId) VALUES ('SE181520', 'Hoàng Quốc An', '123 Võ Văn Ngân, Thủ Đức, TPHCM', '0909123456', NULL, 'SE');");
    await db.execute("INSERT INTO Student (Id, FullName, Address, PhoneNumber, AvatarPath, MajorId) VALUES ('SS11111', 'Đào Công An Phước', '456 Lê Văn Việt, Quận 9, TPHCM', '0987654321', NULL, 'SE');");
    await db.execute("INSERT INTO Student (Id, FullName, Address, PhoneNumber, AvatarPath, MajorId) VALUES ('GD170001', 'Trần Đình Thịnh', '789 Hoàng Diệu 2, Thủ Đức, TPHCM', '0912345678', NULL, 'GD');");
    await db.execute("INSERT INTO Student (Id, FullName, Address, PhoneNumber, AvatarPath, MajorId) VALUES ('ADMIN', 'Quản Trị Viên', NULL, NULL, NULL, NULL);");
    print('Students inserted');

    await db.execute("INSERT INTO Account (Username, Password, StudentId, Role) VALUES ('admin', '1', 'ADMIN', 'admin');");
    await db.execute("INSERT INTO Account (Username, Password, StudentId, Role) VALUES ('SE181520', '1', 'SE181520', 'student');");
    await db.execute("INSERT INTO Account (Username, Password, StudentId, Role) VALUES ('SS11111', '1', 'SS11111', 'student');");
    await db.execute("INSERT INTO Account (Username, Password, StudentId, Role) VALUES ('GD170001', '1', 'GD170001', 'student');");
    print('Accounts inserted');

    print('Database creation completed');
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop existing tables
      await db.execute('DROP TABLE IF EXISTS Account');
      await db.execute('DROP TABLE IF EXISTS Student');
      await db.execute('DROP TABLE IF EXISTS Major');

      // Recreate
      await onCreate(db, newVersion);
    }
  }
}
