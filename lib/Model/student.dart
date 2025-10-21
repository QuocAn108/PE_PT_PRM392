import '../Model/base_model.dart';

class Student extends BaseModel {
  final String? id;
  final String fullName;
  final String? majorId;
  final String? address;
  final String? phoneNumber;
  final String? avatarPath;

  Student({
    this.id,
    required this.fullName,
    this.majorId,
    this.address,
    this.phoneNumber,
    this.avatarPath,
  });

  // Compatibility getters
  String? get maSV => id;
  String get hoTen => fullName;
  String? get diaChi => address;
  String? get soDT => phoneNumber;
  String? get maNganh => majorId;

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'FullName': fullName,
    };
    if (id != null) map['Id'] = id;
    if (address != null) map['Address'] = address;
    if (phoneNumber != null) map['PhoneNumber'] = phoneNumber;
    if (avatarPath != null) map['AvatarPath'] = avatarPath;
    if (majorId != null) map['MajorId'] = majorId;
    return map;
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['Id'] == null ? null : json['Id'].toString(),
      fullName: json['FullName'],
      majorId: json['MajorId'],
      address: json['Address'],
      phoneNumber: json['PhoneNumber'],
      avatarPath: json['AvatarPath'],
    );
  }
}
