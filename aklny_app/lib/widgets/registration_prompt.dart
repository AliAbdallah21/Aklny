// lib/widgets/registration_prompt.dart
// A reusable widget for the "Don't have an account? Register Here" prompt.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart'; // For AppColors
import '../screens/registration_screen.dart'; // For navigation

class RegistrationPrompt extends StatelessWidget {
  const RegistrationPrompt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(color: AppColors.avocadoPeel.withOpacity(0.6)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
          child: Text(
            'Register Here',
            style: TextStyle(
              color: AppColors.orangeCrush, // Branding color for link
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
