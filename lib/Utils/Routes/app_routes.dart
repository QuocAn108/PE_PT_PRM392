import 'package:flutter/material.dart';
import 'package:student_management/View/home_view.dart';
import 'package:student_management/View/login_view.dart';
import 'package:student_management/View/student_management_view.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String studentManage = '/students';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginView(),
      home: (context) => const HomeView(),
      studentManage: (context) => const StudentManagementView(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case studentManage:
        return MaterialPageRoute(builder: (_) => const StudentManagementView());
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
