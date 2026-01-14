# BizManagement

A powerful Flutter business management application that helps you manage your businesses efficiently.

## Features

🚀 **Authentication System**
- Secure login and registration
- JWT token-based authentication
- User profile management

📊 **Dashboard**
- Business overview and analytics
- Quick actions and navigation
- Real-time data visualization

🏢 **Business Management**
- Add and manage multiple businesses
- Business types and categorization
- Status tracking and updates

🔒 **Security**
- Secure API integration
- Local data encryption
- Session management

## API Configuration

The app is pre-configured to connect to your API server at:
```
https://ndvf9jzb-7124.uks1.devtunnels.ms
```

All API endpoints are centrally configured in `lib/config/api_config.dart`.

## Project Structure

```
lib/
├── config/
│   └── api_config.dart          # API configuration and endpoints
├── models/
│   ├── user.dart               # User model and auth response
│   └── business.dart           # Business model and enums
├── providers/
│   └── auth_provider.dart      # Authentication state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart   # Login interface
│   │   └── register_screen.dart # Registration interface
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Main dashboard
│   └── splash_screen.dart      # App loading screen
├── services/
│   └── api_service.dart        # HTTP client for API calls
├── utils/
│   ├── storage_manager.dart    # Local storage management
│   └── app_theme.dart          # App theming and styles
├── widgets/                    # Reusable UI components
└── main.dart                   # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone or download this project**
2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```

### First Time Setup

1. The app will start with a splash screen
2. You'll see the login screen
3. Create a new account by clicking "Sign Up"
4. Once logged in, you'll access the main dashboard

## API Integration

### Base Configuration

The API is configured in `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://ndvf9jzb-7124.uks1.devtunnels.ms';
```

### Available Endpoints

- **Authentication:**
  - `POST /api/v1/auth/login` - User login
  - `POST /api/v1/auth/register` - User registration
  - `POST /api/v1/auth/logout` - User logout

- **User Management:**
  - `GET /api/v1/user/profile` - Get user profile
  - `PUT /api/v1/user/profile` - Update user profile

- **Business Management:**
  - `GET /api/v1/businesses` - List businesses
  - `POST /api/v1/businesses` - Create business
  - `GET /api/v1/businesses/{id}` - Get business details

- **Dashboard:**
  - `GET /api/v1/dashboard` - Dashboard data
  - `GET /api/v1/dashboard/analytics` - Analytics data

### Making API Calls

Use the `ApiService` class for all HTTP requests:

```dart
final apiService = ApiService();

// GET request
final response = await apiService.get('/api/v1/businesses');

// POST request with authentication
final response = await apiService.post(
  '/api/v1/businesses',
  body: {'name': 'My Business', 'type': 'retail'},
);
```

## State Management

The app uses the Provider pattern for state management:

- **AuthProvider**: Handles authentication state, login, logout, user management
- **BusinessProvider**: (To be added) Manages business data and operations

## Dependencies

### Core Packages
- `provider: ^6.0.5` - State management
- `http: ^1.1.0` - HTTP client for API calls
- `shared_preferences: ^2.2.2` - Local storage
- `json_annotation: ^4.8.1` - JSON serialization

### UI Packages
- `flutter_spinkit: ^5.2.0` - Loading indicators
- `fluttertoast: ^8.2.4` - Toast notifications
- `go_router: ^12.1.3` - Navigation
- `flutter_form_builder: ^9.1.1` - Form handling

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Check the documentation
- Review the API integration guide
- Contact support team

## License

This project is proprietary software. All rights reserved.

---

**BizManagement** - Your Business, Simplified 🚀