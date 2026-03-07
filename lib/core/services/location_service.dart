import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// ── Location Service ──
/// Handles GPS location tracking.
///
/// Dependencies (tambahkan di pubspec.yaml):
///   geolocator: ^13.0.2
///   geocoding: ^3.0.0
///
/// Android (AndroidManifest.xml):
///   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
///   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
///
/// iOS (Info.plist):
///   NSLocationWhenInUseUsageDescription
///   NSLocationAlwaysAndWhenInUseUsageDescription
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  double? latitude;
  double? longitude;
  String? currentAddress;

  final _locationController = StreamController<LocationData>.broadcast();
  Stream<LocationData> get locationStream => _locationController.stream;

  StreamSubscription? _positionSubscription;

  /// Minta permission dan ambil lokasi saat ini.
  Future<LocationData?> getCurrentLocation() async {
    try {
      // TODO: Uncomment setelah install geolocator + geocoding
      //
      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      //   if (permission == LocationPermission.denied) return null;
      // }
      // if (permission == LocationPermission.deniedForever) return null;
      //
      // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // if (!serviceEnabled) return null;
      //
      // Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
      // latitude = position.latitude;
      // longitude = position.longitude;

      // ── Dev placeholder (Bogor - sesuai PPT mockup) ──
      latitude = -6.5971;
      longitude = 106.8060;
      currentAddress = 'Cimanggu Permai, Bogor';

      final data = LocationData(
        latitude: latitude!,
        longitude: longitude!,
        address: currentAddress,
      );
      _locationController.add(data);
      return data;
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  /// Start live tracking (mode Pembagi / pedagang keliling).
  void startTracking() {
    debugPrint('Location tracking started');
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Hitung jarak Haversine (KM).
  static double calculateDistance(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * (pi / 180);

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
