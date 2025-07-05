import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';
import 'navigation_screen.dart';

class RiderMapScreen extends StatefulWidget {
  const RiderMapScreen({super.key});

  @override
  State<RiderMapScreen> createState() => _RiderMapScreenState();
}

class _RiderMapScreenState extends State<RiderMapScreen> {
  LatLng? _currentPosition;
  final LatLng warehouseLocation = const LatLng(12.961115, 77.600000);
  late List<Map<String, dynamic>> pickups;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _totalDistance = '';
  String _totalTime = '';
  bool _isLoading = true;
  String _locationStatus = 'Getting your location...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _locationStatus = 'Checking permissions...';
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Location services disabled';
          _isLoading = false;
        });
        _useFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Location permission denied';
            _isLoading = false;
          });
          _useFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permissions permanently denied';
          _isLoading = false;
        });
        _useFallbackLocation();
        return;
      }

      setState(() {
        _locationStatus = 'Getting your exact location...';
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _locationStatus = 'Location found: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _isLoading = false;
      });

      _generateMockPickups();
      _createMarkers();
      _createSimpleRoute();

    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
        _isLoading = false;
      });
      _useFallbackLocation();
    }
  }

  void _useFallbackLocation() {
    setState(() {
      _currentPosition = const LatLng(18.4088, 76.5604);
      _locationStatus = 'Using fallback location (Latur center)';
    });
    _generateMockPickups();
    _createMarkers();
    _createSimpleRoute();
  }

  void _generateMockPickups() {
    if (_currentPosition == null) return;
    
    pickups = [
      {
        "id": 1,
        "location": _generateRandomLocation(center: _currentPosition!, maxDistance: 5000),
        "time_slot": "9AM-10AM",
        "inventory": 5,
      },
      {
        "id": 2,
        "location": _generateRandomLocation(center: _currentPosition!, maxDistance: 5000),
        "time_slot": "9AM-10AM",
        "inventory": 3,
      },
      {
        "id": 3,
        "location": _generateRandomLocation(center: _currentPosition!, maxDistance: 5000),
        "time_slot": "10AM-11AM",
        "inventory": 7,
      },
      {
        "id": 4,
        "location": _generateRandomLocation(center: _currentPosition!, maxDistance: 5000),
        "time_slot": "10AM-11AM",
        "inventory": 4,
      },
      {
        "id": 5,
        "location": _generateRandomLocation(center: _currentPosition!, maxDistance: 5000),
        "time_slot": "11AM-12PM",
        "inventory": 6,
      },
    ];
  }

  LatLng _generateRandomLocation({required LatLng center, required double maxDistance}) {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * maxDistance;
    final latDelta = distance * cos(angle) / 111320;
    final lngDelta = distance * sin(angle) / (111320 * cos(center.latitude * pi / 180));
    final newLat = center.latitude + latDelta;
    final newLng = center.longitude + lngDelta;
    return LatLng(newLat, newLng);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _refreshLocation() {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Refreshing location...';
    });
    _getCurrentLocation();
  }

  Future<void> _startNavigation() async {
    if (_currentPosition == null) {
      _showErrorDialog('Location not available. Please refresh.');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Navigation'),
        content: const Text('Select your preferred navigation method:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startInAppNavigation();
            },
            child: const Text('In-App Navigation'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGoogleMapsNavigation();
            },
            child: const Text('Google Maps'),
          ),
        ],
      ),
    );
  }

  void _startInAppNavigation() {
    if (_currentPosition == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          pickups: pickups,
          warehouseLocation: warehouseLocation,
          startLocation: _currentPosition!,
        ),
      ),
    );
  }

  Future<void> _startGoogleMapsNavigation() async {
    if (_currentPosition == null) return;
    String waypoints = '';
    for (var pickup in pickups) {
      waypoints += '${pickup['location'].latitude},${pickup['location'].longitude}|';
    }
    waypoints += '${warehouseLocation.latitude},${warehouseLocation.longitude}';
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${warehouseLocation.latitude},${warehouseLocation.longitude}&waypoints=$waypoints&travelmode=driving'
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Could not launch Google Maps');
      }
    } catch (e) {
      _showErrorDialog('Error launching navigation: $e');
    }
  }

  void _createMarkers() {
    if (_currentPosition == null) return;
    
    Set<Marker> markers = {};
    
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition!,
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
    
    for (var pickup in pickups) {
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
        position: warehouseLocation,
        infoWindow: const InfoWindow(
          title: 'Warehouse',
          snippet: 'Final destination',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    
    setState(() {
      _markers = markers;
    });
  }

  void _createSimpleRoute() {
    if (_currentPosition == null) return;
    
    List<LatLng> routePoints = [];
    routePoints.add(_currentPosition!);
    
    for (var pickup in pickups) {
      routePoints.add(pickup['location'] as LatLng);
    }
    
    routePoints.add(warehouseLocation);
    
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      };
      _totalDistance = '${_calculateTotalDistance().toStringAsFixed(1)} km';
      _totalTime = '~${(_calculateTotalDistance() * 2).round()} min';
    });
  }

  double _calculateTotalDistance() {
    if (_currentPosition == null) return 0.0;
    double total = 0.0;
    LatLng prev = _currentPosition!;
    
    for (var pickup in pickups) {
      LatLng pickupLocation = pickup['location'] as LatLng;
      total += _calculateDistance(prev, pickupLocation);
      prev = pickupLocation;
    }
    
    total += _calculateDistance(prev, warehouseLocation);
    return total;
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const earthRadius = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLng = _deg2rad(b.longitude - a.longitude);
    final lat1 = _deg2rad(a.latitude);
    final lat2 = _deg2rad(b.latitude);
    final aVal = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan(sqrt(aVal) / sqrt(1 - aVal));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (3.14159265359 / 180);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Map'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_currentPosition != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) {},
            ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _locationStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isLoading && _currentPosition != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _locationStatus,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          if (!_isLoading && _currentPosition != null && _totalDistance.isNotEmpty)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      child: _buildInfoCard('Distance', _totalDistance, Icons.directions_car),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Time', _totalTime, Icons.access_time),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Pickups', '${pickups.length}', Icons.location_on),
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isLoading && _currentPosition != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: _startNavigation,
                icon: const Icon(Icons.navigation),
                label: const Text(
                  'Navigate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
        ],
      ),
    );
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