import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/Services/auth_viewmodel.dart';
import '../Model/user_role.dart';
import 'login_view.dart';
import 'student_list_view.dart';
import 'student_detail_view.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for login state
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoggedIn) {
          // If admin, show student list screen
          if (authViewModel.currentRole == UserRole.admin) {
            return const StudentListView();
          } else {
            // If student, show their own detail screen
            return StudentDetailView(student: authViewModel.currentSinhvien);
          }
        } else {
          // If not logged in, show the login screen
          return const LoginView();
        }
      },
    );
  }
}