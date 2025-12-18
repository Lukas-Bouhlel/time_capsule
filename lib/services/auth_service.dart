import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import '../services/api_service.dart';

HttpClient getHttpClient() {
  HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback = (cert, host, port) => true;
  return httpClient;
}

IOClient getIoClient() {
  return IOClient(getHttpClient());
}

class AuthService {
  static final ApiService _api = ApiService();

  static Future<bool> login(String email, String password) async {
    final response = await _api.request(
      'POST',
      '/api/auth/login',
      body: {'identifier': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', data['token']);
      print('bien connecté');
      return true;
    }
    return false;
  }

  static Future<bool> register(String email, String username, String password) async {
    final response = await _api.request(
      'POST',
      '/api/auth/signup',
      body: {
        'email': email,
        'username': username,
        'password': password
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('✅ Inscription réussie !');
      return true;
    } else {
      print('❌ Erreur Inscription: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = jsonDecode(
          ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
        );

        return decodedToken;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = jsonDecode(
          ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))),
        );

        if (decodedToken.containsKey('exp')) {
          int expirationTime = decodedToken['exp'];
          DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
            expirationTime * 1000,
          );

          if (expirationDate.isBefore(DateTime.now())) {
            return false;
          }

          return true;
        }
      } catch (e) {
        return false;
      }
    }

    return false;
  }
}
