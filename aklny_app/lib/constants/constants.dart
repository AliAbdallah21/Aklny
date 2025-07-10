// lib/constants/constants.dart
// This file holds all application-wide constants, including backend API endpoints.

class AppConstants {
  // Base URL for your backend API.
  // IMPORTANT: Replace with your actual backend URL (e.g., your public IP or domain)
  // When running on an emulator, '10.0.2.2' maps to your host machine's localhost.
  // For physical devices, use your machine's local IP address (e.g., '192.168.1.X')
  // or your deployed backend URL.
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Example for Android emulator

  // Authentication Endpoints
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String verifyEmailEndpoint = '$baseUrl/auth/verify-email';
  static const String resendVerificationEmailEndpoint =
      '$baseUrl/auth/resend-verification-email';
  static const String requestPasswordResetEndpoint =
      '$baseUrl/auth/request-password-reset';
  static const String resetPasswordEndpoint = '$baseUrl/auth/reset-password';
  static const String googleAuthEndpoint =
      '$baseUrl/auth/google-login'; // Google Auth Endpoint
  static const String logoutEndpoint =
      '$baseUrl/auth/logout'; // Logout endpoint

  // User Profile Endpoints (Names preserved as requested)
  static const String profileMeEndpoint = '$baseUrl/users/me';
  static const String profilePasswordEndpoint = '$baseUrl/users/me/password';

  // Add other endpoints as your application grows (e.g., food items, orders, sellers)
  // static const String foodItemsEndpoint = '$baseUrl/food-items';
  // static const String String ordersEndpoint = '$baseUrl/orders';
}
