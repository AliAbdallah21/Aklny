// lib/screens/orders_screen.dart
// This screen will display the user's past and current orders.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart'; // Import AppColors

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: AppColors.unbleached),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cadillacCoupe,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: AppColors.squashBlossom.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'No Orders Yet!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.avocadoPeel,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your delicious meals will appear here once you place an order.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.avocadoPeel.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // This button could navigate back to the FoodBrowsingScreen or a specific category
                // For now, it will just show a message.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Time to order some food!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeCrush,
                foregroundColor: AppColors.unbleached,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse Food',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
