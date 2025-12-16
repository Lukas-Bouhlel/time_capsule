import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/capsule_model.dart';

class ApiService {
  final String baseUrl = '${dotenv.env['API_URL'] ?? ''}/api/capsules';

  Future<List<Capsule>> fetchCapsules() async {
    final url = Uri.parse(baseUrl); 
    print('📞 Appel GET vers : $url');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Capsule.fromJson(item)).toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur API: $e');
      rethrow;
    }
  }

   Future<void> createCapsule({
    required String title,
    required String description,
    required File imageFile,
    required double lat,
    required double long,
  }) async {
    final url = Uri.parse(baseUrl);
    print('📤 Envoi POST vers : $url');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = long.toString();

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print("✅ Capsule créée API succès");
      } else {
        throw Exception('Erreur upload API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("❌ Erreur API Upload: $e");
      rethrow;
    }
  }
}