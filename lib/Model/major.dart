import '../Model/base_model.dart';

class Major extends BaseModel {
  final String id;
  final String majorName;
  final String? description;

  Major({
    required this.id,
    required this.majorName,
    this.description,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'MajorName': majorName,
      'Description': description,
    };
  }

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: json['Id'],
      majorName: json['MajorName'],
      description: json['Description'],
    );
  }
}
