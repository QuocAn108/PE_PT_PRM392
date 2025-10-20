import 'package:flutter/material.dart';
import '../../View/home_view.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeView(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
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
