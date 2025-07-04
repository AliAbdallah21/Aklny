// lib/screens/profile_screen.dart
// This file defines the User Profile Screen for the Aklny app,
// now using extracted components for better readability and maintainability.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for TextInputFormatter

import '../api_service/user_api_service.dart'; // For fetching/updating profile
import '../models/user_model.dart'; // For the User model
import '../constants/theme_constants.dart'; // For AppColors
import '../utils/ui_utils.dart'; // For SnackBar utility
import '../utils/auth_utils.dart'; // For logout utility

// NEW WIDGET IMPORTS
import '../widgets/profile/profile_info_field.dart'; // Import the new ProfileInfoField widget
import '../widgets/profile/profile_editable_field.dart'; // Import the new ProfileEditableField widget

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
  final TextEditingController _addressStreetController =
      TextEditingController();
  final TextEditingController _addressCityController = TextEditingController();
  final TextEditingController _addressCountryController =
      TextEditingController();

  // Controllers for change password dialog
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

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
        _fullNameController.text = user.fullName ?? '';
        _phoneNumberController.text = user.phoneNumber ?? '';
        _addressStreetController.text = user.addressStreet ?? '';
        _addressCityController.text = user.addressCity ?? '';
        _addressCountryController.text = user.addressCountry ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      UiUtils.showSnackBar(
        context,
        _errorMessage!,
        isError: true,
      ); // Use SnackBar utility
      // If token is invalid/expired, navigate to login using the new AuthUtils
      if (e.toString().contains('Unauthorized') ||
          e.toString().contains('forbidden')) {
        AuthUtils.logoutAndNavigateToLogin(context);
      }
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
    // Compare current controller text with existing user profile data (handling nulls)
    if (_fullNameController.text.trim() != (_userProfile?.fullName ?? '')) {
      updateData['fullName'] = _fullNameController.text.trim();
    }
    if (_phoneNumberController.text.trim() !=
        (_userProfile?.phoneNumber ?? '')) {
      updateData['phoneNumber'] = _phoneNumberController.text.trim();
    }
    if (_addressStreetController.text.trim() !=
        (_userProfile?.addressStreet ?? '')) {
      updateData['addressStreet'] = _addressStreetController.text.trim();
    }
    if (_addressCityController.text.trim() !=
        (_userProfile?.addressCity ?? '')) {
      updateData['addressCity'] = _addressCityController.text.trim();
    }
    if (_addressCountryController.text.trim() !=
        (_userProfile?.addressCountry ?? '')) {
      updateData['addressCountry'] = _addressCountryController.text.trim();
    }

    if (updateData.isEmpty) {
      setState(() {
        _errorMessage = 'No changes to save.';
        _isLoading = false;
        _isEditing = false; // Exit editing mode if no changes
      });
      UiUtils.showSnackBar(
        context,
        'No changes to save.',
        isError: true,
      ); // Use SnackBar utility
      return;
    }

    try {
      final updatedUser = await _userApiService.updateMyProfile(updateData);
      setState(() {
        _userProfile = updatedUser;
        _isEditing = false; // Exit editing mode
        UiUtils.showSnackBar(
          context,
          'Profile updated successfully!',
          isError: false,
        ); // Use SnackBar utility
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      UiUtils.showSnackBar(
        context,
        _errorMessage!,
        isError: true,
      ); // Use SnackBar utility
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
          title: Text(
            'Change Password',
            style: TextStyle(color: AppColors.avocadoPeel),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.cadillacCoupe),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cadillacCoupe,
                foregroundColor: AppColors.unbleached,
              ),
              onPressed: _isLoading ? null : _changePassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.unbleached)
                  : const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  // Handles password change logic
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      UiUtils.showSnackBar(
        context,
        'New passwords do not match.',
        isError: true,
      ); // Use SnackBar utility
      return;
    }
    if (_newPasswordController.text.length < 8) {
      UiUtils.showSnackBar(
        context,
        'New password must be at least 8 characters long.',
        isError: true,
      ); // Use SnackBar utility
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
      UiUtils.showSnackBar(
        context,
        message,
        isError: false,
      ); // Use SnackBar utility
    } catch (e) {
      UiUtils.showSnackBar(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      ); // Use SnackBar utility
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
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor:
            AppColors.cadillacCoupe, // Use primary accent for AppBar
        actions: [
          if (!_isLoading && _userProfile != null)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.cancel : Icons.edit,
                color: AppColors.unbleached,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    // If exiting edit mode without saving, reset controllers
                    _fullNameController.text = _userProfile?.fullName ?? '';
                    _phoneNumberController.text =
                        _userProfile?.phoneNumber ?? '';
                    _addressStreetController.text =
                        _userProfile?.addressStreet ?? '';
                    _addressCityController.text =
                        _userProfile?.addressCity ?? '';
                    _addressCountryController.text =
                        _userProfile?.addressCountry ?? '';
                  }
                });
              },
              tooltip: _isEditing ? 'Cancel Editing' : 'Edit Profile',
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
                      'Error: $_errorMessage',
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Profile Picture and Name/Role
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.orangeCrush.withOpacity(0.3),
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: AppColors.cadillacCoupe,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userProfile!.fullName != null &&
                            _userProfile!.fullName!.isNotEmpty
                        ? _userProfile!.fullName!
                        : _userProfile!.email,
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
                  const Divider(
                    height: 40,
                    thickness: 1,
                    color: AppColors.squashBlossom,
                  ),

                  // Profile Details Section (View or Edit Mode)
                  if (_isEditing) ...[
                    ProfileEditableField(
                      // Using new widget
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    ProfileEditableField(
                      // Using new widget
                      controller: _phoneNumberController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    ProfileEditableField(
                      // Using new widget
                      controller: _addressStreetController,
                      label: 'Street Address',
                      icon: Icons.location_on,
                    ),
                    ProfileEditableField(
                      // Using new widget
                      controller: _addressCityController,
                      label: 'City',
                      icon: Icons.location_city,
                    ),
                    ProfileEditableField(
                      // Using new widget
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
                          ? const CircularProgressIndicator(
                              color: AppColors.unbleached,
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    ProfileInfoField(
                      // Using new widget
                      label: 'Email',
                      value: _userProfile!.email,
                      icon: Icons.email,
                    ),
                    ProfileInfoField(
                      // Using new widget
                      label: 'Phone Number',
                      value: _userProfile!.phoneNumber ?? 'N/A',
                      icon: Icons.phone,
                    ),
                    if (_userProfile!.addressStreet != null &&
                        _userProfile!.addressStreet!.isNotEmpty)
                      ProfileInfoField(
                        // Using new widget
                        label: 'Street Address',
                        value: _userProfile!.addressStreet!,
                        icon: Icons.location_on,
                      ),
                    if (_userProfile!.addressCity != null &&
                        _userProfile!.addressCity!.isNotEmpty)
                      ProfileInfoField(
                        // Using new widget
                        label: 'City',
                        value: _userProfile!.addressCity!,
                        icon: Icons.location_city,
                      ),
                    if (_userProfile!.addressCountry != null &&
                        _userProfile!.addressCountry!.isNotEmpty)
                      ProfileInfoField(
                        // Using new widget
                        label: 'Country',
                        value: _userProfile!.addressCountry!,
                        icon: Icons.public,
                      ),
                    const SizedBox(height: 30),
                  ],

                  // Change Password Button
                  ElevatedButton.icon(
                    onPressed: _showChangePasswordDialog,
                    icon: Icon(
                      Icons.vpn_key_rounded,
                      color: AppColors.unbleached,
                    ),
                    label: Text(
                      'Change Password',
                      style: TextStyle(
                        color: AppColors.unbleached,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeCrush,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
