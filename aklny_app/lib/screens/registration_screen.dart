// lib/screens/registration_screen.dart
// This file defines the Registration Screen for the Aklny app with updated design,
// now correctly integrated with the email verification flow.

import 'package:flutter/material.dart';
import '../api_service/auth_api_service.dart'; // For API calls
import '../constants/theme_constants.dart'; // For AppColors
import 'login_screen.dart'; // For navigating to login
import 'verification_pending_screen.dart'; // IMPORTANT: For new verification flow


class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final AuthApiService _authApiService =
      AuthApiService(); // Instance of the API service

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true; // To toggle password visibility

  // _selectedRole is no longer needed here as it's not passed to AuthApiService.register.
  // The backend now defaults new registrations to 'customer' role.

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Ensure form is validated
      setState(() {
        _isLoading = true; // Show loading indicator
        _errorMessage = null; // Clear previous errors
      });

      try {
        // CORRECTED CALL: Removed the 'role' parameter. Backend handles it.
        // The register method now returns a User object directly.
        final user = await _authApiService.register(
          email: _emailController.text.trim(),
          password:
              _passwordController.text, // Password should not be trimmed here
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! Please check your email to verify your account.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // NEW NAVIGATION: Navigate to VerificationPendingScreen after successful registration
        // Pass the user's email so the pending screen can display it and offer resend.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VerificationPendingScreen(email: user.email),
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst(
            'Exception: ',
            '',
          ); // Clean error message
        });
        print('Registration error: $_errorMessage'); // Log error for debugging
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached, // Use your custom color
      body: Stack(
        children: [
          // Background decorative element (top-left) - Orange Crush accent
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.orangeCrush.withOpacity(0.3), // Soft accent
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Background decorative element (bottom-left) - Cadillac Coupe accent
          Positioned(
            bottom: -70,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.cadillacCoupe.withOpacity(
                  0.2,
                ), // Slightly bolder accent
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
                      Icons.person_add_alt_1, // Example icon for registration
                      size: 120,
                      color: AppColors.cadillacCoupe, // Branding color for icon
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Join Aklny!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.avocadoPeel, // Dark text for contrast
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Create your account to explore delicious home-cooked meals.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.avocadoPeel.withOpacity(
                          0.7,
                        ), // Slightly faded
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Full Name Input
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Your full name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.cadillacCoupe,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide.none, // No border for cleaner look
                        ),
                        filled: true,
                        fillColor: AppColors.unbleached.withOpacity(
                          0.9,
                        ), // Subtle fill
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          // Custom enabled border
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.squashBlossom.withOpacity(0.5),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // Custom focused border
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.cadillacCoupe,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          // Error border
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          // Focused error border
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      style: TextStyle(color: AppColors.avocadoPeel),
                    ),
                    const SizedBox(height: 20),

                    // Phone Number Input
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g., 01xxxxxxxxx',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: AppColors.cadillacCoupe,
                        ),
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
                          ),
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
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        // Adjust regex if needed, this one checks for 11 digits starting with 01
                        if (!RegExp(
                          r'^01[0-2,5]{1}[0-9]{8}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid Egyptian phone number (e.g., 01xxxxxxxxx).';
                        }
                        return null;
                      },
                      style: TextStyle(color: AppColors.avocadoPeel),
                    ),
                    const SizedBox(height: 20),

                    // Email Input
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'your_email@example.com',
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.cadillacCoupe,
                        ),
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
                          ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      style: TextStyle(color: AppColors.avocadoPeel),
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create a strong password',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: AppColors.cadillacCoupe,
                        ),
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
                          ),
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
                      ),
                      obscureText: _obscurePassword, // Toggle visibility
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please create a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                      style: TextStyle(color: AppColors.avocadoPeel),
                    ),
                    const SizedBox(height: 30),

                    // Error Message Display
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.cadillacCoupe, // Use error color
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Register Button
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.cadillacCoupe,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _register,
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
                              'Register',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 25),

                    // Link back to Login Screen
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Already have an account? Login Here',
                        style: TextStyle(
                          color:
                              AppColors.orangeCrush, // Branding color for link
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
