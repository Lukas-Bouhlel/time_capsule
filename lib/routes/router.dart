import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/login_page.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../screens/main_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<bool>(
          future: AuthService.isAuthenticated(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData && snapshot.data == true) {
              return Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (!userProvider.isInitialized) {
                    Future.microtask(() => userProvider.loadUserData());
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return MainScreen(
                    initialRoute: settings.name,
                    arguments: settings.arguments,
                  );
                },
              );
            }
            return LoginPage();
          },
        );
      },
    );
  }
}
