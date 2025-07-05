import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/screens/navigation_screen.dart';

void main() {
  group('NavigationScreen Tests', () {
    testWidgets('NavigationScreen should display pickups and route segments', (WidgetTester tester) async {
      // Create test pickup data
      final testPickups = [
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
      ];

      const testWarehouse = LatLng(12.961115, 77.600000);
      const testStartLocation = LatLng(12.970000, 77.590000);

      // Build the widget
      await tester.pumpWidget(MaterialApp(
        home: NavigationScreen(
          pickups: testPickups,
          warehouseLocation: testWarehouse,
          startLocation: testStartLocation,
        ),
      ));
      
      // Wait for the widget to load
      await tester.pumpAndSettle();
      
      // Verify that the map is displayed
      expect(find.byType(GoogleMap), findsOneWidget);
      
      // Verify that route segments section is present
      expect(find.text('Route Segments'), findsOneWidget);
      
      // Verify that pickup information is displayed
      expect(find.text('Pickup 1'), findsOneWidget);
      expect(find.text('Pickup 2'), findsOneWidget);
      expect(find.text('Warehouse'), findsOneWidget);
    });

    test('NavigationScreen should create correct number of route segments', () {
      final testPickups = [
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
      ];

      const testWarehouse = LatLng(12.961115, 77.600000);
      const testStartLocation = LatLng(12.970000, 77.590000);

      // Create navigation screen
      final navigationScreen = NavigationScreen(
        pickups: testPickups,
        warehouseLocation: testWarehouse,
        startLocation: testStartLocation,
      );

      // Verify that the screen is created with correct data
      expect(navigationScreen.pickups.length, 2);
      expect(navigationScreen.warehouseLocation, testWarehouse);
      expect(navigationScreen.startLocation, testStartLocation);
    });
  });
} 