// lib/widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../config/design_system/theme.dart';

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
    final navBarColor = AppTheme.primaryBlue; // Primary color from theme
    final selectedButtonColor = AppTheme.accentColor; // Accent color from theme

    // Determine the visual index for the curved navigation bar
    // If camera overlay is open, show camera as selected (index 2)
    // Otherwise, use the actual currentIndex
    final visualIndex = isCameraOverlayOpen ? 2 : currentIndex;

    return CurvedNavigationBar(
      index: visualIndex, // Use visualIndex instead of currentIndex
      height: 75, // Maintained height
      backgroundColor: Colors.transparent,
      color: navBarColor, // Use theme color for nav bar 
      buttonBackgroundColor: selectedButtonColor, // Use accent color for selected button
      animationCurve: Curves.easeOutCubic,
      animationDuration: const Duration(milliseconds: 400),
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
          ? const EdgeInsets.all(10.0) // Regular padding for selected items
          : const EdgeInsets.fromLTRB(
              10, 16, 10, 5), // More top padding for unselected
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSelected ? 28 : 24,
            color: Colors.white,
          ),
          // Only show label if not selected (as selected items move up)
          if (!isSelected)
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraNavItem(bool isCameraOverlayOpen) {
    // If camera overlay is open, show a custom thin plus icon (selected state)
    if (isCameraOverlayOpen) {
      return Center(
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Horizontal line
              Container(
                width: 32,
                height: 2, // Very thin line
                color: Colors.white,
              ),
              // Vertical line
              Container(
                width: 2, // Very thin line
                height: 32,
                color: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // If camera overlay is not open, show the regular camera icon and text
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.camera_alt_rounded, // Camera icon
            size: 24,
            color: Colors.white,
          ),
          Text(
            'Camera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}