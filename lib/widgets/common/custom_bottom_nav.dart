// lib/widgets/common/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../config/design_system/theme_design.dart';

/// Icon-only segmented control bottom navigation bar
/// 
/// Inspired by iPhone dock with 5 icons
/// - Adapts to light/dark theme
/// - Frosted glass background
/// - Sliding selector pill
/// - Selected icon: Solid fill (stands out)
/// - Unselected icons: Outlined (subtle)
/// - Center '+' icon: Always black with elevated circle for maximum visibility
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
    Icons.fitness_center_rounded,
    Icons.add_rounded,
    Icons.assessment_rounded,
    Icons.settings_rounded,
  ];

  static const List<String> _navLabels = [
    'Home',
    'Progress',
    'Quick Add',
    'Summary',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      height: 75.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.0),
              borderRadius: BorderRadius.circular(34.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(7.0),
            child: Stack(
              children: [
                // Sliding circular background
                AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  alignment: _getAlignmentForIndex(currentIndex),
                  child: FractionallySizedBox(
                    widthFactor: 1 / _navIcons.length,
                    child: Container(
                      height: 62.0,
                      alignment: Alignment.center,
                      child: Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A3342)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.1),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
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
    // Check if this is the center '+' button
    final bool isCenterButton = index == 2;

    // ✅ OPTION B: Always black for center button, theme-adaptive for others
    Color iconColor;

    if (isCenterButton) {
      // ✅ Center '+' button: ALWAYS black for maximum visibility
      iconColor = AppColors.textDark;
    } else {
      // Regular icons (non-center buttons)
      if (isActive) {
        iconColor = isDark ? Colors.white : const Color(0xFF1A2332);
      } else {
        iconColor = isDark
            ? Colors.white.withOpacity(0.5)
            : const Color(0xFF1A2332).withOpacity(0.4);
      }
    }

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(index);
          },
          borderRadius: BorderRadius.circular(28.0),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            height: 62.0,
            alignment: Alignment.center,
            // Minimum touch target size (48x48) with padding
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Elevated circle background (only for center '+' button)
                if (isCenterButton)
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      // Subtle black circle with low opacity
                      color: AppColors.textDark.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),

                // Icon with animation
                AnimatedSwitcher(
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
                    size: isActive ? 28.0 : 26.0,
                    color: iconColor,
                    weight: isActive ? 800 : 600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}