import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/location_utils.dart';
import 'dart:async';

class NavigationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> pickups;
  final LatLng warehouseLocation;
  final LatLng startLocation;

  const NavigationScreen({
    super.key,
    required this.pickups,
    required this.warehouseLocation,
    required this.startLocation,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  Position? _currentPosition;
  List<LatLng> _routePolyline = [];
  List<Map<String, dynamic>> _directions = [];
  int _currentStepIndex = 0;
  bool _isLoading = true;
  Timer? _locationTimer;
  String _totalDistance = '';
  String _totalTime = '';

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });

      _createSimpleRoute();
      _startLocationTracking();
    } catch (e) {
      _createFallbackRoute();
    }
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _currentPosition = position;
        });

        _updateCurrentStep();
      } catch (e) {
        // ignore: empty_catches
      }
    });
  }

  void _updateCurrentStep() {
    if (_currentPosition == null || _directions.isEmpty) return;

    if (_currentStepIndex < _directions.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    }
  }

  List<LatLng> _createSimpleRoute() {
    List<LatLng> routePoints = [];
    if (_currentPosition != null) {
      routePoints.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }
    for (var pickup in widget.pickups) {
      routePoints.add(pickup['location'] as LatLng);
    }
    routePoints.add(widget.warehouseLocation);
    
    double totalDistance = _calculateTotalDistance();
    
    setState(() {
      _routePolyline = routePoints;
      _totalDistance = '${totalDistance.toStringAsFixed(1)} km';
      _totalTime = '~${(totalDistance * 2).round()} min';
      _directions = _createSimpleDirections();
      _isLoading = false;
    });
    
    return routePoints;
  }

  List<Map<String, dynamic>> _createSimpleDirections() {
    List<Map<String, dynamic>> directions = [];
    
    for (int i = 0; i < widget.pickups.length; i++) {
      directions.add({
        'instruction': 'Head to Pickup ${widget.pickups[i]['id']}',
        'distance': '${_calculateLegDistance(i).toStringAsFixed(1)} km',
        'duration': '~${(_calculateLegDistance(i) * 2).round()} min',
      });
    }
      
    directions.add({
      'instruction': 'Head to Warehouse',
      'distance': '${_calculateLegDistance(widget.pickups.length).toStringAsFixed(1)} km',
      'duration': '~${(_calculateLegDistance(widget.pickups.length) * 2).round()} min',
    });
    
    return directions;
  }

  double _calculateLegDistance(int legIndex) {
    if (_currentPosition == null) return 0.0;
    
    LatLng start;
    LatLng end;
    
    if (legIndex == 0) {
      start = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      end = widget.pickups[0]['location'] as LatLng;
    } else if (legIndex < widget.pickups.length) {
      start = widget.pickups[legIndex - 1]['location'] as LatLng;
      end = widget.pickups[legIndex]['location'] as LatLng;
    } else {
      start = widget.pickups[widget.pickups.length - 1]['location'] as LatLng;
      end = widget.warehouseLocation;
    }
    
    return calculateDistance(start, end);
  }

  double _calculateTotalDistance() {
    if (_currentPosition == null) return 0.0;
    double total = 0.0;
    LatLng prev = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    
    for (var pickup in widget.pickups) {
      LatLng pickupLocation = pickup['location'] as LatLng;
      total += calculateDistance(prev, pickupLocation);
      prev = pickupLocation;
    }
    
    total += calculateDistance(prev, widget.warehouseLocation);
    return total;
  }

  void _createFallbackRoute() {
    setState(() {
      _routePolyline = _createSimpleRoute();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard('Total Distance', _totalDistance, Icons.directions_car),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard('Total Time', _totalTime, Icons.access_time),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard('Steps', '${_directions.length}', Icons.list),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition != null 
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : widget.startLocation,
                          zoom: 15.0,
                        ),
                        markers: _createMarkers(),
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId('navigation_route'),
                            points: _routePolyline,
                            color: Colors.blue,
                            width: 5,
                          ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  ),
                ),
                
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Navigation Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _directions.length,
                          itemBuilder: (context, index) {
                            final direction = _directions[index];
                            final isCurrentStep = index == _currentStepIndex;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrentStep ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: isCurrentStep 
                                    ? Border.all(color: Colors.blue.withValues(alpha: 0.3))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCurrentStep ? Icons.navigation : Icons.location_on,
                                    color: isCurrentStep ? Colors.blue : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          direction['instruction'],
                                          style: TextStyle(
                                            fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
                                            color: isCurrentStep ? Colors.blue : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '${direction['distance']} • ${direction['duration']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};
    
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    for (var pickup in widget.pickups) {
      markers.add(
        Marker(
          markerId: MarkerId('pickup_${pickup['id']}'),
          position: pickup['location'],
          infoWindow: InfoWindow(
            title: 'Pickup ${pickup['id']}',
            snippet: '${pickup['time_slot']} - ${pickup['inventory']} items',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    
    markers.add(
      Marker(
        markerId: const MarkerId('warehouse'),
        position: widget.warehouseLocation,
        infoWindow: const InfoWindow(
          title: 'Warehouse',
          snippet: 'Final destination',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    
    return markers;
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 