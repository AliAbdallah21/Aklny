// lib/widgets/profile_editable_field.dart
// A reusable TextFormField widget for editable profile fields with consistent styling.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for TextInputFormatter
import '../../constants/theme_constants.dart'; // For AppColors

class ProfileEditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool isEnabled;

  const ProfileEditableField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.cadillacCoupe),
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
            borderSide: BorderSide(color: AppColors.cadillacCoupe, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            // Style for disabled fields
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.squashBlossom.withOpacity(0.3),
              width: 1.0,
            ),
          ),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Apply formatters if provided
        style: TextStyle(color: AppColors.avocadoPeel),
      ),
    );
  }
}
