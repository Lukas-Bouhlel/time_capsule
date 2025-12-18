import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _userPosition;
  bool _isLoading = true;
  String? error;

  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;

  Future<void> getUserLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Le GPS est désactivé.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission GPS refusée.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permission GPS refusée définitivement.');
      }

      _userPosition = await Geolocator.getCurrentPosition();
      
      _startLocationStream();

    } catch (e) {
      error = e.toString();
      print("❌ Erreur GPS : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startLocationStream() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _userPosition = position;
      notifyListeners();
    });
  }

  double getDistanceFromUser(double targetLat, double targetLong) {
    if (_userPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      targetLat,
      targetLong,
    );
  }
}