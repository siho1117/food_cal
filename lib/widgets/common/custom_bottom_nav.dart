// lib/widgets/common/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'dart:ui';

/// Design constants for icon-only segmented control navigation
/// Follows AppWidgetDesign token system from theme.dart
class _SegmentedNavDesign {
  // ═══════════════════════════════════════════════════════════════
  // DIMENSIONS
  // ═══════════════════════════════════════════════════════════════
  
  /// Total navigation bar height
  static const double navHeight = 66.0;
  
  /// Height of the sliding selector
  static const double selectorHeight = 54.0;
  
  /// Border radius for nav container (matches AppWidgetDesign)
  static const double navBorderRadius = 28.0;
  
  /// Border radius for sliding selector
  static const double selectorBorderRadius = 22.0;
  
  /// Border width (matches AppWidgetDesign.cardBorderWidth)
  static const double borderWidth = 4.0;
  
  /// Internal padding of nav container
  static const double navPadding = 6.0;
  
  /// Gap between nav items
  static const double itemGap = 6.0;
  
  /// Icon size for all nav items
  static const double iconSize = 26.0;
  
  /// Bottom margin (distance from screen bottom)
  static const double bottomMargin = 20.0;
  
  /// Horizontal margin (distance from screen edges)
  static const double horizontalMargin = 12.0;
  
  // ═══════════════════════════════════════════════════════════════
  // COLORS - LIGHT MODE
  // ═══════════════════════════════════════════════════════════════
  
  /// Frosted glass background color (light mode)
  static const Color lightBgColor = Colors.white;
  static const double lightBgOpacity = 0.15;
  
  /// Border color (light mode, matches AppWidgetDesign)
  static const Color lightBorderColor = Colors.white;
  static const double lightBorderOpacity = 0.5;
  
  /// Sliding selector background (light mode)
  static const Color lightSelectorColor = Colors.white;
  static const double lightSelectorOpacity = 0.95;
  
  /// Inactive icon color (light mode)
  static const Color lightInactiveIconColor = Colors.white;
  static const double lightInactiveIconOpacity = 0.7;
  
  /// Active icon color (light mode) - primaryBlue
  static const Color lightActiveIconColor = Color(0xFF0D4033);
  
  // ═══════════════════════════════════════════════════════════════
  // COLORS - DARK MODE
  // ═══════════════════════════════════════════════════════════════
  
  /// Frosted glass background color (dark mode)
  static const Color darkBgColor = Color(0xFF1A2332);
  static const double darkBgOpacity = 0.85;
  
  /// Border color (dark mode)
  static const Color darkBorderColor = Colors.white;
  static const double darkBorderOpacity = 0.1;
  
  /// Sliding selector background (dark mode)
  static const Color darkSelectorColor = Color(0xFF2D3748);
  static const double darkSelectorOpacity = 0.95;
  
  /// Inactive icon color (dark mode)
  static const Color darkInactiveIconColor = Color(0xFF9CA3AF);
  static const double darkInactiveIconOpacity = 0.5;
  
  /// Active icon color (dark mode) - goldAccent
  static const Color darkActiveIconColor = Color(0xFFCF9340);
  
  // ═══════════════════════════════════════════════════════════════
  // ANIMATION
  // ═══════════════════════════════════════════════════════════════
  
  /// Duration for selector sliding animation
  static const Duration slideDuration = Duration(milliseconds: 400);
  
  /// Curve for selector sliding animation
  static const Curve slideCurve = Curves.easeInOutCubic;
  
  /// Duration for icon color change
  static const Duration iconDuration = Duration(milliseconds: 300);
  
  // ═══════════════════════════════════════════════════════════════
  // EFFECTS
  // ═══════════════════════════════════════════════════════════════
  
  /// Backdrop blur amount for frosted glass effect
  static const double backdropBlur = 20.0;
  
  /// Shadow blur radius
  static const double shadowBlur = 30.0;
  
  /// Shadow offset
  static const Offset shadowOffset = Offset(0, 8);
  
  /// Shadow opacity (light mode)
  static const double shadowOpacityLight = 0.1;
  
  /// Shadow opacity (dark mode)
  static const double shadowOpacityDark = 0.3;
}

/// Icon-only segmented control bottom navigation bar
/// 
/// A minimal, iOS-inspired navigation bar with:
/// - Frosted glass background with backdrop blur
/// - Sliding white selector for active state
/// - 5 navigation items (Home, Progress, Camera, Summary, Settings)
/// - No text labels - icons only for maximum minimalism
/// - Theme-aware (light/dark mode support)
/// - Smooth animations using cubic easing
/// 
/// Usage:
/// ```dart
/// CustomBottomNav(
///   currentIndex: _currentIndex,
///   onTap: (index) {
///     setState(() {
///       _currentIndex = index;
///     });
///   },
/// )
/// ```
class CustomBottomNav extends StatefulWidget {
  /// Current active navigation index (0-4)
  final int currentIndex;
  
  /// Callback when a navigation item is tapped
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Theme-aware colors
    final bgColor = isDark
        ? _SegmentedNavDesign.darkBgColor.withValues(
            alpha: _SegmentedNavDesign.darkBgOpacity,
          )
        : _SegmentedNavDesign.lightBgColor.withValues(
            alpha: _SegmentedNavDesign.lightBgOpacity,
          );

