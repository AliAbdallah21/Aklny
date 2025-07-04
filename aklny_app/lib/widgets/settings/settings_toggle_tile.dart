// lib/widgets/settings_toggle_tile.dart
// A reusable widget for a settings list tile with a toggle switch.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.unbleached,
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.avocadoPeel,
            fontWeight: FontWeight.w500,
          ),
        ),
        secondary: Icon(icon, color: AppColors.avocadoPeel, size: 24),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.cadillacCoupe, // Color when switch is ON
        inactiveThumbColor: AppColors.squashBlossom.withOpacity(
          0.5,
        ), // Color of the switch thumb when OFF
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ), // Adjusted padding
      ),
    );
  }
}
