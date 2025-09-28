// lib/widgets/common/custom_bottom_nav.dart
// ✅ SIMPLIFIED: Using hard-coded values to eliminate import issues
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
    // ✅ SIMPLIFIED: Hard-coded theme colors to avoid import issues
    const navBarColor = Color(0xFF0D4033);      // AppTheme.primaryBlue
    const selectedButtonColor = Color(0xFF8B3A3A); // AppTheme.accentColor

    // Determine the visual index for the curved navigation bar
    // If camera overlay is open, show camera as selected (index 2)
    // Otherwise, use the actual currentIndex
    final visualIndex = isCameraOverlayOpen ? 2 : currentIndex;

    return CurvedNavigationBar(
      index: visualIndex, // Use visualIndex instead of currentIndex
      height: 75.0, // Hard-coded instead of AppConstants.bottomNavHeight
      backgroundColor: Colors.transparent,
      color: navBarColor, // Use theme color for nav bar 
      buttonBackgroundColor: selectedButtonColor, // Use accent color for selected button
      animationCurve: Curves.easeInOut, // Hard-coded instead of AppConstants.animationCurve
      animationDuration: const Duration(milliseconds: 400), // Hard-coded duration
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
          ? const EdgeInsets.all(10.0) // Hard-coded padding
          : const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 5.0), // Hard-coded padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSelected ? 24.0 : 20.0, // Hard-coded icon sizes
            color: isSelected ? Colors.white : Colors.white70,
          ),
          if (!isSelected) ...[
            const SizedBox(height: 2), // Small spacing between icon and text
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.0, // Hard-coded font size
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
      padding: const EdgeInsets.all(8.0), // Hard-coded padding
      child: Icon(
        Icons.camera_alt_rounded,
        size: 28.0, // Hard-coded icon size
        color: isCameraOpen ? const Color(0xFF0D4033) : Colors.white, // Hard-coded colors
      ),
    );
  }
}