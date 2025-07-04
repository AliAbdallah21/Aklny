// lib/screens/forgot_password_screen.dart
// This screen allows users to request a password reset link be sent to their email.

import 'package:flutter/material.dart';
import '../api_service/auth_api_service.dart';
import '../constants/theme_constants.dart'; // For AppColors

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();
  bool _isLoading = false;
  String? _message; // For success or error messages

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _message = null; // Clear previous messages
      });

      try {
        final responseMessage = await _authApiService.requestPasswordReset(
          _emailController.text.trim(),
        );
        setState(() {
          _message = responseMessage;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseMessage),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _message = e.toString().replaceFirst('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_message!), backgroundColor: Colors.red),
        );
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
      backgroundColor: AppColors.unbleached,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: AppColors.unbleached),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cadillacCoupe,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.unbleached),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Go back',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.lock_reset, // Icon for password reset
                  size: 100,
                  color: AppColors.orangeCrush,
                ),
                const SizedBox(height: 30),
                Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.avocadoPeel,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your email address below and we\'ll send you a link to reset your password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.avocadoPeel.withOpacity(0.7),
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
                const SizedBox(height: 30),

                // Message Display (success/error from API)
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.contains('success')
                            ? Colors.green
                            : AppColors.cadillacCoupe,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Send Reset Link Button
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orangeCrush,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _requestPasswordReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangeCrush,
                          foregroundColor: AppColors.unbleached,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 25),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to login screen
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.cadillacCoupe,
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
    );
  }
}
