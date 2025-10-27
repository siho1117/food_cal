// lib/widgets/common/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'dart:ui';

/// Icon-only segmented control bottom navigation bar
/// 
/// Inspired by iPhone dock with 5 icons
/// - Frosted glass background
/// - Sliding white selector pill
/// - Active icon becomes transparent (cutout effect)
/// - Inactive icons use theme text color
/// - All colors adapt to theme changes
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Navigation items
  static const List<IconData> _navIcons = [
    Icons.home_rounded,
    Icons.trending_up_rounded,
    Icons.camera_alt_rounded,
    Icons.assessment_rounded,
    Icons.settings_rounded,
  ];

  static const List<String> _navLabels = [
    'Home',
    'Progress',
    'Scan Food',
    'Summary',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    // Get theme text color for inactive icons
    final themeTextColor = Theme.of(context).textTheme.bodyLarge?.color 
        ?? (isDark ? Colors.white : Colors.black87);

    return Container(
      margin: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 20.0,
      ),
      height: 75.0, // Moderate reduction for better proportions
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A2332).withOpacity(0.85)
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(34.0),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 4.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 30.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(7.0),
            child: Stack(
              children: [
                // Sliding white selector pill
                AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  alignment: _getAlignmentForIndex(currentIndex),
                  child: FractionallySizedBox(
                    widthFactor: 1 / _navIcons.length,
                    child: Container(
                      height: 62.0,
                      margin: const EdgeInsets.symmetric(horizontal: 3.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(26.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Navigation items
                Row(
                  children: List.generate(
                    _navIcons.length,
                    (index) => Expanded(
                      child: _buildNavItem(
                        icon: _navIcons[index],
                        label: _navLabels[index],
                        index: index,
                        isActive: currentIndex == index,
                        iconColor: themeTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Map index to alignment (-1.0 to 1.0)
  Alignment _getAlignmentForIndex(int index) {
    // 0→-1.0, 1→-0.5, 2→0.0, 3→0.5, 4→1.0
    final double alignmentX = -1.0 + (index * 0.5);
    return Alignment(alignmentX, 0.0);
  }

  /// Build individual navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required Color iconColor,
  }) {
    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(26.0),
          child: Container(
            height: 62.0,
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Active: transparent (0.3), Inactive: solid (0.85)
              opacity: isActive ? 0.3 : 0.85,
              child: Icon(
                icon,
                size: 32.0, // Moderate reduction for better balance
                color: iconColor, // Uses theme text color
              ),
            ),
          ),
        ),
      ),
    );
  }
}