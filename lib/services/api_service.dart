import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

HttpClient getHttpClient() {
  HttpClient httpClient = HttpClient();
  httpClient.badCertificateCallback = (cert, host, port) => true;
  return httpClient;
}

IOClient getIoClient() {
  return IOClient(getHttpClient());
}

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? ''; 
  final IOClient client = getIoClient();

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<http.Response> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool isMultipart = false,
    File? imageFile,
    String? imageFieldName,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    
    final token = await _getToken();
    
    Map<String, String> headers = {};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (isMultipart && imageFile != null) {
      print('📤 [API] Envoi MULTIPART vers : $uri');
      
      var request = http.MultipartRequest(method, uri);
      
      request.headers.addAll(headers);
      
      print("🛑 STOP ! VERIFICATION DU TOKEN : ${request.headers['Authorization']}");
      
      body?.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      request.files.add(await http.MultipartFile.fromPath(
        imageFieldName ?? 'image',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    }

    print('📞 [API] Appel $method vers : $uri');
    
    headers['Content-Type'] = 'application/json';

    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: headers);
          break;
        case 'POST':
          response = await client.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await client.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Méthode HTTP non supportée');
      }
      return response;
    } catch (e) {
      print('❌ [API] Erreur technique : $e');
      rethrow;
    }
  }
}