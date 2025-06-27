// lib/constants/constants.dart

class AppConstants {
  // Base URL for your backend API
  // Use 10.0.2.2 for Android Emulator to access host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:3000';

  // API Endpoints for Customer
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String profileMeEndpoint = '$baseUrl/api/users/me';
  static const String profilePasswordEndpoint =
      '$baseUrl/api/users/me/password';
  // Add other customer-related endpoints as we create them
}
