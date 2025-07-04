// lib/screens/account_screen.dart
// This screen serves as the main entry point for user account management,
// featuring a redesigned profile summary and a list-based navigation for account options.

import 'package:flutter/material.dart';
import '../api_service/user_api_service.dart';
import '../models/user_model.dart';
import '../constants/theme_constants.dart';
// To navigate to the detailed profile editor
import 'settings_screen.dart'; // To navigate to the settings options
import 'orders_screen.dart'; // To navigate to My Orders screen
import '../utils/auth_utils.dart'; // For logout utility (centralized)

// NEW WIDGET IMPORTS
import '../widgets/profile/profile_header_summary.dart';
import '../widgets/aklny_pro_card.dart';
import '../widgets/account_option_tile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final UserApiService _userApiService = UserApiService();
  User? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _userApiService.getMyProfile();
      setState(() {
        _userProfile = user;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      // Use the centralized AuthUtils for logout
      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('forbidden')) {
        AuthUtils.logoutAndNavigateToLogin(context);
      }
      print('Error fetching profile for AccountScreen: $_errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached,
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(color: AppColors.unbleached),
        ),
        centerTitle: true,
        backgroundColor: AppColors.cadillacCoupe,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.unbleached),
            onPressed: () async {
              // Await the result to refresh profile data if changes were made in settings (e.g., password change triggers logout)
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              _fetchUserProfile(); // Refresh data in case of changes
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.unbleached),
            onPressed: () =>
                AuthUtils.logoutAndNavigateToLogin(context), // Using AuthUtils
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.cadillacCoupe),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.cadillacCoupe,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Error loading profile: $_errorMessage',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.avocadoPeel,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchUserProfile,
                      icon: Icon(Icons.refresh, color: AppColors.unbleached),
                      label: Text(
                        'Retry',
                        style: TextStyle(color: AppColors.unbleached),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cadillacCoupe,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _userProfile == null
          ? Center(
              child: Text(
                'No profile data available.',
                style: TextStyle(fontSize: 18, color: AppColors.avocadoPeel),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- Profile Header Section (using new widget) ---
                  ProfileHeaderSummary(
                    userProfile: _userProfile!,
                    onProfileUpdated:
                        _fetchUserProfile, // Pass callback to refresh
                  ),
                  const SizedBox(height: 20),

                  // --- Aklny Pro Promotional Card (using new widget) ---
                  const AklnyProCard(),
                  const SizedBox(height: 24),

                  // --- Account Options List (using new widget) ---
                  AccountOptionTile(
                    icon: Icons.star_border,
                    title: 'My Reviews',
                    trailing: Text(
                      '0 Reviews',
                      style: TextStyle(
                        color: AppColors.avocadoPeel.withOpacity(0.7),
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing your reviews...'),
                        ),
                      );
                      // TODO: Navigate to Reviews screen later
                    },
                  ),
                  AccountOptionTile(
                    icon: Icons.receipt_long,
                    title: 'Your Orders',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  AccountOptionTile(
                    icon: Icons.payments,
                    title: 'Aklny Pay',
                    trailing: Text(
                      'EGP 0.00',
                      style: TextStyle(
                        color: AppColors.avocadoPeel.withOpacity(0.7),
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aklny Pay feature coming soon!'),
                        ),
                      );
                    },
                  ),
                  AccountOptionTile(
                    icon: Icons.person_add,
                    title: 'Refer a friend',
                    trailing: Text(
                      'Get EGP 60',
                      style: TextStyle(color: AppColors.orangeCrush),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Referral program details coming soon!',
                          ),
                        ),
                      );
                    },
                  ),
                  AccountOptionTile(
                    icon: Icons.local_activity,
                    title: 'My Vouchers',
                    trailing: Text(
                      '0',
                      style: TextStyle(
                        color: AppColors.avocadoPeel.withOpacity(0.7),
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing your vouchers...'),
                        ),
                      );
                    },
                  ),
                  AccountOptionTile(
                    icon: Icons.help_outline,
                    title: 'Get Help',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ); // Links to settings for now
                    },
                  ),
                  AccountOptionTile(
                    icon: Icons.info_outline,
                    title: 'About App',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Aklny App info...')),
                      );
                      // TODO: Show AboutDialog or navigate to About screen
                    },
                  ),
                  const SizedBox(height: 20), // Space at bottom
                ],
              ),
            ),
    );
  }
}
