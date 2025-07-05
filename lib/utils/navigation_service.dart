import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/location_utils.dart';

class NavigationService {
  // Get optimized route with waypoints (simplified offline version)
  static Future<Map<String, dynamic>> getOptimizedRoute({
    required LatLng origin,
    required List<LatLng> waypoints,
    required LatLng destination,
  }) async {
    try {
      // Simple nearest neighbor algorithm for route optimization
      List<LatLng> optimizedWaypoints = _optimizeRoute(origin, waypoints, destination);
      
      // Calculate total distance and duration
      double totalDistance = 0.0;
      int totalDuration = 0;
      
      LatLng current = origin;
      for (var waypoint in optimizedWaypoints) {
        double distance = calculateDistance(current, waypoint);
        totalDistance += distance;
        totalDuration += (distance * 60).round(); // Rough estimate: 1km = 1 minute
        current = waypoint;
      }
      
      // Create simple polyline
      List<LatLng> polyline = [origin];
      polyline.addAll(optimizedWaypoints);
      polyline.add(destination);
      
      // Create detailed legs for turn-by-turn
      List<Map<String, dynamic>> legs = [];
      for (int i = 0; i < optimizedWaypoints.length; i++) {
        double legDistance = calculateDistance(i == 0 ? origin : optimizedWaypoints[i-1], optimizedWaypoints[i]);
        List<Map<String, dynamic>> steps = _generateDetailedSteps(
          i == 0 ? origin : optimizedWaypoints[i-1], 
          optimizedWaypoints[i], 
          'Pickup ${i + 1}',
          legDistance
        );
        
        legs.add({
          'distance': {'text': legDistance >= 1.0 ? '${legDistance.toStringAsFixed(1)} km' : '${(legDistance * 1000).round()} m'},
          'duration': {'text': '${(legDistance * 60).round()} min'},
          'steps': steps
        });
      }
      
      // Add final leg to warehouse
      double finalDistance = calculateDistance(optimizedWaypoints.isNotEmpty ? optimizedWaypoints.last : origin, destination);
      List<Map<String, dynamic>> finalSteps = _generateDetailedSteps(
        optimizedWaypoints.isNotEmpty ? optimizedWaypoints.last : origin, 
        destination, 
        'Warehouse',
        finalDistance
      );
      
      legs.add({
        'distance': {'text': finalDistance >= 1.0 ? '${finalDistance.toStringAsFixed(1)} km' : '${(finalDistance * 1000).round()} m'},
        'duration': {'text': '${(finalDistance * 60).round()} min'},
        'steps': finalSteps
      });
      
      return {
        'status': 'success',
        'polyline': polyline,
        'totalDistance': (totalDistance * 1000).round(),
        'totalDuration': totalDuration,
        'waypointOrder': List.generate(optimizedWaypoints.length, (i) => i),
        'legs': legs,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Exception: $e',
      };
    }
  }

  // Generate detailed turn-by-turn steps
  static List<Map<String, dynamic>> _generateDetailedSteps(LatLng from, LatLng to, String destination, double totalDistance) {
    List<Map<String, dynamic>> steps = [];
    
    // Calculate bearing to determine general direction
    double bearing = _calculateBearing(from, to);
    String direction = _getDirectionFromBearing(bearing);
    
    // Generate multiple steps for longer distances
    if (totalDistance > 0.5) { // If more than 500m
      // First step: Initial direction
      steps.add({
        'html_instructions': 'Head $direction on the road',
        'distance': {'text': '${(totalDistance * 500).round()} m'},
        'duration': {'text': '${(totalDistance * 30).round()} min'},
        'maneuver': 'straight'
      });
      
      // Middle step: Continue
      if (totalDistance > 1.0) {
        steps.add({
          'html_instructions': 'Continue $direction towards $destination',
          'distance': {'text': '${(totalDistance * 300).round()} m'},
          'duration': {'text': '${(totalDistance * 18).round()} min'},
          'maneuver': 'straight'
        });
      }
      
      // Final step: Arrive
      steps.add({
        'html_instructions': 'Arrive at $destination',
        'distance': {'text': '${(totalDistance * 200).round()} m'},
        'duration': {'text': '${(totalDistance * 12).round()} min'},
        'maneuver': 'straight'
      });
    } else {
      // Short distance: single step
      steps.add({
        'html_instructions': 'Continue $direction to $destination',
        'distance': {'text': '${(totalDistance * 1000).round()} m'},
        'duration': {'text': '${(totalDistance * 60).round()} min'},
        'maneuver': 'straight'
      });
    }
    
    return steps;
  }

  // Calculate bearing between two points
  static double _calculateBearing(LatLng from, LatLng to) {
    double lat1 = from.latitude * (3.14159 / 180);
    double lat2 = to.latitude * (3.14159 / 180);
    double dLon = (to.longitude - from.longitude) * (3.14159 / 180);
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    
    double bearing = atan2(y, x) * (180 / 3.14159);
    return (bearing + 360) % 360;
  }

  // Get direction string from bearing
  static String _getDirectionFromBearing(double bearing) {
    if (bearing >= 315 || bearing < 45) return 'north';
    if (bearing >= 45 && bearing < 135) return 'east';
    if (bearing >= 135 && bearing < 225) return 'south';
    if (bearing >= 225 && bearing < 315) return 'west';
    return 'north';
  }

  // Simple nearest neighbor algorithm for route optimization
  static List<LatLng> _optimizeRoute(LatLng origin, List<LatLng> waypoints, LatLng destination) {
    if (waypoints.isEmpty) return [];
    
    List<LatLng> optimized = [];
    List<LatLng> remaining = List.from(waypoints);
    LatLng current = origin;
    
    while (remaining.isNotEmpty) {
      // Find nearest waypoint
      int nearestIndex = 0;
      double nearestDistance = calculateDistance(current, remaining[0]);
      
      for (int i = 1; i < remaining.length; i++) {
        double distance = calculateDistance(current, remaining[i]);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestIndex = i;
        }
      }
      
      // Add nearest waypoint to optimized route
      optimized.add(remaining[nearestIndex]);
      current = remaining[nearestIndex];
      remaining.removeAt(nearestIndex);
    }
    
    return optimized;
  }

  // Get turn-by-turn directions
  static List<Map<String, dynamic>> getTurnByTurnDirections(List<dynamic> legs) {
    List<Map<String, dynamic>> directions = [];
    
    for (int i = 0; i < legs.length; i++) {
      final leg = legs[i];
      directions.add({
        'instruction': 'Continue to next destination',
        'distance': leg['distance']['text'],
        'duration': leg['duration']['text'],
        'maneuver': 'straight',
      });
    }
    
    return directions;
  }

  // Format duration from seconds to human readable
  static String formatDuration(int durationInSeconds) {
    if (durationInSeconds < 60) {
      return '${durationInSeconds}s';
    } else if (durationInSeconds < 3600) {
      return '${(durationInSeconds / 60).round()} min';
    } else {
      final hours = (durationInSeconds / 3600).floor();
      final minutes = ((durationInSeconds % 3600) / 60).round();
      return '${hours}h ${minutes}m';
    }
  }

  // Format distance from meters to human readable
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }
} 