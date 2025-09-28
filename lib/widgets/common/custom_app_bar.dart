// lib/widgets/common/custom_app_bar.dart
// ✅ FIXED: Correct import paths for widgets/common/ location
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';      // Two levels up to reach config
import '../../config/design_system/text_styles.dart'; // Two levels up to reach config

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onSettingsTap;
  final String currentPage;

  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const CustomAppBar({
    super.key,
    required this.onSettingsTap,
    this.currentPage = '',
  });

  @override
  // Increase the height to accommodate the sub-heading
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBeige,
      // Add some extra top padding to make sure the content isn't too close to the status bar
      child: SafeArea(
        child: Padding(
          // Increase the vertical padding for more space
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Center the row items vertically to use the increased height
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App name with Monoton font and sub-heading - using our new text style
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main app title
                      Text(
                        'FOOD LLM',
                        style: AppTextStyles.getHeadingStyle().copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 2,
                          height: 1.2, // Adjusted line height
                        ),
                      ),
                      
                      // Sub-heading for current page
                      if (currentPage.isNotEmpty) ...[
                        const SizedBox(height: 2), // Space between title and sub-heading
                        Text(
                          currentPage,
                          style: AppTextStyles.getSubHeadingStyle().copyWith(
                            fontSize: 16,
                            color: Colors.grey[800],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Settings icon button
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: AppTheme.primaryBlue,
                  size: 28,
                ),
                onPressed: () => onSettingsTap(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}