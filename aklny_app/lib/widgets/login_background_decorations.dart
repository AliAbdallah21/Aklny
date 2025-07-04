// lib/widgets/login_background_decorations.dart
// A reusable widget for the decorative background circles on the login screen.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart'; // For AppColors

class LoginBackgroundDecorations extends StatelessWidget {
  const LoginBackgroundDecorations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background decorative element (top-left)
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
        // Background decorative element (bottom-right)
        Positioned(
          bottom: -70,
          right: -70,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.orangeCrush.withOpacity(
                0.2,
              ), // Slightly bolder accent
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
