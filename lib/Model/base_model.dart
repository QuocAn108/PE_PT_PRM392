abstract class BaseModel {
  BaseModel();

  Map<String, dynamic> toJson();

  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclasses');
  }
}
