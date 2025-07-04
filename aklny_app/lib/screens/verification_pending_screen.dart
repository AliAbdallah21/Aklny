// lib/screens/verification_pending_screen.dart
// This screen informs the user to verify their email and provides a resend option.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart'; // For AppColors
import '../api_service/auth_api_service.dart'; // For calling resendVerificationEmail
import 'login_screen.dart'; // To navigate back to login after verification

class VerificationPendingScreen extends StatefulWidget {
  final String email; // The email of the user awaiting verification

  const VerificationPendingScreen({super.key, required this.email});

  @override
  State<VerificationPendingScreen> createState() =>
      _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  final AuthApiService _authApiService = AuthApiService();
  bool _isResending = false; // State to manage loading during resend action

  // Function to handle resending the verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true; // Set loading state to true
    });
    try {
      final message = await _authApiService.resendVerificationEmail(
        widget.email,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isResending = false; // Set loading state back to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached,
      appBar: AppBar(
        title: const Text(
          'Verify Your Email',
          style: TextStyle(color: AppColors.unbleached),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cadillacCoupe,
        // No back button to force user to verify or explicitly go to login.
        // `automaticallyImplyLeading` set to false hides the default back button.
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 100,
                color: AppColors.orangeCrush,
              ),
              const SizedBox(height: 30),
              Text(
                'Verification Required!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.avocadoPeel,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.avocadoPeel.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.email, // Display the email address passed to the screen
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cadillacCoupe,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Please click the link in the email to activate your account. You might need to check your spam folder.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.avocadoPeel.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Button to resend verification email
              ElevatedButton.icon(
                onPressed: _isResending
                    ? null
                    : _resendVerificationEmail, // Disable if resending
                icon: _isResending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.unbleached,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.send_rounded, color: AppColors.unbleached),
                label: Text(
                  _isResending ? 'Resending...' : 'Resend Verification Email',
                  style: TextStyle(
                    color: AppColors.unbleached,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.orangeCrush, // Distinct color for action
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 20),
              // Button to navigate back to the Login screen
              TextButton(
                onPressed: () {
                  // This allows the user to go back to login, perhaps to try logging in again
                  // after verifying on another device, or to use different credentials.
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false, // Clears the stack
                  );
                },
                child: Text(
                  'Go to Login',
                  style: TextStyle(
                    color: AppColors.cadillacCoupe,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
