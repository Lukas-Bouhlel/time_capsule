import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  int? id;
  String? username;
  String? email;
  bool isInitialized = false;

  Future<void> loadUserData() async {
    try {
      var userData = await AuthService.getUserData();
      print("🔍 Debug UserData: $userData");

      if (userData != null) {
        id = userData['id'];
        username = userData['username'];
        email = userData['email'];
        notifyListeners();
      }
    } catch (e) {
      print("Erreur UserProvider: $e");
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  void clearUser() {
    username = null;
    email = null;
    notifyListeners();
  }
}
