// lib/widgets/order_again_card.dart
// A reusable widget for displaying a single "Order Again" item card.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';
import '../../utils/ui_utils.dart'; // For SnackBar utility

class OrderAgainCard extends StatelessWidget {
  final String dishName;
  final String restaurantName;
  final String price;
  final String imageUrl;

  const OrderAgainCard({
    Key? key,
    required this.dishName,
    required this.restaurantName,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.showSnackBar(
          context,
          'Re-ordering $dishName from $restaurantName!',
        );
        // TODO: Implement re-order logic
      },
      child: Container(
        width: 180, // Fixed width for order again cards
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: AppColors.unbleached,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.squashBlossom.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 90,
                  color: AppColors.cadillacCoupe.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.avocadoPeel.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.avocadoPeel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurantName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.avocadoPeel.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orangeCrush,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
