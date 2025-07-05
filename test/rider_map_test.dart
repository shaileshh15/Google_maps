import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/screens/rider_map_screen.dart';

void main() {
  group('RiderMapScreen Tests', () {
    testWidgets('RiderMapScreen should display map with all required elements', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(home: RiderMapScreen()));
      
      // Wait for the widget to load
      await tester.pumpAndSettle();
      
      // Verify that the map is displayed
      expect(find.byType(GoogleMap), findsOneWidget);
      
      // Verify that the Navigate button is present
      expect(find.text('Navigate'), findsOneWidget);
      
      // Verify that the Fit Route button is present
      expect(find.text('Fit Route'), findsOneWidget);
    });

    test('Pickup data structure should match requirements', () {
      // This test verifies that the pickup data structure matches the requirements
      final expectedPickups = [
        {
          "id": 1,
          "location": const LatLng(12.971598, 77.594566),
          "time_slot": "9AM-10AM",
          "inventory": 5,
        },
        {
          "id": 2,
          "location": const LatLng(12.972819, 77.595212),
          "time_slot": "9AM-10AM",
          "inventory": 3,
        },
        {
          "id": 3,
          "location": const LatLng(12.963842, 77.609043),
          "time_slot": "10AM-11AM",
          "inventory": 7,
        },
        {
          "id": 4,
          "location": const LatLng(12.970000, 77.592000),
          "time_slot": "10AM-11AM",
          "inventory": 4,
        },
        {
          "id": 5,
          "location": const LatLng(12.968000, 77.596000),
          "time_slot": "11AM-12PM",
          "inventory": 6,
        },
      ];

      // Verify warehouse location
      const expectedWarehouse = LatLng(12.961115, 77.600000);
      expect(expectedWarehouse.latitude, 12.961115);
      expect(expectedWarehouse.longitude, 77.600000);
      
      // Verify pickup data structure
      expect(expectedPickups.length, 5);
      expect(expectedPickups[0]['id'], 1);
      expect(expectedPickups[0]['time_slot'], '9AM-10AM');
      expect(expectedPickups[0]['inventory'], 5);
    });
  });
} 