// lib/api_service/auth_api_service.dart
// This file handles all authentication-related API calls to the backend,
// now including methods for email verification, password reset, and Google Sign-In.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart'; // Import AppConstants for endpoint URLs
import '../models/user_model.dart'; // IMPORTANT: Import User model for parsing responses

class AuthApiService {
  // Method to handle user login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse(AppConstants.loginEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // The backend's login endpoint returns both 'token' and 'user' data.
        return {
          'token': responseData['token'],
          'user': User.fromJson(
            responseData['user'],
          ), // Parse the user data into a User object
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to login. Please try again.',
        );
      }
    } catch (e) {
      // Catch network errors or other unexpected issues
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  // Method to handle user registration
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    final uri = Uri.parse(AppConstants.registerEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          // 'role' is NOT sent from frontend for self-registration, backend assigns 'customer'
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // The backend's register endpoint returns the newly created user object.
        return User.fromJson(
          responseData['user'],
        ); // Parse the user data into a User object
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to register. Please try again.',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  // Method to request a resend of the email verification link.
  Future<String> resendVerificationEmail(String email) async {
    final uri = Uri.parse(AppConstants.resendVerificationEmailEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['message'] ?? 'Verification email sent.';
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to resend verification email.',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  // Method to send the verification token to the backend for email confirmation.
  Future<String> verifyEmail(String token) async {
    // The backend expects the token as a query parameter.
    final uri = Uri.parse('${AppConstants.verifyEmailEndpoint}?token=$token');

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Backend returns a success HTML page if accessed directly.
        // For Flutter, we primarily check the status code for success.
        return 'Email verified successfully!';
      } else {
        // Note: Backend returns HTML for errors on direct link access,
        // so response.body might not be JSON. Handle this gracefully.
        String errorMessage = 'Failed to verify email.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // If response body is not JSON, use a generic message.
          errorMessage =
              'Failed to verify email. Please ensure the link is valid and not expired.';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  // Method to request a password reset link to be sent to the user's email.
  Future<String> requestPasswordReset(String email) async {
    final uri = Uri.parse(AppConstants.requestPasswordResetEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['message'] ??
            'Password reset link sent (if email exists).';
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to request password reset.',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  // Method to reset the user's password using a received token.
  Future<String> resetPassword(String token, String newPassword) async {
    final uri = Uri.parse(AppConstants.resetPasswordEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['message'] ?? 'Password reset successfully.';
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to reset password.');
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  // NEW: Method to authenticate with Google using the ID token from Flutter's google_sign_in.
  Future<Map<String, dynamic>> authenticateWithGoogle(String idToken) async {
    final uri = Uri.parse(AppConstants.googleAuthEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'token': responseData['token'],
          'user': User.fromJson(responseData['user']),
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Google authentication failed. Please try again.',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred during Google authentication: $e',
      );
    }
  }
}
