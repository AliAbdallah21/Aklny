// lib/screens/profile_screen.dart
// This file defines the User Profile Screen for the Aklny app.

import 'package:flutter/material.dart';
import '../api_service/user_api_service.dart'; // For fetching/updating profile
import '../models/user_model.dart'; // For the User model
import '../utils/token_manager.dart'; // For logout functionality
import 'login_screen.dart'; // For logout navigation
import 'package:flutter/services.dart'; // RE-ENABLED: Needed for TextInputFormatter
import '../constants/theme_constants.dart'; // IMPORTANT: Import AppColors from central file

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserApiService _userApiService = UserApiService();
  User? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditing = false; // To toggle edit mode

  // Controllers for editable fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressStreetController = TextEditingController();
  final TextEditingController _addressCityController = TextEditingController();
  final TextEditingController _addressCountryController = TextEditingController();
  // Add other editable fields as needed from your user model

  // Controllers for change password dialog
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressStreetController.dispose();
    _addressCityController.dispose();
    _addressCountryController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // Fetches user profile from the backend
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await _userApiService.getMyProfile();
      setState(() {
        _userProfile = user;
        // Populate controllers with current data for editing
        _fullNameController.text = user.fullName;
        _phoneNumberController.text = user.phoneNumber;
        _addressStreetController.text = user.addressStreet ?? '';
        _addressCityController.text = user.addressCity ?? '';
        _addressCountryController.text = user.addressCountry ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      // If token is invalid/expired, navigate to login
      if (e.toString().contains('Unauthorized') || e.toString().contains('forbidden')) {
        _logoutAndNavigateToLogin();
      }
      print('Error fetching profile: $_errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handles profile update
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Collect updated data, only send changed fields
    Map<String, dynamic> updateData = {};
    if (_fullNameController.text.trim() != _userProfile?.fullName) {
      updateData['fullName'] = _fullNameController.text.trim();
    }
    if (_phoneNumberController.text.trim() != _userProfile?.phoneNumber) {
      updateData['phoneNumber'] = _phoneNumberController.text.trim();
    }
    if (_addressStreetController.text.trim() != (_userProfile?.addressStreet ?? '')) {
      updateData['addressStreet'] = _addressStreetController.text.trim();
    }
    if (_addressCityController.text.trim() != (_userProfile?.addressCity ?? '')) {
      updateData['addressCity'] = _addressCityController.text.trim();
    }
    if (_addressCountryController.text.trim() != (_userProfile?.addressCountry ?? '')) {
      updateData['addressCountry'] = _addressCountryController.text.trim();
    }

    if (updateData.isEmpty) {
      setState(() {
        _errorMessage = 'No changes to save.';
        _isLoading = false;
        _isEditing = false; // Exit editing mode if no changes
      });
      return;
    }

    try {
      final updatedUser = await _userApiService.updateMyProfile(updateData);
      setState(() {
        _userProfile = updatedUser;
        _isEditing = false; // Exit editing mode
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      print('Error updating profile: $_errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Shows a dialog for changing password
  Future<void> _showChangePasswordDialog() async {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password', style: TextStyle(color: AppColors.avocadoPeel)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppColors.cadillacCoupe)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cadillacCoupe, foregroundColor: AppColors.unbleached),
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading ? const CircularProgressIndicator(color: AppColors.unbleached) : const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  // Handles password change logic
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters long.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final message = await _userApiService.changeMyPassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper for logout
  Future<void> _logoutAndNavigateToLogin() async {
    await TokenManager.deleteToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Widget to display profile fields in view mode
  Widget _buildProfileField({required String label, required String value, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: AppColors.cadillacCoupe, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.avocadoPeel.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.avocadoPeel,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for editable text fields in edit mode
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // Keep this here for potential future use or if other fields need it
    bool isEnabled = true, // For non-editable fields like email
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.cadillacCoupe),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.unbleached.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.squashBlossom.withOpacity(0.5), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.cadillacCoupe, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder( // Style for disabled fields
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.squashBlossom.withOpacity(0.3), width: 1.0),
          ),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters, // Apply formatters if provided
        style: TextStyle(color: AppColors.avocadoPeel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.unbleached,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: AppColors.cadillacCoupe, // Use primary accent for AppBar
        actions: [
          if (!_isLoading && _userProfile != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit, color: AppColors.unbleached),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // If exiting edit mode without saving, reset controllers
                    _fullNameController.text = _userProfile!.fullName;
                    _phoneNumberController.text = _userProfile!.phoneNumber;
                    _addressStreetController.text = _userProfile!.addressStreet ?? '';
                    _addressCityController.text = _userProfile!.addressCity ?? '';
                    _addressCountryController.text = _userProfile!.addressCountry ?? '';
                  }
                });
              },
              tooltip: _isEditing ? 'Cancel Editing' : 'Edit Profile',
            ),
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.unbleached),
            onPressed: () => _logoutAndNavigateToLogin(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cadillacCoupe))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 80, color: AppColors.cadillacCoupe),
                        const SizedBox(height: 20),
                        Text(
                          'Error: $_errorMessage',
                          style: TextStyle(fontSize: 18, color: AppColors.avocadoPeel, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchUserProfile,
                          icon: Icon(Icons.refresh, color: AppColors.unbleached),
                          label: Text('Retry', style: TextStyle(color: AppColors.unbleached)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cadillacCoupe,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Profile Picture (Placeholder for now)
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.orangeCrush.withOpacity(0.3),
                              child: Icon(Icons.person, size: 80, color: AppColors.cadillacCoupe),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _userProfile!.fullName,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.avocadoPeel,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            _userProfile!.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.squashBlossom,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(height: 40, thickness: 1, color: AppColors.squashBlossom),

                          // Profile Details Section (View or Edit Mode)
                          if (_isEditing) ...[
                            _buildEditableField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              icon: Icons.person,
                            ),
                            _buildEditableField(
                              controller: _phoneNumberController,
                              label: 'Phone Number',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Re-added Filter here
                            ),
                            _buildEditableField(
                              controller: _addressStreetController,
                              label: 'Street Address',
                              icon: Icons.location_on,
                            ),
                            _buildEditableField(
                              controller: _addressCityController,
                              label: 'City',
                              icon: Icons.location_city,
                            ),
                            _buildEditableField(
                              controller: _addressCountryController,
                              label: 'Country',
                              icon: Icons.public,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cadillacCoupe,
                                foregroundColor: AppColors.unbleached,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: AppColors.unbleached)
                                  : const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            _buildProfileField(
                              label: 'Email',
                              value: _userProfile!.email,
                              icon: Icons.email,
                            ),
                            _buildProfileField( // Corrected: using _buildProfileField for display
                              label: 'Phone Number',
                              value: _userProfile!.phoneNumber,
                              icon: Icons.phone,
                            ),
                            if (_userProfile!.addressStreet != null && _userProfile!.addressStreet!.isNotEmpty)
                              _buildProfileField(
                                label: 'Street Address',
                                value: _userProfile!.addressStreet!,
                                icon: Icons.location_on,
                              ),
                            if (_userProfile!.addressCity != null && _userProfile!.addressCity!.isNotEmpty)
                              _buildProfileField(
                                label: 'City',
                                value: _userProfile!.addressCity!,
                                icon: Icons.location_city,
                              ),
                            if (_userProfile!.addressCountry != null && _userProfile!.addressCountry!.isNotEmpty)
                              _buildProfileField(
                                label: 'Country',
                                value: _userProfile!.addressCountry!,
                                icon: Icons.public,
                              ),
                            // Add other fields you want to display (e.g., restaurantName for seller)
                            // if (_userProfile!.role == 'seller' && _userProfile!.restaurantName != null)
                            //   _buildProfileField(label: 'Restaurant Name', value: _userProfile!.restaurantName!, icon: Icons.store),
                            const SizedBox(height: 30),
                          ],

                          // Change Password Button
                          ElevatedButton.icon(
                            onPressed: _showChangePasswordDialog,
                            icon: Icon(Icons.vpn_key_rounded, color: AppColors.unbleached),
                            label: Text('Change Password', style: TextStyle(color: AppColors.unbleached, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeCrush, // Use orange crush for this button
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
      // The closing curly braces/parentheses for `body` and `Scaffold` were likely missing here.
      // I've ensured the structure is correct in the code block above.
    );
  }
}
