// lib/widgets/food_browsing_app_bar.dart
// A custom SliverAppBar for the Food Browsing Screen, displaying location and actions.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class FoodBrowsingAppBar extends StatelessWidget {
  final String currentLocation;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationsTap;

  const FoodBrowsingAppBar({
    Key? key,
    required this.currentLocation,
    required this.onLocationTap,
    required this.onNotificationsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0, // Height when fully expanded
      floating: true, // App bar floats over the content
      pinned: true, // App bar stays at the top when scrolled up
      backgroundColor: AppColors.cadillacCoupe, // Primary brand color
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20.0, bottom: 15.0),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onLocationTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.unbleached.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Deliver to $currentLocation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.unbleached,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.unbleached.withOpacity(0.8),
                    size: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'What would you like to eat?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.unbleached,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: AppColors.unbleached,
            size: 28,
          ),
          onPressed: onNotificationsTap,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
