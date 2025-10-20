import '../Model/base_model.dart';

class Student extends BaseModel {
  final int id;
  final String name;
  final String email;
  final String phone;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
