// lib/widgets/settings_navigation_tile.dart
// A reusable widget for a settings list tile that navigates to another screen or triggers an action.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class SettingsNavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsNavigationTile({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ), // Reduced vertical margin
      elevation: 0.5, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.unbleached,
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.avocadoPeel,
          size: 24,
        ), // Darker icon color for contrast
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.avocadoPeel,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.squashBlossom.withOpacity(0.7),
              size: 16,
            ), // Smaller arrow
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
