// lib/api_service/user_api_service.dart
// This file handles all user profile-related API calls to the backend.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/user_model.dart';
import '../utils/token_manager.dart';

class UserApiService {
  Future<User> getMyProfile() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final uri = Uri.parse(AppConstants.profileMeEndpoint);

    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Unauthorized or forbidden: ${jsonDecode(response.body)['message'] ?? 'Please log in again.'}',
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load profile.');
      }
    } catch (e) {
      print('Error during getMyProfile API call: $e');
      rethrow;
    }
  }

  Future<User> updateMyProfile(Map<String, dynamic> updateData) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final uri = Uri.parse(AppConstants.profileMeEndpoint);

    try {
      final response = await http.put(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return User.fromJson(responseData['user']);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Unauthorized or forbidden: ${jsonDecode(response.body)['message'] ?? 'Please log in again.'}',
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile.');
      }
    } catch (e) {
      print('Error during updateMyProfile API call: $e');
      rethrow;
    }
  }

  Future<String> changeMyPassword(
    String currentPassword,
    String newPassword,
  ) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final uri = Uri.parse(AppConstants.profilePasswordEndpoint);

    try {
      final response = await http.put(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['message'] ?? 'Password updated successfully!';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'Authentication failed: ${jsonDecode(response.body)['message'] ?? 'Incorrect current password or token expired.'}',
        );
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to change password.');
      }
    } catch (e) {
      print('Error during changeMyPassword API call: $e');
      rethrow;
    }
  }
}
