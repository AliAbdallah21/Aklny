// lib/api_service/auth_api_service.dart
// This file handles all authentication-related API calls to the backend.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
// import '../models/user_model.dart'; // This import is not directly used in AuthApiService methods, removed or commented out.

class AuthApiService {
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
        return responseData;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to login. Please try again.',
        );
      }
    } catch (e) {
      print('Error during login API call: $e');
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String role,
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
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to register. Please try again.',
        );
      }
    } catch (e) {
      print('Error during registration API call: $e');
      throw Exception(
        'Failed to connect to the server or an unexpected error occurred: $e',
      );
    }
  }
}
