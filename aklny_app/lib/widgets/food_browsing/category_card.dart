// lib/widgets/category_card.dart
// A reusable widget for displaying a single circular food category.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';
import '../../utils/ui_utils.dart'; // For SnackBar utility

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.showSnackBar(context, 'Navigating to $title category!');
        // TODO: Implement navigation to category-specific list
      },
      child: Container(
        width: 90, // Fixed width for circular card
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.4), width: 1.5),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.avocadoPeel,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
