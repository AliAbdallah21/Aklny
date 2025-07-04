// lib/widgets/profile_info_field.dart
// A reusable widget to display a single read-only profile information field.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart'; // For AppColors

class ProfileInfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ProfileInfoField({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null)
            Icon(icon, color: AppColors.cadillacCoupe, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.avocadoPeel.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.avocadoPeel,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
