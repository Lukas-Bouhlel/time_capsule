import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class RouteManager {
  static const String home = '/';
  static const String map = '/map';
  static const String create = '/create';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
    };
  }
}