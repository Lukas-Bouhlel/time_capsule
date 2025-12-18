import 'dart:io';
import 'package:flutter/material.dart';
import '../models/capsule_model.dart';
import '../services/capsule_service.dart';

class CapsuleProvider with ChangeNotifier {
  final CapsuleService _capsuleService = CapsuleService();

  List<Capsule> _capsules = [];
  bool _isLoading = false;
  String? _error;

  List<Capsule> get capsules => _capsules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCapsules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _capsules = await _capsuleService.fetchCapsules();
    } catch (e) {
      _error = "Impossible de charger les capsules : $e";
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
    _error = null;
    notifyListeners();

    try {
      await _capsuleService.createCapsule(
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