# Delivery Rider App

A comprehensive Flutter application designed for delivery riders to manage orders, navigate efficiently, and track their performance.

## Features

### 🗺️ **Navigation & Maps**
- Real-time GPS tracking with Google Maps integration
- Optimized route planning with multiple pickup points
- Turn-by-turn navigation with distance information
- In-app navigation with route segments showing kilometers
- External Google Maps integration option

### 📦 **Order Management**
- View current and pending orders
- Order status tracking (Pending, In Progress, Completed, Cancelled)
- Customer contact information
- Order details with pickup and delivery addresses
- Real-time order status updates

### 📊 **History & Analytics**
- Complete delivery history
- Filter orders by status and date
- Search functionality by customer name or order ID
- Earnings reports and statistics
- Performance metrics

### 👤 **Profile Management**
- Rider profile with personal information
- Vehicle details and documentation
- Earnings tracking and reports
- Online/offline status toggle
- App settings and preferences

### 🎨 **User Experience**
- Modern Material Design 3 interface
- Dark/Light theme support
- Responsive design for all screen sizes
- Smooth animations and transitions
- Intuitive navigation with bottom tabs

## Screenshots

The app includes the following main screens:
- **Splash Screen**: App loading with animated logo
- **Map Screen**: Main navigation interface with route optimization
- **Orders Screen**: Current and pending orders management
- **History Screen**: Past deliveries with filtering and search
- **Profile Screen**: Rider information and app settings

## Technical Features

### Architecture
- Clean architecture with separation of concerns
- Provider pattern for state management
- Modular code structure with reusable components

### Data Models
- **Order**: Complete order information with status tracking
- **RiderProfile**: Rider details and performance metrics
- **Location Utils**: GPS and distance calculation utilities

### Services
- **Navigation Service**: Route optimization and turn-by-turn directions
- **Location Utils**: GPS tracking and distance calculations
- **App Theme**: Consistent theming across the app

## Setup Instructions

### Prerequisites
- Flutter SDK (3.6.0 or higher)
- Android Studio / VS Code
- Google Maps API key
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd map
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
- `permission_handler`: Device permissions
- `http`: API communication

### Additional Dependencies
- `shared_preferences`: Local data storage
- `connectivity_plus`: Network connectivity
- `provider`: State management
- `intl`: Internationalization
- `image_picker`: Image selection
- `cached_network_image`: Image caching
- `flutter_local_notifications`: Push notifications
- `package_info_plus`: App information
- `device_info_plus`: Device information

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── order.dart           # Order model
│   └── rider_profile.dart   # Rider profile model
├── screens/                  # UI screens
│   ├── splash_screen.dart   # Loading screen
│   ├── main_app_screen.dart # Main app with navigation
│   ├── rider_map_screen.dart # Map and navigation
│   ├── navigation_screen.dart # Turn-by-turn navigation
│   ├── orders_screen.dart   # Order management
│   ├── history_screen.dart  # Delivery history
│   └── profile_screen.dart  # Rider profile
└── utils/                    # Utilities and services
    ├── app_theme.dart       # App theming
    ├── location_utils.dart  # GPS utilities
    └── navigation_service.dart # Route optimization
```

## Key Features Implementation

### Route Optimization
The app uses a nearest neighbor algorithm to optimize delivery routes, minimizing total distance and travel time.

### Real-time Navigation
- GPS tracking with 5-second intervals
- Automatic route recalculation
- Distance and time estimates
- Turn-by-turn directions

### Order Management
- Tabbed interface for current and pending orders
- Expandable order cards with detailed information
- Status updates with visual indicators
- Customer contact integration

### Profile & Analytics
- Comprehensive rider statistics
- Earnings tracking and reporting
- Vehicle information management
- App preferences and settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact:
- Email: support@deliveryapp.com
- Documentation: [Link to documentation]

## Future Enhancements

- [ ] Real-time order notifications
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Integration with delivery platforms
- [ ] Voice navigation
- [ ] Route sharing with customers
- [ ] Payment integration
- [ ] Chat support system