    final borderColor = isDark
        ? _SegmentedNavDesign.darkBorderColor.withValues(
            alpha: _SegmentedNavDesign.darkBorderOpacity,
          )
        : _SegmentedNavDesign.lightBorderColor.withValues(
            alpha: _SegmentedNavDesign.lightBorderOpacity,
          );

    final selectorColor = isDark
        ? _SegmentedNavDesign.darkSelectorColor.withValues(
            alpha: _SegmentedNavDesign.darkSelectorOpacity,
          )
        : _SegmentedNavDesign.lightSelectorColor.withValues(
            alpha: _SegmentedNavDesign.lightSelectorOpacity,
          );

    final inactiveIconColor = isDark
        ? _SegmentedNavDesign.darkInactiveIconColor.withValues(
            alpha: _SegmentedNavDesign.darkInactiveIconOpacity,
          )
        : _SegmentedNavDesign.lightInactiveIconColor.withValues(
            alpha: _SegmentedNavDesign.lightInactiveIconOpacity,
          );

    final activeIconColor = isDark
        ? _SegmentedNavDesign.darkActiveIconColor
        : _SegmentedNavDesign.lightActiveIconColor;

    return Container(
      margin: const EdgeInsets.only(
        left: _SegmentedNavDesign.horizontalMargin,
        right: _SegmentedNavDesign.horizontalMargin,
        bottom: _SegmentedNavDesign.bottomMargin,
      ),
      height: _SegmentedNavDesign.navHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_SegmentedNavDesign.navBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark
                  ? _SegmentedNavDesign.shadowOpacityDark
                  : _SegmentedNavDesign.shadowOpacityLight,
            ),
            blurRadius: _SegmentedNavDesign.shadowBlur,
            offset: _SegmentedNavDesign.shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_SegmentedNavDesign.navBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _SegmentedNavDesign.backdropBlur,
            sigmaY: _SegmentedNavDesign.backdropBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(_SegmentedNavDesign.navBorderRadius),
              border: Border.all(
                color: borderColor,
                width: _SegmentedNavDesign.borderWidth,
              ),
            ),
            padding: const EdgeInsets.all(_SegmentedNavDesign.navPadding),
            child: Stack(
              children: [
                // Sliding selector background
                _buildSlidingSelector(selectorColor),
                
                // Navigation items
                Row(
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      index: 0,
                      isActive: widget.currentIndex == 0,
                      inactiveColor: inactiveIconColor,
                      activeColor: activeIconColor,
                      semanticLabel: 'Home',
                    ),
                    _buildNavItem(
                      icon: Icons.trending_up_rounded,
                      index: 1,
                      isActive: widget.currentIndex == 1,
                      inactiveColor: inactiveIconColor,
                      activeColor: activeIconColor,
                      semanticLabel: 'Progress',
                    ),
                    _buildNavItem(
                      icon: Icons.camera_alt_rounded,
                      index: 2,
                      isActive: widget.currentIndex == 2,
                      inactiveColor: inactiveIconColor,
                      activeColor: activeIconColor,
                      semanticLabel: 'Scan Food',
                    ),
                    _buildNavItem(
                      icon: Icons.assessment_rounded,
                      index: 3,
                      isActive: widget.currentIndex == 3,
                      inactiveColor: inactiveIconColor,
                      activeColor: activeIconColor,
                      semanticLabel: 'Summary',
                    ),
                    _buildNavItem(
                      icon: Icons.settings_rounded,
                      index: 4,
                      isActive: widget.currentIndex == 4,
                      inactiveColor: inactiveIconColor,
                      activeColor: activeIconColor,
                      semanticLabel: 'Settings',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the animated sliding selector that moves behind the active item
  Widget _buildSlidingSelector(Color selectorColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate selector width (total width divided by 5 items minus gaps)
        final totalGaps = _SegmentedNavDesign.itemGap * 4; // 4 gaps between 5 items
        final availableWidth = constraints.maxWidth - totalGaps;
        final itemWidth = availableWidth / 5;
        
        // Calculate selector position based on current index
        final selectorLeft = (itemWidth + _SegmentedNavDesign.itemGap) * widget.currentIndex;

        return AnimatedPositioned(
          duration: _SegmentedNavDesign.slideDuration,
          curve: _SegmentedNavDesign.slideCurve,
          left: selectorLeft,
          top: 0,
          child: Container(
            width: itemWidth,
            height: _SegmentedNavDesign.selectorHeight,
            decoration: BoxDecoration(
              color: selectorColor,
              borderRadius: BorderRadius.circular(_SegmentedNavDesign.selectorBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build individual navigation item with icon
  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
    required Color inactiveColor,
    required Color activeColor,
    required String semanticLabel,
  }) {
    return Expanded(
      child: Semantics(
        label: semanticLabel,
        button: true,
        selected: isActive,
        child: GestureDetector(
          onTap: () => widget.onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: _SegmentedNavDesign.selectorHeight,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: _SegmentedNavDesign.iconDuration,
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: _SegmentedNavDesign.iconSize,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}