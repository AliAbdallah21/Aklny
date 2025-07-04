// lib/widgets/aklny_pro_card.dart
// A reusable widget for the Aklny Pro promotional card.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class AklnyProCard extends StatelessWidget {
  const AklnyProCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orangeCrush.withOpacity(0.8),
            AppColors.cadillacCoupe.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cadillacCoupe.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aklny Pro',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.unbleached,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get unlimited benefits and special offers!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.unbleached.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.rocket_launch,
            size: 60,
            color: AppColors.unbleached.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
