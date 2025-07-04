// lib/widgets/settings_section_header.dart
// A reusable widget for displaying a section header in settings.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({Key? key, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.cadillacCoupe, // Use a bold brand color for headers
        ),
      ),
    );
  }
}
