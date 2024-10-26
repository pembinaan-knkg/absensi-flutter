import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class TargetLocation {
  final double latitude; // Target location latitude
  final double longitude; // Target location longitude
  final double radiusInMeter;

  TargetLocation({
    required this.latitude,
    required this.longitude,
    required this.radiusInMeter,
  });
}

class LocationServices extends Listenable {
  Position? _currentLocation;
  Position? get currentLocation => _currentLocation;
  bool _inRadius = false;
  bool get inRadius => _inRadius;

  Future init() async {
    if (await initPermission()) {
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      ).listen((event) {
        _currentLocation = event;
        _inRadius = isInRadius();
        debugPrint('inRadius $inRadius');
      }).onError((error) {
        debugPrint(error.toString());
      });
    }
  }

  Future<bool> initPermission() async {
    if (await Permission.ignoreBatteryOptimizations.status !=
        PermissionStatus.granted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.deniedForever) {
      return Future.error(LocationPermission.deniedForever);
    }
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    if (status == LocationPermission.denied) {
      await Geolocator.openAppSettings();
    }
    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
      return true;
    }
    return false;
  }

  Future<void> refreshLocation() async {
    _currentLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 6),
    );
    for (var listener in _listener) {
      listener();
    }
  }

  bool isInRadius() {
    TargetLocation target = TargetLocation(
      latitude: 0.5768536590137682,
      longitude: 123.06104024942378,
      
      radiusInMeter: 50,
    );
    assert(_currentLocation != null, "location is not avaible");
    double distanceInMeters = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      target.latitude,
      target.longitude,
    );
    _inRadius = distanceInMeters <= target.radiusInMeter;
    return _inRadius;
  }

  void reset() {
    _currentLocation = null;
  }

  final List<VoidCallback> _listener = [];
  List<VoidCallback> get listener => _listener;

  @override
  void addListener(void Function() listener) {
    _listener.add(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _listener.remove(listener);
  }
}
