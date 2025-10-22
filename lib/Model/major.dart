import '../Model/base_model.dart';

class Major extends BaseModel {
  final String id;
  final String name;

  Major({
    required this.id,
    required this.name,
  });

  // Compatibility getters
  String get majorId => id;
  String get majorName => name;

  @override
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
    };
  }

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: json['Id'].toString(),
      name: json['Name'],
    );
  }
}
