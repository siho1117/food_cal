// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../config/design_system/theme.dart';
import '../config/constants/app_constants.dart';  // ADDED: Import for constants

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isCameraOverlayOpen; // Track camera overlay state
  final Function(int) onTap;
  final Function()? onCameraCapture; // This is now optional and not used directly

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.isCameraOverlayOpen, // Required parameter
    required this.onTap,
    this.onCameraCapture,
  });

  @override
  Widget build(BuildContext context) {
    // Use colors from the theme instead of hardcoded values
    const navBarColor = AppTheme.primaryBlue; // Primary color from theme
    const selectedButtonColor = AppTheme.accentColor; // Accent color from theme

    // Determine the visual index for the curved navigation bar
    // If camera overlay is open, show camera as selected (index 2)
    // Otherwise, use the actual currentIndex
    final visualIndex = isCameraOverlayOpen ? 2 : currentIndex;

    return CurvedNavigationBar(
      index: visualIndex, // Use visualIndex instead of currentIndex
      height: AppConstants.bottomNavHeight, // FIXED: Use constant instead of hardcoded 75
      backgroundColor: Colors.transparent,
      color: navBarColor, // Use theme color for nav bar 
      buttonBackgroundColor: selectedButtonColor, // Use accent color for selected button
      animationCurve: AppConstants.animationCurve, // FIXED: Use constant instead of hardcoded curve
      animationDuration: AppConstants.bottomNavAnimationDuration, // FIXED: Use constant instead of hardcoded 400ms
      items: [
        _buildNavItem(Icons.home_rounded, 'Home', 0, visualIndex),
        _buildNavItem(Icons.bar_chart_rounded, 'Progress', 1, visualIndex),
        _buildCameraNavItem(isCameraOverlayOpen),
        _buildNavItem(Icons.fitness_center_rounded, 'Exercise', 3, visualIndex),
        _buildNavItem(Icons.settings_rounded, 'Settings', 4, visualIndex),
      ],
      onTap: onTap,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int visualIndex) {
    final bool isSelected = visualIndex == index;

    return Padding(
      padding: isSelected
          ? const EdgeInsets.all(AppConstants.paddingSmall + 2) // FIXED: Use constant-based padding
          : const EdgeInsets.fromLTRB(
              AppConstants.paddingSmall + 2, // FIXED: Use constant instead of hardcoded 10
              AppConstants.paddingMedium,     // FIXED: Use constant instead of hardcoded 16
              AppConstants.paddingSmall + 2,  // FIXED: Use constant instead of hardcoded 10
              5), // Keep small bottom padding for visual balance
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSelected ? AppConstants.iconSizeLarge : AppConstants.iconSizeMedium, // FIXED: Use constants
            color: isSelected ? Colors.white : Colors.white70,
          ),
          if (!isSelected) ...[
            const SizedBox(height: 2), // Small spacing between icon and text
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: AppConstants.fontSizeSmall, // FIXED: Use constant instead of hardcoded size
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraNavItem(bool isCameraOpen) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall), // FIXED: Use constant
      child: Icon(
        Icons.camera_alt_rounded,
        size: AppConstants.iconSizeXLarge, // FIXED: Use constant instead of hardcoded size
        color: isCameraOpen ? AppTheme.primaryBlue : Colors.white,
      ),
    );
  }
}