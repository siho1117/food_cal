// lib/widgets/common/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isCameraOverlayOpen;
  final Function(int) onTap;
  final Function()? onCameraCapture;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.isCameraOverlayOpen,
    required this.onTap,
    this.onCameraCapture,
  });

  @override
  Widget build(BuildContext context) {
    const navBarColor = Color(0xFF0D4033);      // AppTheme.primaryBlue
    const selectedButtonColor = Color(0xFF8B3A3A); // AppTheme.accentColor

    // Determine the visual index for the curved navigation bar
    // If camera overlay is open, show camera as selected (index 2)
    // Otherwise, use the actual currentIndex
    final visualIndex = isCameraOverlayOpen ? 2 : currentIndex;

    return CurvedNavigationBar(
      index: visualIndex,
      height: 75.0,
      backgroundColor: Colors.transparent,
      color: navBarColor,
      buttonBackgroundColor: selectedButtonColor,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 400),
      items: [
        _buildNavItem(Icons.home_rounded, 'Home', 0, visualIndex),
        _buildNavItem(Icons.bar_chart_rounded, 'Progress', 1, visualIndex),
        _buildCameraNavItem(isCameraOverlayOpen),
        // REMOVED: Exercise tab (now part of Progress screen)
        _buildNavItem(Icons.analytics_outlined, 'Summary', 3, visualIndex),
      ],
      onTap: onTap,
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int visualIndex) {
    final bool isSelected = visualIndex == index;

    return Padding(
      padding: isSelected
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSelected ? 24.0 : 20.0,
            color: isSelected ? Colors.white : Colors.white70,
          ),
          if (!isSelected) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraNavItem(bool isCameraOpen) {
    return Padding(
      padding: isCameraOpen
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: isCameraOpen ? 24.0 : 20.0,
            color: isCameraOpen ? Colors.white : Colors.white70,
          ),
          if (!isCameraOpen) ...[
            const SizedBox(height: 4),
            const Text(
              'Camera',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}