import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  HttpClient getHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    return httpClient;
  }

  Future<http.Response> request(String method, String endpoint,
      {Map<String, dynamic>? body,
      bool isMultipart = false,
      File? imageFile,
      String? imageFieldName}) async {
    
    final uri = Uri.parse('$baseUrl$endpoint');
    final ioClient = IOClient(getHttpClient());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print("🔑 Token ajouté à la requête : ${token.substring(0, 10)}...");
    }

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    print('📞 [API] $method vers : $uri');

    try {
      http.Response response;

      if (isMultipart && imageFile != null) {
        var request = http.MultipartRequest(method, uri);
        request.headers.addAll(headers);
        
        if (body != null) {
          body.forEach((key, value) {
            request.fields[key] = value.toString();
          });
        }
        
        request.files.add(await http.MultipartFile.fromPath(
          imageFieldName ?? 'image',
          imageFile.path,
        ));

        var streamedResponse = await ioClient.send(request);
        response = await http.Response.fromStream(streamedResponse);
      } 

      else {
        switch (method) {
          case 'POST':
            response = await ioClient.post(uri, headers: headers, body: jsonEncode(body));
            break;
          case 'PUT':
            response = await ioClient.put(uri, headers: headers, body: jsonEncode(body));
            break;
          case 'DELETE':
            response = await ioClient.delete(uri, headers: headers);
            break;
          case 'GET':
          default:
            response = await ioClient.get(uri, headers: headers);
            break;
        }
      }
      
      print('✅ [API] Réponse : ${response.statusCode}');
      return response;

    } catch (e) {
      print('❌ [API] Erreur : $e');
      throw Exception('Erreur connexion serveur');
    }
  }
}