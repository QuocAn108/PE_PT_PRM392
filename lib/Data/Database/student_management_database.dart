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
    print('Database path: $path');
    bool exists = await databaseExists(path);
    bool copied = false;

    if (!exists) {
      // Copy prebuilt database from assets
      ByteData data = await rootBundle.load('assets/$databaseName');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).create(recursive: true);
      await File(path).writeAsBytes(bytes, flush: true);
      copied = true;
    }

    // If we copied the prebuilt DB from assets, do not provide onCreate (tables already exist)
    if (copied) {
      return await openDatabase(
        path,
        version: databaseVersion,
        onUpgrade: onUpgrade,
      );
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
    // No-op: tables are provided by the prebuilt asset database. Avoid executing CREATE TABLE here
    // because it causes 'table ... already exists' errors when the asset DB is copied.
  }

  @override
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implement migration logic if you bump databaseVersion
  }
}
