import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/storage_manager.dart';
import '../utils/database_helper.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  // Callback to notify other providers when user changes
  Function(User?)? _onUserChanged;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final ApiService _apiService = ApiService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Set callback for user changes (to be used by other providers)
  void setOnUserChanged(Function(User?) callback) {
    _onUserChanged = callback;
  }

  void _notifyUserChanged() {
    notifyListeners();
    _onUserChanged?.call(_user);
  }

  // Initialize auth state from local database
  Future<void> initializeAuth() async {
    _setLoading(true);
    
    try {
      // Check for stored token first
      final token = await StorageManager.getToken();
      if (token != null) {
        // Load user from local database
        final localUser = await _databaseHelper.getCurrentUser();
        if (localUser != null) {
          _user = localUser;
          _notifyUserChanged();
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Login method using username/password
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      debugPrint('🔑 Starting login for username: $username'); // Debug log
      
      final response = await _apiService.post(
        ApiEndpoints.login,
        body: {
          'username': username,
          'password': password,
        },
      );

      debugPrint('✅ Login response received: $response'); // Debug log

      // Parse the response according to your API structure
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);
      
      debugPrint('🎯 Parsed user: ${user.fullName} (ID: ${user.id})'); // Debug log
      
      // Save token to shared preferences
      await StorageManager.saveToken(token);
      await StorageManager.saveUserId(user.id.toString());
      await StorageManager.saveUserEmail(user.username);
      await StorageManager.saveUsername(user.fullName);
      
      await _databaseHelper.insertUser(user);
      await _databaseHelper.saveAuthToken(token, user.id);
      
      _user = user;
      _notifyUserChanged();
      
      debugPrint('🎉 Login successful!'); // Debug log
      return true;
    } catch (e) {
      debugPrint('💥 Login error: $e'); // Debug log
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register method (if you have registration)
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    required String phone,
    required String idNumber,
    required DateTime dateOfBirth,
    required String department,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.post(
        ApiEndpoints.register,
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'password': password,
          'phone': phone,
          'idNumber': idNumber,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'department': department,
        },
      );

      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);
      
      // Save token and user data
      await StorageManager.saveToken(token);
      await StorageManager.saveUserId(user.id.toString());
      await StorageManager.saveUserEmail(user.username);
      
      await _databaseHelper.insertUser(user);
      await _databaseHelper.saveAuthToken(token, user.id);
      
      _user = user;
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Simple register for demo purposes
  Future<bool> registerSimple(String name, String email, String password) async {
    // Parse the name
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.last : 'User';
    
    return register(
      firstName: firstName,
      lastName: lastName,
      username: email,
      password: password,
      phone: '0000000000', // Default placeholder
      idNumber: '0000000000', // Default placeholder
      dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 25)), // Default 25 years ago
      department: 'General', // Default department
    );
  }

  // Load user profile from API
  Future<void> loadUserProfile() async {
    try {
      final response = await _apiService.get(ApiEndpoints.userProfile);
      final user = User.fromJson(response['user'] ?? response);
      
      // Update local database
      await _databaseHelper.updateUser(user);
      
      _user = user;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    }
  }

  // Logout method
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      // Call logout endpoint if available
      await _apiService.post(ApiEndpoints.logout);
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API call failed: $e');
    }
    
    // Clear all local data
    await StorageManager.clearUserData();
    await _databaseHelper.clearAllData();
    
    _user = null;
    _setError(null);
    
    _setLoading(false);
    _notifyUserChanged();
  }

  // Update profile
  Future<bool> updateProfile(User updatedUser) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        body: updatedUser.toJson(),
      );
      
      final user = User.fromJson(response['user'] ?? response);
      
      // Update local database
      await _databaseHelper.updateUser(user);
      
      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}