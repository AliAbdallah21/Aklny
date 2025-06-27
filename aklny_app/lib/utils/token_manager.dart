// lib/utils/token_manager.dart
// This file provides utility methods for managing JWT tokens using shared_preferences.

import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'jwt_token'; // Key to store the JWT token

  // Saves the JWT token to local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('TokenManager: Token saved successfully.'); // Debug log
  }

  // Retrieves the JWT token from local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print(
      'TokenManager: Token retrieved: ${token != null ? "Present" : "Missing"}',
    ); // Debug log
    return token;
  }

  // Deletes the JWT token from local storage (e.g., on logout)
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('TokenManager: Token deleted successfully.'); // Debug log
  }
}
