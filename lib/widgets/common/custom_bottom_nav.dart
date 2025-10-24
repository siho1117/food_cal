import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../../config/design_system/theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isCameraOverlayOpen;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.isCameraOverlayOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // iOS-style colors
    final backgroundColor = isDark
        ? AppTheme.primaryBlue.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);

    final buttonBackgroundColor = isDark
        ? AppTheme.goldAccent.withValues(alpha: 0.9)
        : AppTheme.coralAccent.withValues(alpha: 0.85);

    final iconColor = isDark 
        ? Colors.white70 
        : AppTheme.textDark.withValues(alpha: 0.6);
    
    final selectedIconColor = isDark ? Colors.white : AppTheme.primaryBlue;

    // Determine the visual index for the curved navigation bar
    // If camera overlay is open, show camera as selected (index 2)
    // Otherwise, use the actual currentIndex
    final visualIndex = isCameraOverlayOpen ? 2 : currentIndex;

    return Container(
      decoration: BoxDecoration(
        // iOS-style top border
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: visualIndex,
        height: 60.0,
        items: <Widget>[
          // Home (Index 0)
          Icon(
            Icons.home_rounded,
            size: 28,
            color: visualIndex == 0 ? selectedIconColor : iconColor,
          ),
          // Progress (Index 1)
          Icon(
            Icons.trending_up_rounded,
            size: 28,
            color: visualIndex == 1 ? selectedIconColor : iconColor,
          ),
          // Camera (Index 2 - Center/Highlighted)
          Icon(
            Icons.camera_alt_rounded,
            size: 32,
            color: Colors.white,
          ),
          // Summary (Index 3)
          Icon(
            Icons.assessment_rounded,
            size: 28,
            color: visualIndex == 3 ? selectedIconColor : iconColor,
          ),
          // Settings (Index 4)
          Icon(
            Icons.settings_rounded,
            size: 28,
            color: visualIndex == 4 ? selectedIconColor : iconColor,
          ),
        ],
        color: backgroundColor,
        buttonBackgroundColor: buttonBackgroundColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        onTap: onTap,
        letIndexChange: (index) => true,
      ),
    );
  }
}