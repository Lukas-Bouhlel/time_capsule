import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/create_capsule_page.dart';

class RouteManager {
  static const String home = '/';
  static const String create = '/create';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      create: (context) => const CreateCapsulePage(),
    };
  }
}