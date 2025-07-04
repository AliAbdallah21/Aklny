// lib/widgets/search_bar_widget.dart
// A reusable search bar widget for browsing screens.

import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';
import '../../utils/ui_utils.dart'; // For SnackBar utility

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.unbleached,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.squashBlossom.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: AppColors.avocadoPeel.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for food or restaurant',
                hintStyle: TextStyle(
                  color: AppColors.avocadoPeel.withOpacity(0.5),
                ),
                border: InputBorder.none,
                isDense: true, // Reduce vertical space
              ),
              style: TextStyle(color: AppColors.avocadoPeel, fontSize: 16),
              onTap: () {
                // TODO: Implement actual search page navigation
                UiUtils.showSnackBar(context, 'Search page coming soon!');
              },
              readOnly: true, // Make it non-editable to act as a button
            ),
          ),
          Icon(
            Icons.tune,
            color: AppColors.avocadoPeel.withOpacity(0.7),
            size: 24,
          ), // Filter icon
        ],
      ),
    );
  }
}
