// lib/screens/home_screen.dart
// This is the main application screen after login, now with logout and profile navigation.

import 'package:flutter/material.dart';
import '../utils/token_manager.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; // Import ProfileScreen
import '../constants/theme_constants.dart'; // IMPORTANT: Import AppColors from central file

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method to handle logout
  Future<void> _logout(BuildContext context) async {
    await TokenManager.deleteToken(); // Delete the stored token
    print('User logged out. Token deleted.'); // Debug log

    // Navigate back to the LoginScreen and remove all previous routes from the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) =>
          false, // This predicate ensures all previous routes are removed
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aklny Home'),
        backgroundColor:
            AppColors.cadillacCoupe, // Use primary accent for AppBar
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.unbleached,
            ), // Icon color
            onPressed: () => _logout(context), // Call the logout method
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the Aklny App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.avocadoPeel,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              icon: Icon(Icons.person, color: AppColors.unbleached),
              label: Text(
                'View/Edit Profile',
                style: TextStyle(color: AppColors.unbleached, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.cadillacCoupe, // Use primary accent for button
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
