import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/text_styles.dart'; // Import the new text styles

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onSettingsTap;

  const CustomAppBar({
    Key? key,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  // Increase the height to accommodate the taller Monoton font
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBeige,
      // Add some extra top padding to make sure the content isn't too close to the status bar
      child: SafeArea(
        child: Padding(
          // Increase the vertical padding for more space
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Center the row items vertically to use the increased height
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App name with Monoton font - using our new text style
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'FOOD LLM',
                    style: AppTextStyles.getHeadingStyle().copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 2,
                      height: 1.2, // Adjusted line height
                    ),
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