// lib/widgets/restaurant_card.dart
// A reusable widget for displaying a single restaurant card.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';
import '../../utils/ui_utils.dart'; // For SnackBar utility

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UiUtils.showSnackBar(context, 'Navigating to ${restaurant['name']} menu!');
        // TODO: Implement navigation to Restaurant Menu screen
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias, // Clip children to card's rounded corners
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            Stack(
              children: [
                Image.network(
                  restaurant['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: AppColors.squashBlossom.withOpacity(0.2),
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: AppColors.avocadoPeel.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                if (restaurant['hasOffer'])
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orangeCrush,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Offer',
                        style: TextStyle(
                          color: AppColors.unbleached,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (restaurant['isOnlinePayment'])
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cadillacCoupe,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Online Payment',
                        style: TextStyle(
                          color: AppColors.unbleached,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.avocadoPeel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant['cuisine'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.avocadoPeel.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.orangeCrush,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['rating'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.avocadoPeel,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.delivery_dining,
                        color: AppColors.avocadoPeel.withOpacity(0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['deliveryTime'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.avocadoPeel,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.monetization_on,
                        color: AppColors.avocadoPeel.withOpacity(0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant['priceRange'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.avocadoPeel,
                        ),
                      ),
                    ],
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
