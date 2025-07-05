# 📍 Location Configuration Guide

## 🎯 **Current Location Setup**

### **1. Pickup Locations (Fixed Coordinates)**
**File:** `lib/screens/rider_map_screen.dart` (Lines 25-50)

```dart
List<Map<String, dynamic>> pickups = [
  {
    "id": 1,
    "location": const LatLng(12.971598, 77.594566),  // Bangalore coordinates
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
```

### **2. Warehouse Location**
**File:** `lib/screens/rider_map_screen.dart` (Line 52)

```dart
final LatLng warehouseLocation = const LatLng(12.961115, 77.600000);
```

### **3. Rider Location (Dynamic GPS)**
**File:** `lib/screens/rider_map_screen.dart` (Lines 60-80)

```dart
Position position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
);
// Rider location is automatically set to current GPS position
```

## 🔧 **How to Modify Locations**

### **Option 1: Use Fixed Coordinates (Current Setup)**
- ✅ **Pros**: Consistent testing, exact locations
- ❌ **Cons**: Not realistic for real-world use
- **Status**: Currently Active

### **Option 2: Generate Random Pickups Near Rider**
**File:** `lib/screens/rider_map_screen.dart` (Lines 70-75)

```dart
// Uncomment these lines to generate random pickups
pickups = generateRandomPickups(
  center: LatLng(position.latitude, position.longitude),
  count: 5,
  radiusInMeters: 5000, // 5km radius
);
```

**File:** `lib/utils/location_utils.dart` (Lines 5-25)
```dart
List<Map<String, dynamic>> generateRandomPickups({
  required LatLng center,        // Rider's current location
  required int count,            // Number of pickups (5)
  required double radiusInMeters, // 5000 meters (5km)
}) {
  // Generates random pickups within specified radius
}
```

## 📍 **Current Location Details**

### **Fixed Pickup Locations (Bangalore, India)**
1. **Pickup 1**: `12.971598, 77.594566` - Near MG Road
2. **Pickup 2**: `12.972819, 77.595212` - Near Brigade Road
3. **Pickup 3**: `12.963842, 77.609043` - Near Indiranagar
4. **Pickup 4**: `12.970000, 77.592000` - Near Commercial Street
5. **Pickup 5**: `12.968000, 77.596000` - Near Koramangala

### **Warehouse Location**
- **Warehouse**: `12.961115, 77.600000` - Near Electronic City

### **Rider Location**
- **Dynamic**: Uses device GPS location
- **Accuracy**: High precision
- **Update**: Real-time tracking

## 🛠️ **Configuration Options**

### **To Use Fixed Coordinates (Current)**
```dart
// In rider_map_screen.dart, keep the pickups array as is
// Comment out the generateRandomPickups line
```

### **To Use Random Pickups Near Rider**
```dart
// In rider_map_screen.dart, uncomment these lines:
pickups = generateRandomPickups(
  center: LatLng(position.latitude, position.longitude),
  count: 5,
  radiusInMeters: 5000,
);
```

### **To Add Custom Pickup Locations**
```dart
// Replace the pickups array with your coordinates:
List<Map<String, dynamic>> pickups = [
  {
    "id": 1,
    "location": const LatLng(YOUR_LAT, YOUR_LNG),
    "time_slot": "9AM-10AM",
    "inventory": 5,
  },
  // Add more pickups...
];
```

## 🎯 **Recommendations**

### **For Development/Testing**
- ✅ Use fixed coordinates for consistent testing
- ✅ Easy to debug and verify routes
- ✅ Predictable behavior

### **For Real-World Use**
- ✅ Use random pickups near rider location
- ✅ More realistic delivery scenarios
- ✅ Dynamic route optimization

### **For Production**
- ✅ Integrate with real API for pickup data
- ✅ Use actual delivery orders
- ✅ Real-time pickup assignments

## 🔍 **Verification Steps**

1. **Check Current Setup**:
   ```bash
   # Look at lines 25-50 in rider_map_screen.dart
   # Verify pickup coordinates are correct
   ```

2. **Test Random Generation**:
   ```bash
   # Uncomment generateRandomPickups lines
   # Run app and check if pickups appear near your location
   ```

