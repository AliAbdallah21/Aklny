// lib/utils/auth_utils.dart
// This file contains common authentication-related utility functions.
// Logout now handles clearing access token and calling backend for refresh token revocation.

import 'package:flutter/material.dart';
import '../utils/token_manager.dart'; // For TokenManager
import '../screens/login_screen.dart'; // For LoginScreen navigation
import '../api_service/auth_api_service.dart'; // Import AuthApiService
import '../utils/ui_utils.dart'; // For SnackBar utility

class AuthUtils {
  /// Logs out the user by deleting the access token, calling the backend logout endpoint
  /// to revoke the refresh token, and navigates to the LoginScreen,
  /// clearing the navigation stack.
  /// [context] The BuildContext for navigation.
  static Future<void> logoutAndNavigateToLogin(BuildContext context) async {
    final AuthApiService authApiService =
        AuthApiService(); // Instantiate the service

    // 1. Clear client-side access token immediately
    await TokenManager.deleteToken(); // Clears JWT access token
    print('AuthUtils: Client-side access token cleared.'); // Debugging print

    // 2. Call backend logout endpoint to revoke refresh token and clear HttpOnly cookie
    try {
      await authApiService
          .logout(); // This will send the refresh token cookie and delete it client-side
      print('AuthUtils: Backend logout call successful.'); // Debugging print
      UiUtils.showSnackBar(
        context,
        'Logged out successfully!',
      ); // Optional: Show success message
    } catch (e) {
      // Log the error but don't prevent navigation, as client-side tokens are cleared.
      print(
        'AuthUtils: Error during backend logout call: $e',
      ); // Debugging print
      UiUtils.showSnackBar(
        context,
        'Logout completed with a minor issue. Please try again if problems persist.',
        isError: true,
      ); // Optional: Show a warning
    } finally {
      // Ensure all tokens are cleared from TokenManager, even if backend call failed
      await TokenManager.clearAllTokens();
    }

    // 3. Navigate to login screen, clearing navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) =>
          false, // This predicate ensures all previous routes are removed
    );
  }
}
