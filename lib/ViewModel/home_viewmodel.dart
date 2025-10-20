import 'package:flutter/material.dart';
import '../Model/student.dart';
import '../ViewModel/base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  List<Student> _students = [];

  List<Student> get students => _students;

  @override
  void init() {
    super.init();
    _loadMockData();
  }

  void _loadMockData() {
    _students = [
      Student(id: 1, name: 'Nguyen Van A', email: 'a@example.com', phone: '0123456789'),
      Student(id: 2, name: 'Tran Thi B', email: 'b@example.com', phone: '0987654321'),
      Student(id: 3, name: 'Le Van C', email: 'c@example.com', phone: '0111111111'),
      Student(id: 4, name: 'Pham Thi D', email: 'd@example.com', phone: '0222222222'),
      Student(id: 5, name: 'Hoang Van E', email: 'e@example.com', phone: '0333333333'),
    ];
    notifyListeners();
  }

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void removeStudent(int id) {
    _students.removeWhere((student) => student.id == id);
    notifyListeners();
  }
}
