import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onSettingsTap;

  const CustomAppBar({
    Key? key,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  // Increase the height from 60 to 80
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBeige,
      // Add some extra top padding to make sure the content isn't too close to the status bar
      child: SafeArea(
        child: Padding(
          // Increase the vertical padding from 8.0 to 16.0
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // Center the row items vertically to use the increased height
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App name - always shown, larger font size
              const Text(
                'FOOD LLM',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 2,
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