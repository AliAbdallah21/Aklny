// lib/utils/auth_utils.dart
// This file contains common authentication-related utility functions.

import 'package:flutter/material.dart';
import '../utils/token_manager.dart'; // For TokenManager
import '../screens/login_screen.dart'; // For LoginScreen navigation

class AuthUtils {
  /// Logs out the user by deleting the token and navigates to the LoginScreen,
  /// clearing the navigation stack.
  /// [context] The BuildContext for navigation.
  static Future<void> logoutAndNavigateToLogin(BuildContext context) async {
    await TokenManager.deleteToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) =>
          false, // This predicate ensures all previous routes are removed
    );
  }
}
