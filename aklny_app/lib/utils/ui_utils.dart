// lib/utils/ui_utils.dart
// This file contains common UI utility functions, like showing SnackBars.

import 'package:flutter/material.dart';

class UiUtils {
  /// Shows a SnackBar with a given message and color.
  /// [context] The BuildContext to show the SnackBar.
  /// [message] The text message to display.
  /// [isError] If true, the SnackBar will be red; otherwise, it will be green.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
