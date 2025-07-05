# Flutter Rider Map Application

A Flutter application that displays a rider's current location, pickup points, warehouse location, and provides navigation functionality with route optimization.

## Features

### 🗺️ **Map Display**
- Real-time GPS tracking with Google Maps integration
- Rider's current location marker (blue)
- Pickup location markers (green) with mock data within 5km
- Warehouse marker (red) as final destination
- Route polyline connecting all points

### 🧭 **Navigation**
- In-app navigation with step-by-step guidance
- External Google Maps integration
- Live location tracking with 5-second updates
- Distance and time calculations
- Turn-by-turn directions

### 📱 **User Interface**
- Clean, modern Material Design
- Responsive layout for all screen sizes
- Route information overlay (distance, time, pickup count)
- Navigation button with multiple options
- Location status display

## Technical Implementation

### Architecture
- Single functional screen as per requirements
- Clean code structure with separation of concerns
- Modular utilities for location and navigation services

### Key Components
- **RiderMapScreen**: Main map interface with markers and route
- **NavigationScreen**: Turn-by-turn navigation with live updates
- **Location Utils**: GPS tracking and distance calculations
- **Navigation Service**: Route optimization and directions

### Data Models
- **Pickup Data**: Mock locations with time slots and inventory
- **Route Information**: Distance calculations and time estimates
- **Location Data**: GPS coordinates and bearing calculations

## Setup Instructions

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Android Studio / VS Code
- Google Maps API key
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shaileshh15/Google_maps.git
   cd Google_maps
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add the API key to your Android/iOS configuration

4. **Android Setup**
   - Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`
   - Ensure location permissions are properly configured

5. **iOS Setup**
   - Add your Google Maps API key to `ios/Runner/AppDelegate.swift`
   - Configure location permissions in `ios/Runner/Info.plist`

6. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

### Core Dependencies
- `google_maps_flutter`: Google Maps integration
- `geolocator`: GPS location services
- `url_launcher`: External app launching

### Additional Dependencies
- `flutter/material.dart`: UI framework
- `dart:math`: Mathematical calculations
- `dart:async`: Asynchronous operations

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── order.dart           # Order model
│   └── rider_profile.dart   # Rider profile model
├── screens/                  # UI screens
│   ├── rider_map_screen.dart # Main map interface
│   └── navigation_screen.dart # Turn-by-turn navigation
└── utils/                    # Utilities and services
    ├── app_theme.dart       # App theming
    ├── location_utils.dart  # GPS utilities
    └── navigation_service.dart # Route optimization
```

## Key Features Implementation

### Mock Data Generation
- Pickup locations randomly generated within 5km of rider's location
- Realistic time slots and inventory counts
- Warehouse location at fixed coordinates

### Route Calculation
- Simple route through all pickup points to warehouse
- Distance calculations using Haversine formula
- Time estimates based on average speed

### Location Services
- GPS permission handling
- Fallback location (Latur center) if GPS unavailable
- Real-time location updates

### Navigation Options
- In-app navigation with detailed steps
- External Google Maps with waypoints
- Live location tracking during navigation

## Testing

The project includes unit tests for:
- Navigation screen functionality
- Rider map screen features
- Location utilities

Run tests with:
```bash
flutter test
```

## Code Quality

- Zero Flutter analyze issues
- Clean, professional code structure
- No debug prints or unnecessary comments
- Proper error handling and user feedback



## Requirements Compliance

✅ **Single functional screen** - Rider map with all required features
✅ **Current location display** - Real GPS tracking with fallback
✅ **Pickup markers** - Mock locations within 5km as specified
✅ **Warehouse marker** - Fixed location as final destination
✅ **Route polyline** - Visual path from rider through pickups to warehouse
✅ **Navigation button** - In-app and Google Maps options
✅ **Clean code** - Professional implementation ready for review
