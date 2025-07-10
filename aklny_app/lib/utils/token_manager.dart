// lib/utils/token_manager.dart
// This file manages the storage and retrieval of authentication tokens
// using shared_preferences. Now handles both JWT access token and refresh token.

import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken'; // Refresh token key

  /// Saves the JWT access token.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    print('TokenManager: Access Token saved successfully.');
  }

  /// Retrieves the JWT access token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    print(
      'TokenManager: Access Token retrieved: ${token != null ? "Present" : "Missing"}',
    );
    return token;
  }

  /// Deletes the JWT access token.
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    print('TokenManager: Access Token deleted successfully.');
  }

  /// Saves the refresh token.
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
    print('TokenManager: Refresh Token saved successfully.');
  }

  /// Retrieves the refresh token.
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_refreshTokenKey);
    print(
      'TokenManager: Refresh Token retrieved: ${token != null ? "Present" : "Missing"}',
    );
    return token;
  }

  /// Deletes the refresh token.
  static Future<void> deleteRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
    print('TokenManager: Refresh Token deleted successfully.');
  }

  /// Clears all stored tokens (access token and refresh token).
  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    print('TokenManager: All tokens cleared.');
  }
}
