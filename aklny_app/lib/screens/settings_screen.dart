// lib/screens/settings_screen.dart
// This screen provides a redesigned list of settings and account-related options,
// with a focus on clear categorization and interactive elements, now using reusable components.

import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../utils/auth_utils.dart'; // For logout utility
import '../utils/ui_utils.dart'; // For SnackBar utility

// Screen imports for navigation
import 'profile_screen.dart';
import 'orders_screen.dart';

// NEW WIDGET IMPORTS
import '../widgets/auth/change_password_dialog_widget.dart';
import '../widgets/settings/settings_section_header.dart';
import '../widgets/settings/settings_navigation_tile.dart';
import '../widgets/settings/settings_toggle_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Placeholder for toggle states (will be managed by user preferences later)
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false; // Example: light mode by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.unbleached),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cadillacCoupe,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.unbleached),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Go back',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Account Settings Section ---
            const SettingsSectionHeader(title: 'Account Settings'),
            SettingsNavigationTile(
              icon: Icons.person_outline,
              title: 'Account Info',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            SettingsNavigationTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              onTap: () {
                UiUtils.showSnackBar(
                  context,
                  'Address book management coming soon!',
                );
              },
            ),
            SettingsNavigationTile(
              icon: Icons.email_outlined,
              title: 'Change Email',
              onTap: () {
                UiUtils.showSnackBar(
                  context,
                  'Email change feature coming soon!',
                );
              },
            ),
            SettingsNavigationTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext dialogContext) {
                    return const ChangePasswordDialog(); // Using the new dialog widget
                  },
                );
              },
            ),
            SettingsNavigationTile(
              icon: Icons.credit_card_outlined,
              title: 'Manage Cards',
              onTap: () {
                UiUtils.showSnackBar(context, 'Card management coming soon!');
              },
            ),
            SettingsNavigationTile(
              icon: Icons.receipt_long,
              title: 'My Orders',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
            ),
            const SizedBox(height: 16), // Spacer between sections
            // --- App Preferences Section ---
            const SettingsSectionHeader(title: 'App Preferences'),
            SettingsToggleTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  UiUtils.showSnackBar(
                    context,
                    'Notifications ${_notificationsEnabled ? "enabled" : "disabled"}.',
                  );
                  // TODO: Save preference to local storage / backend
                });
              },
            ),
            SettingsToggleTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                  UiUtils.showSnackBar(
                    context,
                    'Dark Mode ${_darkModeEnabled ? "enabled" : "disabled"}.',
                  );
                  // TODO: Implement actual theme change logic
                });
              },
            ),
            SettingsNavigationTile(
              icon: Icons.language,
              title: 'Language',
              trailing: Text(
                'English',
                style: TextStyle(color: AppColors.avocadoPeel.withOpacity(0.7)),
              ),
              onTap: () {
                UiUtils.showSnackBar(
                  context,
                  'Language selection coming soon!',
                );
              },
            ),
            SettingsNavigationTile(
              icon: Icons.location_on_outlined,
              title: 'Country',
              trailing: Text(
                'Egypt',
                style: TextStyle(color: AppColors.avocadoPeel.withOpacity(0.7)),
              ),
              onTap: () {
                UiUtils.showSnackBar(context, 'Country selection coming soon!');
              },
            ),
            const SizedBox(height: 16), // Spacer between sections
            // --- Legal & Support Section ---
            const SettingsSectionHeader(title: 'Legal & Support'),
            SettingsNavigationTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {
                UiUtils.showSnackBar(context, 'Contact support or view FAQs.');
              },
            ),
            SettingsNavigationTile(
              icon: Icons.security,
              title: 'Privacy Policy',
              onTap: () {
                UiUtils.showSnackBar(context, 'View privacy policy.');
              },
            ),
            SettingsNavigationTile(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                UiUtils.showSnackBar(context, 'View terms of service.');
              },
            ),
            const SizedBox(height: 30), // Spacer before logout button
            // --- Logout Button ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10.0,
              ),
              child: ElevatedButton.icon(
                onPressed: () => AuthUtils.logoutAndNavigateToLogin(
                  context,
                ), // Using AuthUtils
                icon: Icon(Icons.logout, color: AppColors.cadillacCoupe),
                label: Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.cadillacCoupe,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.unbleached, // Light background
                  foregroundColor: AppColors.cadillacCoupe, // Text color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: AppColors.cadillacCoupe,
                      width: 1.5,
                    ), // Distinct border
                  ),
                  elevation: 0, // No shadow for this button
                ),
              ),
            ),
            const SizedBox(height: 20), // Final padding
          ],
        ),
      ),
    );
  }
}
