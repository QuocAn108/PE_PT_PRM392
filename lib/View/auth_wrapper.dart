import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/Services/auth_viewmodel.dart';
import 'login_view.dart';
import 'student_list_view.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để lắng nghe trạng thái đăng nhập
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoggedIn) {
          // Nếu đã đăng nhập, vào màn hình chính
          return const StudentListView();
        } else {
          // Nếu chưa, hiển thị màn hình đăng nhập
          return const LoginView();
        }
      },
    );
  }
}