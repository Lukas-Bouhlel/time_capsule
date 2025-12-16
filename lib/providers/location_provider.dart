import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _userPosition;
  bool _isLoading = true;

  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;

  LocationProvider() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _userPosition = position;
      _isLoading = false;
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