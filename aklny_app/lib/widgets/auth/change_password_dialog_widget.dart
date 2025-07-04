// lib/widgets/change_password_dialog_widget.dart
// A reusable dialog widget for changing a user's password.

import 'package:flutter/material.dart';
import '../../api_service/user_api_service.dart'; // For API calls
import '../../constants/theme_constants.dart'; // For AppColors
import '../../utils/ui_utils.dart'; // For SnackBar utility

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final UserApiService _userApiService = UserApiService();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      UiUtils.showSnackBar(
        context,
        'New passwords do not match.',
        isError: true,
      );
      return;
    }
    if (_newPasswordController.text.length < 8) {
      UiUtils.showSnackBar(
        context,
        'New password must be at least 8 characters long.',
        isError: true,
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
      Navigator.of(context).pop(); // Close dialog on success
      UiUtils.showSnackBar(context, message, isError: false);
    } catch (e) {
      UiUtils.showSnackBar(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
  }
}
