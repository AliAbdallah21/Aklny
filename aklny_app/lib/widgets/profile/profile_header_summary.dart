// lib/widgets/profile_header_summary.dart
// A reusable widget for displaying a user's profile summary on the account screen.

import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../constants/theme_constants.dart';
import '../../screens/profile_screen.dart'; // To navigate to the detailed profile editor

class ProfileHeaderSummary extends StatelessWidget {
  final User userProfile;
  final VoidCallback onProfileUpdated; // Callback to refresh data in parent

  const ProfileHeaderSummary({
    Key? key,
    required this.userProfile,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: AppColors.unbleached, // Keep background light
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.cadillacCoupe.withOpacity(0.1),
            child: Text(
              userProfile.fullName != null && userProfile.fullName!.isNotEmpty
                  ? userProfile.fullName![0].toUpperCase()
                  : (userProfile.email.isNotEmpty
                        ? userProfile.email[0].toUpperCase()
                        : 'A'), // Fallback to email's first letter or 'A'
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.cadillacCoupe,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile.fullName ??
                      userProfile.email, // Display full name or email
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.avocadoPeel,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.avocadoPeel.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.avocadoPeel.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userProfile.addressCountry != null &&
                              userProfile.addressCountry!.isNotEmpty
                          ? userProfile.addressCountry!
                          : 'Egypt', // Default or placeholder
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.avocadoPeel.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Edit Profile button
          IconButton(
            icon: Icon(
              Icons.edit_note,
              color: AppColors.cadillacCoupe,
              size: 30,
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              onProfileUpdated(); // Call callback to refresh parent data
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }
}
