// lib/screens/food_browsing_screen.dart
// This screen displays a dynamic and visually appealing list of food items and restaurants,
// integrating elements from various app inspirations to create a unique Aklny experience.
// Now refactored into smaller, reusable components for better organization.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart'; // For AppColors
import '../utils/ui_utils.dart'; // Corrected: For SnackBar utility
 // For SnackBar utility

// NEW WIDGET IMPORTS
import '../widgets/food_browsing/food_browsing_app_bar.dart';
import '../widgets/food_browsing/search_bar_widget.dart';
import '../widgets/food_browsing/section_header.dart';
import '../widgets/food_browsing/category_card.dart';
import '../widgets/food_browsing/promo_banner_card.dart';
import '../widgets/food_browsing/restaurant_card.dart';
import '../widgets/food_browsing/order_again_card.dart';

class FoodBrowsingScreen extends StatefulWidget {
  const FoodBrowsingScreen({super.key});

  @override
  State<FoodBrowsingScreen> createState() => _FoodBrowsingScreenState();
}

class _FoodBrowsingScreenState extends State<FoodBrowsingScreen> {
  // Placeholder for the current delivery location.
  // In a real app, this would be dynamic, fetched from user settings or GPS.
  String _currentLocation = 'Cairo';

  @override
  Widget build(BuildContext context) {
    // Placeholder restaurant data
    final restaurants = [
      {
        'name': 'Tajally Grill & More',
        'cuisine': 'Khaleji, BBQ',
        'rating': '4.8 (1.2K+)',
        'deliveryTime': '25-35 min',
        'priceRange': 'EGP 50+',
        'imageUrl':
            'https://placehold.co/400x200/cadillacCoupe/unbleached?text=Tajally', // Placeholder image
        'hasOffer': true,
        'isOnlinePayment': true,
      },
      {
        'name': 'Pasta & Co.',
        'cuisine': 'Italian, Pasta',
        'rating': '4.7 (800+)',
        'deliveryTime': '30-40 min',
        'priceRange': 'EGP 60+',
        'imageUrl':
            'https://placehold.co/400x200/orangeCrush/unbleached?text=Pasta', // Placeholder image
        'hasOffer': false,
        'isOnlinePayment': true,
      },
      {
        'name': 'Hadramoot El Malky',
        'cuisine': 'Egyptian, Oriental',
        'rating': '4.6 (2K+)',
        'deliveryTime': '20-30 min',
        'priceRange': 'EGP 40+',
        'imageUrl':
            'https://placehold.co/400x200/avocadoPeel/unbleached?text=Hadramoot', // Placeholder image
        'hasOffer': true,
        'isOnlinePayment': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.unbleached,
      body: CustomScrollView(
        slivers: [
          // --- Custom SliverAppBar with Location and Actions (using new widget) ---
          FoodBrowsingAppBar(
            currentLocation: _currentLocation,
            onLocationTap: () {
              UiUtils.showSnackBar(context, 'Change delivery location coming soon!');
              // TODO: Implement location selection
            },
            onNotificationsTap: () {
              UiUtils.showSnackBar(context, 'Notifications!');
              // TODO: Navigate to Notifications screen
            },
          ),

          // --- Search Bar Section (using new widget) ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: SearchBarWidget(),
            ),
          ),

          // --- Quick Categories Section ---
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Explore Categories',
              icon: Icons.category,
              onSeeAll: () {
                UiUtils.showSnackBar(context, 'Viewing all categories!');
                // TODO: Navigate to All Categories screen
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120, // Height for horizontal category list
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  CategoryCard( // Corrected call
                    title: 'Food',
                    icon: Icons.fastfood,
                    color: AppColors.orangeCrush,
                  ),
                  CategoryCard( // Corrected call
                    title: 'Drinks',
                    icon: Icons.local_drink,
                    color: AppColors.squashBlossom,
                  ),
                  CategoryCard( // Corrected call
                    title: 'Healthy',
                    icon: Icons.local_florist,
                    color: AppColors.avocadoPeel,
                  ),
                  CategoryCard( // Corrected call
                    title: 'Sweets',
                    icon: Icons.cake,
                    color: AppColors.cadillacCoupe,
                  ),
                  CategoryCard( // Corrected call
                    title: 'Groceries',
                    icon: Icons.shopping_bag,
                    color: AppColors.orangeCrush,
                  ),
                  CategoryCard( // Corrected call
                    title: 'Offers',
                    icon: Icons.local_offer,
                    color: AppColors.squashBlossom,
                  ),
                  // Add more categories
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- Deals & Offers Section (Carousel Placeholder) ---
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Exclusive Deals',
              icon: Icons.local_offer_rounded,
              onSeeAll: () {
                UiUtils.showSnackBar(context, 'Viewing all deals!');
                // TODO: Navigate to All Deals screen
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180, // Height for promotional banners
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  PromoBannerCard( // Corrected call
                    title: 'Get 20% off your first order!',
                    subtitle: 'Use code AKLNY20',
                    color: AppColors.cadillacCoupe,
                    icon: Icons.percent,
                  ),
                  PromoBannerCard( // Corrected call
                    title: 'Free Delivery on orders over EGP 100',
                    subtitle: 'Limited time offer',
                    color: AppColors.squashBlossom,
                    icon: Icons.delivery_dining,
                  ),
                  PromoBannerCard( // Corrected call
                    title: 'Unlock Aklny Pro for more!',
                    subtitle: 'Premium benefits available now',
                    color: AppColors.avocadoPeel,
                    icon: Icons.diamond,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- Top-Rated Restaurants Section ---
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Top-Rated Restaurants',
              icon: Icons.star_border,
              onSeeAll: () {
                UiUtils.showSnackBar(context, 'Viewing all top-rated restaurants!');
                // TODO: Navigate to All Restaurants screen
              },
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index >= restaurants.length) return null;
                return RestaurantCard(restaurant: restaurants[index]); // Using new widget
              },
              childCount: restaurants.length, // Display placeholder restaurants
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // --- Order Again Section (if applicable) ---
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Order Again',
              icon: Icons.history,
              onSeeAll: () {
                UiUtils.showSnackBar(context, 'Viewing your past orders!');
                // TODO: Navigate to past orders screen
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150, // Height for order again items
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: const [
                  OrderAgainCard( // Corrected call
                    dishName: 'Your Last Combo Meal',
                    restaurantName: 'Bazooka',
                    price: 'EGP 75',
                    imageUrl: 'https://placehold.co/150x150/squashBlossom/avocadoPeel?text=Combo', // Placeholder
                  ),
                  OrderAgainCard( // Corrected call
                    dishName: 'Chicken Shawerma',
                    restaurantName: 'Broccar',
                    price: 'EGP 55',
                    imageUrl: 'https://placehold.co/150x150/cadillacCoupe/unbleached?text=Shawerma', // Placeholder
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ), // Final padding
        ],
      ),
    );
  }
}
