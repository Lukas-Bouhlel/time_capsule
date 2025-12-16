import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/capsule_model.dart';
import '../services/api_service.dart';

class CapsuleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final String baseUrl = '${dotenv.env['API_URL'] ?? ''}/api/capsules';

  List<Capsule> _capsules = [];
  bool _isLoading = false;
  String? _error;

  List<Capsule> get capsules => _capsules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCapsules() async {
    _isLoading = true;
    notifyListeners();
    try {
      _capsules = await _apiService.fetchCapsules();
    } catch (e) {
      _error = "Erreur chargement: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCapsule({
    required String title,
    required String description,
    required File imageFile,
    required double lat,
    required double long,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.createCapsule(
        title: title,
        description: description,
        imageFile: imageFile,
        lat: lat,
        long: long,
      );

      await loadCapsules();
      
    } catch (e) {
      print("❌ Erreur Provider: $e");
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}