import '../Model/base_model.dart';

class Major extends BaseModel {
  final String id;
  final String name;

  Major({
    required this.id,
    required this.name,
  });

  // Compatibility getters
  String get maNganh => id;
  String get tenNganh => name;

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
