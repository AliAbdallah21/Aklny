// lib/api_service/auth_api_service.dart
// This file handles all authentication-related API calls to the backend,
// now with robust manual refresh token handling from Set-Cookie headers.

import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:cookie_jar/cookie_jar.dart'; // REMOVED: cookie_jar
import '../constants/constants.dart'; // Import AppConstants for endpoint URLs
import '../models/user_model.dart'; // IMPORTANT: Import User model for parsing responses
import '../utils/token_manager.dart'; // Import TokenManager for saving/retrieving tokens

class AuthApiService {
  // COMMENTED OUT: CookieJar instance removed
  // static final CookieJar _cookieJar = CookieJar();

  // Helper function to extract refreshToken from Set-Cookie header using regex
  String? _extractRefreshToken(http.Response response) {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      // Split by comma to handle multiple Set-Cookie headers
      final cookies = setCookieHeaders.split(',');
      for (var cookieString in cookies) {
        // Regex to find "refreshToken=VALUE;" or "refreshToken=VALUE" at end
        final refreshTokenMatch = RegExp(
          r'refreshToken=([^;]+)',
        ).firstMatch(cookieString);
        if (refreshTokenMatch != null && refreshTokenMatch.groupCount >= 1) {
          final tokenValue = refreshTokenMatch.group(1);
          print(
            'Flutter: Manually extracted refresh token: $tokenValue',
          ); // Debug print
          return tokenValue;
        }
      }
    }
    print(
      'Flutter: No refreshToken found in Set-Cookie headers.',
    ); // Debug print
    return null;
  }

  // Helper function to get common headers, including the Authorization and Cookie headers
  Future<Map<String, String>> _getCommonHeaders({
    bool includeAuth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    // Add Authorization header if requested
    if (includeAuth) {
      final accessToken = await TokenManager.getToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    // Manually add the refreshToken to the Cookie header
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken != null) {
      headers['Cookie'] = 'refreshToken=$refreshToken';
      print(
        'Flutter: Adding refreshToken to Cookie header: ${headers['Cookie']}',
      ); // Debug print
    } else {
      print(
        'Flutter: No refreshToken found in TokenManager to add to Cookie header.',
      ); // Debug print
    }

    return headers;
  }

  // Method to handle user login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse(AppConstants.loginEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: await _getCommonHeaders(), // No auth token needed for login
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      // --- DEBUG LOG START ---
      final rawSetCookieHeaders = response.headers['set-cookie'];
      print(
        'Flutter: Raw Set-Cookie headers received on Login: $rawSetCookieHeaders',
      );
      // --- DEBUG LOG END ---

      // Manually extract and save the refresh token from the response headers
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
        print(
          'AuthApiService: Refresh token extracted and saved: $refreshToken',
        ); // Debug print
      } else {
        print(
          'AuthApiService: No refresh token found in login response headers to save.',
        ); // Debug print
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Save the access token
        await TokenManager.saveToken(responseData['token']);
        return {
          'token': responseData['token'],
          'user': User.fromJson(responseData['user']),
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to login. Please try again.',
        );
      }
    } catch (e) {
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
        headers: await _getCommonHeaders(),
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
        }),
      );

      // No refresh token expected on registration, but good practice to check
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
        print(
          'AuthApiService: Refresh token found and saved after registration: $refreshToken',
        ); // Debug print
      }

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData['user']);
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
        headers: await _getCommonHeaders(), // Send cookies with this request
        body: jsonEncode({'email': email}),
      );

      // Check for new refresh token (e.g., if session was renewed)
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
      }

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
    final uri = Uri.parse('${AppConstants.verifyEmailEndpoint}?token=$token');

    try {
      final response = await http.get(
        uri,
        headers: await _getCommonHeaders(), // Send cookies with this request
      );

      // Check for new refresh token
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
      }

      if (response.statusCode == 200) {
        return 'Email verified successfully!';
      } else {
        String errorMessage = 'Failed to verify email.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
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
        headers: await _getCommonHeaders(), // Send cookies with this request
        body: jsonEncode({'email': email}),
      );

      // Check for new refresh token
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
      }

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
        headers: await _getCommonHeaders(), // Send cookies with this request
        body: jsonEncode({'token': token, 'newPassword': newPassword}),
      );

      // Check for new refresh token
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
      }

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

  // Method to authenticate with Google using the ID token from Flutter's google_sign_in.
  Future<Map<String, dynamic>> authenticateWithGoogle(String idToken) async {
    final uri = Uri.parse(AppConstants.googleAuthEndpoint);

    try {
      final response = await http.post(
        uri,
        headers: await _getCommonHeaders(), // Send cookies with this request
        body: jsonEncode(<String, String>{'idToken': idToken}),
      );

      // --- DEBUG LOG START ---
      final rawSetCookieHeaders = response.headers['set-cookie'];
      print(
        'Flutter: Raw Set-Cookie headers received on Google Login: $rawSetCookieHeaders',
      );
      // --- DEBUG LOG END ---

      // Manually extract and save the refresh token from the response headers
      final refreshToken = _extractRefreshToken(response);
      if (refreshToken != null) {
        await TokenManager.saveRefreshToken(refreshToken);
        print(
          'AuthApiService: Refresh token extracted and saved from Google login: $refreshToken',
        ); // Debug print
      } else {
        print(
          'AuthApiService: No refresh token found in Google login response headers to save.',
        ); // Debug print
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        await TokenManager.saveToken(responseData['token']);
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

  // Method to handle user logout
  Future<void> logout() async {
    final uri = Uri.parse(AppConstants.logoutEndpoint);

    try {
      // Get common headers, which will include the manually added refreshToken cookie
      final headers = await _getCommonHeaders();

      final response = await http.post(
        uri,
        headers: headers, // Use the manually prepared headers
      );

      // Clear refresh token from client-side storage
      await TokenManager.deleteRefreshToken();
      print('AuthApiService: Client-side refresh token deleted.');

      if (response.statusCode == 200) {
        print('AuthApiService: Logout successful on backend.');
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to logout on backend.');
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred during logout: $e',
      );
    }
  }

  // Method to clear only the access token (used for general token invalidation)
  Future<void> clearAccessToken() async {
    await TokenManager.deleteToken();
    print('AuthApiService: Access token cleared from client-side.');
  }
}
