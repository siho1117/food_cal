// lib/widgets/common/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'dart:ui';

/// Icon-only segmented control bottom navigation bar
/// 
/// Inspired by iPhone dock with 5 icons
/// - Adapts to light/dark theme
/// - Frosted glass background
/// - Sliding selector pill
/// - Selected icon: Solid fill (stands out)
/// - Unselected icons: Outlined (subtle)
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

    return Container(
      margin: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 20.0,
      ),
      height: 75.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              // Theme-adaptive background
              color: isDark
                  ? const Color(0xFF1A2332).withOpacity(0.85) // Dark theme: dark glass
                  : Colors.white.withOpacity(0.25),             // Light theme: brighter white glass
              borderRadius: BorderRadius.circular(34.0),
              border: Border.all(
                // Theme-adaptive border
                color: isDark
                    ? Colors.white.withOpacity(0.1)   // Dark theme: subtle border
                    : Colors.white.withOpacity(0.6),  // Light theme: more visible border
                width: 4.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 30.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(7.0),
            child: Stack(
              children: [
                // Sliding selector pill
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
                        // Theme-adaptive pill
                        color: isDark
                            ? const Color(0xFF2A3342) // Dark theme: elevated dark
                            : Colors.white,            // Light theme: solid white
                        borderRadius: BorderRadius.circular(26.0),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)  // Dark theme: subtle border
                              : Colors.black.withOpacity(0.08), // Light theme: very subtle border
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.15 : 0.1),
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
                        isDark: isDark,
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
    required bool isDark,
  }) {
    // CRITICAL FIX: Different icon colors for light vs dark theme
    Color iconColor;
    
    if (isActive) {
      // Selected icon: High contrast solid color
      iconColor = isDark 
          ? Colors.white                    // Dark theme: solid white
          : const Color(0xFF1A2332);        // Light theme: solid dark
    } else {
      // Unselected icon: Dimmed based on theme
      iconColor = isDark
          ? Colors.white.withOpacity(0.5)   // Dark theme: dimmed white
          : const Color(0xFF1A2332).withOpacity(0.4); // Light theme: dimmed dark
    }

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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                icon,
                key: ValueKey('${icon}_$isActive'),
                size: isActive ? 28.0 : 26.0, // Selected is slightly bigger
                color: iconColor,
                weight: isActive ? 600 : 400, // Selected is bolder
              ),
            ),
          ),
        ),
      ),
    );
  }
}