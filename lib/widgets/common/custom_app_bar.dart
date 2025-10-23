// lib/widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onSettingsTap;
  final String currentPage;

  const CustomAppBar({
    super.key,
    required this.onSettingsTap,
    this.currentPage = '',
  });

  @override
  Size get preferredSize => const Size.fromHeight(70); // Reduced from 100 to 70

  @override
  Widget build(BuildContext context) {
    // Make status bar icons white for better visibility on gradients
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons on Android
        statusBarBrightness: Brightness.dark, // White icons on iOS
      ),
    );

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Reduced vertical padding from 15 to 12
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App name - hardcoded, does NOT change with language
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Food LLM', // Brand name - stays the same in all languages
                    style: AppTypography.displayXLarge.copyWith(
                      fontSize: 38,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // Settings icon button
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
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