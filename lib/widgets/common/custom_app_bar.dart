// lib/widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/theme_design.dart';
import '../../providers/theme_provider.dart';  // ✅ NEW: Import ThemeProvider

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;

  const CustomAppBar({
    super.key,
    this.currentPage = '',
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

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

    // ✅ NEW: Wrap with Consumer to get theme-adaptive colors
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // ✅ NEW: Get theme-adaptive text color
        final textColor = AppColors.getTextColorForTheme(
          themeProvider.selectedGradient,
        );

        return AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: preferredSize.height,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent, // ✅ Remove Material 3 tint
          scrolledUnderElevation: 0, // ✅ No elevation when scrolled
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                          color: textColor,  // ✅ CHANGED: Use theme-adaptive color
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  // Settings button removed - now accessible via bottom navigation
                  // Just an empty SizedBox to maintain the layout structure
                  const SizedBox(width: 28), // Same width as the old icon button
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}