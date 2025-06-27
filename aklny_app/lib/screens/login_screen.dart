// lib/screens/login_screen.dart
// This file defines the Login Screen for the Aklny app with a new design.

import 'package:flutter/material.dart';
import '../api_service/auth_api_service.dart';
import '../utils/token_manager.dart';
import 'home_screen.dart';
import 'registration_screen.dart';
import '../constants/theme_constants.dart'; // IMPORTANT: Import AppColors from central file

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await _authApiService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (response.containsKey('token') && response['token'] != null) {
          await TokenManager.saveToken(response['token']);
          print('Login successful! Token saved.');

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            _errorMessage = 'Login failed: No token received.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        print('Login error: $_errorMessage');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached, // Use the light background color
      body: Stack(
        children: [
          // Background decorative element (top-left) - Orange Crush accent
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.squashBlossom.withOpacity(0.3), // Soft accent
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Background decorative element (bottom-right) - Cadillac Coupe accent
          Positioned(
            bottom: -70,
            right: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.cadillacCoupe.withOpacity(
                  0.2,
                ), // Primary accent with opacity
                shape: BoxShape.circle,
              ),
            ),
          ),
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
                      Icons.restaurant_menu, // A more refined food icon
                      size: 120,
                      color: AppColors.cadillacCoupe, // Primary branding color
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Welcome to Aklny!',
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

                    // Email Input
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'your_email@example.com',
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.cadillacCoupe,
                        ), // Icon color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.unbleached.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.squashBlossom.withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.cadillacCoupe,
                            width: 2.0,
                          ), // Focused border
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppColors.avocadoPeel),
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

                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Your secret password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: AppColors.cadillacCoupe,
                        ), // Icon color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.unbleached.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.squashBlossom.withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.cadillacCoupe,
                            width: 2.0,
                          ), // Focused border
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                      obscureText: true,
                      style: TextStyle(color: AppColors.avocadoPeel),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

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
                          ) // Loading indicator color
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
                              elevation: 8,
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

                    // Link to Registration Screen
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Don\'t have an account? Register Here',
                        style: TextStyle(
                          color: AppColors
                              .orangeCrush, // Secondary accent for link
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
