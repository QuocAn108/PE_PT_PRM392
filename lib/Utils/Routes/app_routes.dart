import 'package:flutter/material.dart';
import 'package:student_management/View/auth_wrapper.dart';
import 'package:student_management/View/login_view.dart';
import 'package:student_management/View/student_list_view.dart';
import 'package:student_management/View/major_management_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String studentManage = '/students';
  static const String majorManage = '/majors';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      home: (context) => const AuthWrapper(),
      studentManage: (context) => const StudentListView(),
      majorManage: (context) => const MajorManagementView(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case home:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case studentManage:
        return MaterialPageRoute(builder: (_) => const StudentListView());
      case majorManage:
        return MaterialPageRoute(builder: (_) => const MajorManagementView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
