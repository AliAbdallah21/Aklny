// lib/screens/main_app_screen.dart
// This is the main screen of the Aklny app after login, featuring a BottomNavigationBar
// to navigate between Food Browsing, Orders, and Account sections.

import 'package:flutter/material.dart';
// Removed: import '../utils/token_manager.dart'; // No longer needed directly here
// Removed: import 'login_screen.dart'; // No longer needed directly here
import '../constants/theme_constants.dart'; // Import AppColors

// Import the new tab screens
import 'food_browsing_screen.dart';
import 'orders_screen.dart';
import 'account_screen.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex =
      0; // Index for the selected tab in the BottomNavigationBar

  // List of screens corresponding to the navigation bar items
  static const List<Widget> _widgetOptions = <Widget>[
    FoodBrowsingScreen(), // Corresponds to Home tab
    OrdersScreen(), // Corresponds to Orders tab
    AccountScreen(), // Corresponds to Account tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Removed the _logout method as it's now centralized in AuthUtils.
  // Future<void> _logout(BuildContext context) async {
  //   await TokenManager.deleteToken(); // Delete the stored token
  //   print('User logged out. Token deleted.'); // Debug log
  //
  //   // Navigate back to the LoginScreen and remove all previous routes from the stack
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     (Route<dynamic> route) =>
  //         false, // This predicate ensures all previous routes are removed
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar will be handled by each individual screen (FoodBrowsingScreen, OrdersScreen, AccountScreen)
      // This allows each screen to have its own specific app bar title and actions.
      body: Center(
        child: _widgetOptions.elementAt(
          _selectedIndex,
        ), // Display the selected screen
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long,
            ), // Or Icons.list_alt, Icons.shopping_bag_outlined
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            AppColors.cadillacCoupe, // Color for selected icon/label
        unselectedItemColor: AppColors.avocadoPeel.withOpacity(
          0.6,
        ), // Color for unselected
        onTap: _onItemTapped, // Call when a tab is tapped
        backgroundColor: AppColors.unbleached, // Background of the nav bar
        type: BottomNavigationBarType
            .fixed, // Ensures all labels are always visible
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
