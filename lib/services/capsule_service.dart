import 'dart:convert';
import 'dart:io';
import '../models/capsule_model.dart';
import 'api_service.dart';

class CapsuleService {
  // On instancie le moteur
  final ApiService _api = ApiService();

  // Récupérer les capsules
  Future<List<Capsule>> fetchCapsules() async {
    // On appelle juste '/api/capsules', l'ApiService gère l'URL complète et le token
    final response = await _api.request('GET', '/api/capsules');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Capsule.fromJson(item)).toList();
    } else {
      throw Exception('Erreur chargement capsules: ${response.statusCode}');
    }
  }

  // Créer une capsule (avec image)
  Future<void> createCapsule({
    required String title,
    required String description,
    required File imageFile,
    required double lat,
    required double long,
  }) async {
    // On prépare les données textes
    final Map<String, dynamic> fields = {
      'title': title,
      'description': description,
      'latitude': lat,
      'longitude': long,
    };

    // On utilise le mode Multipart de l'ApiService
    final response = await _api.request(
      'POST', 
      '/api/capsules',
      body: fields,        // Les textes
      isMultipart: true,   // Active le mode fichier
      imageFile: imageFile, // Le fichier
      imageFieldName: 'image' // Le nom du champ attendu par ton backend (NestJS/Node)
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("✅ Capsule créée avec succès !");
    } else {
      throw Exception('Erreur création: ${response.statusCode} - ${response.body}');
    }
  }
}