enum UserRole {
  admin,
  student;

  // Chuyển từ String -> Enum
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student; // Default là sinh viên
    }
  }

  // Chuyển từ Enum -> String (để lưu vào DB)
  String toDbString() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.student:
        return 'student';
    }
  }

  // Hiển thị tên tiếng Việt
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Quản Trị Viên';
      case UserRole.student:
        return 'Sinh Viên';
    }
  }
}

