import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  // Refresh token management
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await _prefs;
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await _prefs;
    await prefs.remove(_refreshTokenKey);
  }

  // User data management
  static Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_userEmailKey);
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await _prefs;
    await prefs.setString('username', username);
  }

  static Future<String?> getUsername() async {
    final prefs = await _prefs;
    return prefs.getString('username');
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}