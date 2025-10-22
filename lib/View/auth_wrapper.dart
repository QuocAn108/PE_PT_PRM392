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
    // Dùng Consumer để lắng nghe trạng thái đăng nhập
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        if (authViewModel.isLoggedIn) {
          // Nếu là admin, vào màn hình danh sách sinh viên
          if (authViewModel.currentRole == UserRole.admin) {
            return const StudentListView();
          } else {
            // Nếu là sinh viên, vào màn hình chi tiết của chính mình
            return StudentDetailView(student: authViewModel.currentSinhvien);
          }
        } else {
          // Nếu chưa, hiển thị màn hình đăng nhập
          return const LoginView();
        }
      },
    );
  }
}