// lib/widgets/section_header.dart
// A reusable widget for section headers with an icon and an optional "See All" button.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.icon,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.avocadoPeel, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.avocadoPeel,
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.orangeCrush,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
