// lib/widgets/account_option_tile.dart
// A reusable widget for a single account option tile (e.g., My Orders, Settings).

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class AccountOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const AccountOptionTile({
    Key? key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1, // Slightly less elevation for list items
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.unbleached,
      child: ListTile(
        leading: Icon(icon, color: AppColors.cadillacCoupe, size: 26),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.avocadoPeel,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.squashBlossom.withOpacity(0.7),
              size: 18,
            ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      ),
    );
  }
}