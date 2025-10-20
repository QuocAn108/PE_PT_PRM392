import '../Model/base_model.dart';

class Student extends BaseModel {
  final int? id;
  final String fullName;
  final String majorID;
  final String? address;
  final String? phoneNumber;
  final String? avatarURL;
  final double? latitude;
  final double? longitude;

  Student({
    this.id,
    required this.fullName,
    required this.majorID,
    this.address,
    this.phoneNumber,
    this.avatarURL,
    this.latitude,
    this.longitude,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'FullName': fullName,
      'MajorID': majorID,
    };
    if (id != null) map['Id'] = id;
    if (address != null) map['Address'] = address;
    if (phoneNumber != null) map['PhoneNumber'] = phoneNumber;
    if (avatarURL != null) map['AvatarURL'] = avatarURL;
    if (latitude != null) map['Latitude'] = latitude;
    if (longitude != null) map['Longitude'] = longitude;
    return map;
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['Id'],
      fullName: json['FullName'],
      majorID: json['MajorID'],
      address: json['Address'],
      phoneNumber: json['PhoneNumber'],
      avatarURL: json['AvatarURL'],
      latitude: (json['Latitude'] is num) ? (json['Latitude'] as num).toDouble() : null,
      longitude: (json['Longitude'] is num) ? (json['Longitude'] as num).toDouble() : null,
    );
  }
}
