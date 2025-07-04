// lib/screens/login_screen.dart
// This file defines the Login Screen for the Aklny app,
// now using extracted components for better readability and maintainability.

import 'package:flutter/material.dart';

import '../api_service/auth_api_service.dart'; // For API calls
import '../utils/token_manager.dart'; // For token storage
import '../constants/theme_constants.dart'; // For AppColors
import '../models/user_model.dart'; // For User model and isVerified status
import 'main_app_screen.dart'; // For navigating to main app after successful login
import 'verification_pending_screen.dart'; // For verification flow
import 'forgot_password_screen.dart'; // For password reset flow
import '../widgets/auth/google_sign_in_button.dart'; // Import the GoogleSignInButton widget
import '../utils/ui_utils.dart'; // Import UiUtils for SnackBar

// NEW WIDGET IMPORTS
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/or_divider.dart';
import '../widgets/registration_prompt.dart';
import '../widgets/login_background_decorations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // To toggle password visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // Clear any previous error messages
      });

      try {
        final responseData = await _authApiService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        final String token = responseData['token'];
        final User user = responseData['user']; // Extract the User object

        // Check if the user's email is verified
        if (!user.isVerified) {
          UiUtils.showSnackBar(
            context,
            'Please verify your email address to log in.',
            isError: true,
          );
          // Navigate to the VerificationPendingScreen if email is not verified
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  VerificationPendingScreen(email: user.email),
            ),
          );
          return; // Stop the login process here if not verified
        }

        // If email is verified, proceed to save token and navigate
        await TokenManager.saveToken(token); // Save the authentication token

        // Safely access fullName or fallback to email for display
        final String displayName =
            user.fullName != null && user.fullName!.isNotEmpty
            ? user.fullName!.split(' ')[0] // Get first name if available
            : user.email; // Fallback to email if full name is null or empty
        UiUtils.showSnackBar(
          context,
          'Welcome back, $displayName!',
        ); // Using UiUtils

        // Navigate to the main application screen after successful login and verification
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainAppScreen()),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst(
            'Exception: ',
            '',
          ); // Clean error message
        });
        UiUtils.showSnackBar(
          context,
          _errorMessage!,
          isError: true,
        ); // Using UiUtils
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  // Callback for successful Google Sign-In
  void _onGoogleSignInSuccess(String token, User user) {
    // Safely access fullName or fallback to email for display
    final String displayName =
        user.fullName != null && user.fullName!.isNotEmpty
        ? user.fullName!.split(' ')[0] // Get first name if available
        : user.email; // Fallback to email if full name is null or empty
    UiUtils.showSnackBar(
      context,
      'Google Sign-In successful for $displayName!',
    ); // Using UiUtils

    // Store the 'token' (JWT from your backend)
    TokenManager.saveToken(token); // Save the authentication token
    // Navigate to the main application screen
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainAppScreen()));
  }

  // Callback for failed Google Sign-In
  void _onGoogleSignInFailure(String error) {
    UiUtils.showSnackBar(context, error, isError: true); // Using UiUtils
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached, // Use your custom color
      body: Stack(
        children: [
          // Background decorative elements
          const LoginBackgroundDecorations(), // Using the new widget
          // Main content centered
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // App Logo/Icon
                    Icon(
                      Icons.restaurant, // Example icon for your app
                      size: 120,
                      color: AppColors.cadillacCoupe, // Branding color for icon
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Welcome to Aklny',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.avocadoPeel, // Dark text for contrast
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Log in to continue your culinary journey.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.avocadoPeel.withOpacity(
                          0.7,
                        ), // Slightly faded
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    AuthTextField(
                      // Using the new AuthTextField widget
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    AuthTextField(
                      // Using the new AuthTextField widget
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Your secret password',
                      prefixIcon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.avocadoPeel.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors
                                .orangeCrush, // Branding color for link
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Message Display
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.cadillacCoupe,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Login Button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.cadillacCoupe,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .cadillacCoupe, // Primary button color
                              foregroundColor:
                                  AppColors.unbleached, // Text color
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation:
                                  8, // Stronger shadow for prominent button
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 25),

                    // "OR" Divider
                    const OrDivider(), // Using the new OrDivider widget
                    const SizedBox(height: 25), // Spacer
                    // Google Sign-In Button
                    GoogleSignInButton(
                      onSignInSuccess: _onGoogleSignInSuccess,
                      onSignInFailure: _onGoogleSignInFailure,
                    ),
                    const SizedBox(height: 20),

                    // Don't have an account? Register link
                    const RegistrationPrompt(), // Using the new RegistrationPrompt widget
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
