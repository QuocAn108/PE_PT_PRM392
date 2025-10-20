import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'base_database.dart';

class StudentManagementDatabase extends BaseDatabase {
  @override
  String get databaseName => 'StudentManagement.db';

  @override
  int get databaseVersion => 1;

  @override
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);
    bool exists = await databaseExists(path);

    if (!exists) {
      // Copy prebuilt database from assets
      ByteData data = await rootBundle.load('assets/$databaseName');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).create(recursive: true);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  @override
  Future<void> onCreate(Database db, int version) async {
    // If you need to create tables dynamically when not using asset DB
    await db.execute('''
      CREATE TABLE Major (
        Id TEXT PRIMARY KEY NOT NULL,
        MajorName TEXT NOT NULL UNIQUE,
        Description TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Student (
        Id INTEGER PRIMARY KEY,
        FullName TEXT NOT NULL,
        MajorID TEXT NOT NULL,
        Address TEXT,
        PhoneNumber TEXT,
        AvatarURL TEXT,
        Latitude REAL,
        Longitude REAL,
        FOREIGN KEY(MajorID) REFERENCES Major(Id)
      );
    ''');

    await db.execute('''
      CREATE TABLE Account (
        AccountID INTEGER PRIMARY KEY,
        Username TEXT UNIQUE NOT NULL,
        PasswordHash TEXT NOT NULL,
        StudentID INTEGER UNIQUE NOT NULL,
        FOREIGN KEY(StudentID) REFERENCES Student(Id) ON DELETE CASCADE
      );
    ''');
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migration logic if you bump databaseVersion
  }
}