3. **Verify Route Creation**:
   ```bash
   # Check that route goes: Rider → Pickup 1 → Pickup 2 → ... → Warehouse
   ```

## 📱 **Current App Behavior**

- **Rider Location**: Automatically detected via GPS
- **Pickup Locations**: Fixed coordinates in Bangalore
- **Warehouse**: Fixed location in Electronic City
- **Route**: Optimized path through all pickups to warehouse
- **Navigation**: Both in-app and Google Maps options available

This document explains how locations are configured in the rider map application.

## Current Implementation

The app generates pickup locations dynamically based on the rider's current GPS position, while using the fixed warehouse location as specified in the requirements:

### Pickup Locations
- **Generation**: 5 random pickup locations are generated within a 5km radius of the rider's current location
- **Time Slots**: Randomly assigned from: "9AM-10AM", "10AM-11AM", "11AM-12PM", "12PM-1PM", "1PM-2PM"
- **Inventory**: Randomly assigned between 3-9 items per pickup
- **Data Structure**: Each pickup follows the exact structure from requirements:
  ```dart
  {
    "id": 1,
    "location": LatLng(latitude, longitude), // Generated near rider
    "time_slot": "9AM-10AM",
    "inventory": 5,
  }
  ```

### Warehouse Location
- **Location**: Fixed at `LatLng(12.961115, 77.600000)` as per requirements
- **Purpose**: Serves as the final destination for the delivery route
- **Note**: This is the exact warehouse location specified in the task requirements

### Rider Location
- **Source**: Uses device GPS to get current rider position
- **Accuracy**: High accuracy location tracking
- **Permission**: App requests location permissions on startup

## Requirements Compliance

The implementation follows the exact requirements:

### ✅ Pickup Locations (Dynamic Generation)
- **Requirement**: Mock 5 pickup locations within 5km radius of rider's current location
- **Implementation**: ✅ Using `generateRandomPickups()` function
- **Reason**: Ensures realistic routing and testing regardless of rider's location

### ✅ Warehouse Location (Fixed)
- **Requirement**: `final warehouseLocation = LatLng(12.961115, 77.600000)`
- **Implementation**: ✅ Fixed warehouse location as specified
- **Reason**: Warehouse is a permanent facility with known location

## Previous Fixed Locations (For Reference)

The original requirements specified these fixed Bangalore coordinates:

### Pickup Locations (Fixed - No longer used)
1. **Pickup 1**: `12.971598, 77.594566` - Near MG Road
2. **Pickup 2**: `12.972819, 77.595212` - Near Brigade Road  
3. **Pickup 3**: `12.963842, 77.609043` - Near Indiranagar
4. **Pickup 4**: `12.970000, 77.592000` - Near Commercial Street
5. **Pickup 5**: `12.968000, 77.596000` - Near Koramangala

### Warehouse Location (Fixed - Still Used)
- **Warehouse**: `12.961115, 77.600000` - Near Electronic City ✅

## How to Modify Locations

### For Testing with Fixed Pickup Locations
If you want to use fixed pickup locations for testing, you can modify `lib/screens/rider_map_screen.dart`:

1. Comment out the dynamic generation in `_initializeLocation()`:
   ```dart
   // Comment out this line:
   // pickups = generateRandomPickups(...);
   ```

2. Uncomment and use the fixed coordinates:
   ```dart
   pickups = [
     {
       "id": 1,
       "location": const LatLng(12.971598, 77.594566),
       "time_slot": "9AM-10AM", 
       "inventory": 5,
     },
     // ... add other pickups
   ];
   ```

### For Custom Location Generation
Modify the parameters in `_initializeLocation()`:
- **Pickup Count**: Change `count: 5` to desired number
- **Pickup Radius**: Change `radiusInMeters: 5000` to desired radius

## Location Utilities

The app uses `lib/utils/location_utils.dart` for:
- Generating random pickup locations
- Calculating distances between points
- Converting between coordinate systems

## Testing

To test the app:
1. Ensure GPS is enabled on your device
2. Grant location permissions when prompted
3. The app will automatically generate pickups near your current location
4. The warehouse will always be at the fixed Bangalore location
5. Each app restart will generate new random pickup locations 