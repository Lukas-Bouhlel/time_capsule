import 'dart:convert';
import 'dart:io';
import '../models/capsule_model.dart';
import 'api_service.dart';

class CapsuleService {
  final ApiService _api = ApiService();

  Future<List<Capsule>> fetchCapsules() async {
    final response = await _api.request('GET', '/api/capsules');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Capsule.fromJson(item)).toList();
    } else {
      throw Exception('Erreur chargement capsules: ${response.statusCode}');
    }
  }

  Future<void> createCapsule({
    required String title,
    required String description,
    required File imageFile,
    required double lat,
    required double long,
  }) async {
    final Map<String, dynamic> fields = {
      'title': title,
      'description': description,
      'latitude': lat,
      'longitude': long,
    };

    final response = await _api.request(
      'POST', 
      '/api/capsules',
      body: fields,
      isMultipart: true,
      imageFile: imageFile,
      imageFieldName: 'image'
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("✅ Capsule créée avec succès !");
    } else {
      throw Exception('Erreur création: ${response.statusCode} - ${response.body}');
    }
  }
}