import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

LatLng generateRandomLocation({required LatLng center, required double maxDistance}) {
  final random = Random();
  final angle = random.nextDouble() * 2 * pi;
  final distance = random.nextDouble() * maxDistance;
  final dx = distance * cos(angle) / 111320;
  final dy = distance * sin(angle) / (111320 * cos(center.latitude * pi / 180));
  final newLat = center.latitude + dx;
  final newLng = center.longitude + dy;
  return LatLng(newLat, newLng);
}

List<Map<String, dynamic>> generateMockPickups(LatLng riderLocation) {
  final random = Random();
  return List.generate(5, (index) {
    return {
      "id": index + 1,
      "location": generateRandomLocation(center: riderLocation, maxDistance: 5000),
      "time_slot": "${9 + index}AM-${10 + index}AM",
      "inventory": 3 + random.nextInt(7),
    };
  });
}

double calculateDistance(LatLng a, LatLng b) {
  const earthRadius = 6371.0;
  final dLat = _deg2rad(b.latitude - a.latitude);
  final dLng = _deg2rad(b.longitude - a.longitude);
  final lat1 = _deg2rad(a.latitude);
  final lat2 = _deg2rad(b.latitude);
  final aVal = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
  return earthRadius * c;
}

double _deg2rad(double deg) => deg * (pi / 180);

// Test function to verify distance calculations
void testDistanceCalculations() {
  // Test case 1: Same location
  LatLng point1 = const LatLng(12.971598, 77.594566);
  LatLng point2 = const LatLng(12.971598, 77.594566);
  calculateDistance(point1, point2);
  // Test case 2: Different locations
  LatLng point3 = const LatLng(12.972819, 77.595212);
  calculateDistance(point1, point3);
  // Test case 3: Warehouse distance
  LatLng warehouse = const LatLng(12.961115, 77.600000);
  calculateDistance(point1, warehouse);
} 