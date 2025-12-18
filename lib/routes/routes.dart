import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/create_capsule_page.dart';

Widget getPageForRoute(BuildContext context, String route,
    {dynamic arguments,
    required void Function(String route, {dynamic arguments}) onNavigate}) {

  switch (route) {
    case '/dashboard':
      return HomePage(
        onNavigate: onNavigate, 
      );
      
    case '/create':
      return CreateCapsulePage(
        // onNavigate: onNavigate,
        // arguments: arguments,
      );

    default:
      // En cas de route inconnue, on renvoie vers le dashboard
      return HomePage();
  }
}