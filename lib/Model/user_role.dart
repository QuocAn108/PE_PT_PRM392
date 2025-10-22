enum UserRole {
  admin,
  student;

  // Convert from String -> Enum
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student; // Default is student
    }
  }

  // Convert from Enum -> String (to store in DB)
  String toDbString() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.student:
        return 'student';
    }
  }

  // Display name in English
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.student:
        return 'Student';
    }
  }
}
