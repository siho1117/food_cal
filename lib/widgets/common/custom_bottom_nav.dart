// lib/widgets/common/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'dart:ui';

/// Design constants for floating pill navigation bar
/// All values centralized for consistent styling and easy maintenance
class _FloatingPillDesign {
  // Bar dimensions
  static const double barHeight = 70.0;
  static const double barRadius = 28.0;
  static const double barMarginHorizontal = 12.0;
  static const double barMarginBottom = 20.0;
  
  // Icon sizes
  static const double iconSizeRegular = 28.0;
  static const double iconSizeCamera = 36.0;
  
  // Active indicator dots
  static const double dotSize = 4.0;
  static const double dotSizeCamera = 6.0;
  static const double dotGap = 3.0;
  static const double dotSpacing = 6.0;
  
  // Light mode colors
  static const Color lightBg = Colors.white;
  static const double lightBgOpacity = 0.85;
  static const Color lightBorder = Colors.white;
  static const double lightBorderOpacity = 0.3;
  static const Color lightIconUnselected = Color(0xFF6B7280);
  static const double lightIconOpacity = 0.6;
  static const Color lightIconSelected = Color(0xFFFF6B6B); // Coral
  
  // Dark mode colors
  static const Color darkBg = Color(0xFF1A2332);
  static const double darkBgOpacity = 0.85;
  static const Color darkBorder = Colors.white;
  static const double darkBorderOpacity = 0.1;
  static const Color darkIconUnselected = Color(0xFF9CA3AF);
  static const double darkIconOpacity = 0.5;
  static const Color darkIconSelected = Color(0xFFFFD93D); // Gold
  
  // Camera button gradient colors
  static const List<Color> cameraGradientLight = [
    Color(0xFFFF6B6B), // Coral
    Color(0xFFFFD93D), // Gold
  ];
  static const List<Color> cameraGradientDark = [
    Color(0xFFFFD93D), // Gold
    Color(0xFFA8E6CF), // Mint
  ];
  
  // Camera background circle
  static const double cameraCircleSize = 48.0;
  
  // Shadow and blur
  static const double backdropBlur = 20.0;
  static const double shadowBlur = 30.0;
  static const double shadowOpacity = 0.1;
  static const double shadowOpacityDark = 0.3;
  static const Offset shadowOffset = Offset(0, 8);
  
  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration iconBounceDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOutCubic;
}

/// Floating pill navigation bar with frosted glass effect
/// 
/// Features:
/// - Frosted glass background with backdrop blur
/// - Larger icons (28px regular, 36px camera)
/// - Camera as hero element with gradient background
/// - Active indicator dots
/// - Smooth animations (icon bounce, dot slide)
/// - Theme-aware (light/dark mode)
/// - Clean, modern iOS 16+ aesthetic
class CustomBottomNav extends StatefulWidget {
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
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;
  
  int _lastTappedIndex = -1;

  @override
  void initState() {
    super.initState();
    
    // Icon bounce animation controller
    _iconController = AnimationController(
      duration: _FloatingPillDesign.iconBounceDuration,
      vsync: this,
    );
    
    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    setState(() {
      _lastTappedIndex = index;
    });
    
    // Play bounce animation
    _iconController.forward().then((_) {
      _iconController.reverse();
    });
    
    // Call parent callback
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Background color
    final backgroundColor = isDark
        ? _FloatingPillDesign.darkBg.withValues(
            alpha: _FloatingPillDesign.darkBgOpacity,
          )
        : _FloatingPillDesign.lightBg.withValues(
            alpha: _FloatingPillDesign.lightBgOpacity,
          );

    // Border color
    final borderColor = isDark
        ? _FloatingPillDesign.darkBorder.withValues(
            alpha: _FloatingPillDesign.darkBorderOpacity,
          )
        : _FloatingPillDesign.lightBorder.withValues(
            alpha: _FloatingPillDesign.lightBorderOpacity,
          );

    // Icon colors
    final unselectedColor = isDark
        ? _FloatingPillDesign.darkIconUnselected.withValues(
            alpha: _FloatingPillDesign.darkIconOpacity,
          )
        : _FloatingPillDesign.lightIconUnselected.withValues(
            alpha: _FloatingPillDesign.lightIconOpacity,
          );
    
    final selectedColor = isDark
        ? _FloatingPillDesign.darkIconSelected
        : _FloatingPillDesign.lightIconSelected;

    // Visual index for display
    final visualIndex = widget.isCameraOverlayOpen ? 2 : widget.currentIndex;

    return Container(
      margin: EdgeInsets.only(
        left: _FloatingPillDesign.barMarginHorizontal,
        right: _FloatingPillDesign.barMarginHorizontal,
        bottom: _FloatingPillDesign.barMarginBottom,
      ),
      height: _FloatingPillDesign.barHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_FloatingPillDesign.barRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark
                  ? _FloatingPillDesign.shadowOpacityDark
                  : _FloatingPillDesign.shadowOpacity,
            ),
            blurRadius: _FloatingPillDesign.shadowBlur,
            offset: _FloatingPillDesign.shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_FloatingPillDesign.barRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _FloatingPillDesign.backdropBlur,
            sigmaY: _FloatingPillDesign.backdropBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(_FloatingPillDesign.barRadius),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Home (Index 0)
                _buildNavItem(
                  icon: Icons.home_rounded,
                  index: 0,
                  isSelected: visualIndex == 0,
                  isDark: isDark,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                ),
                
                // Progress (Index 1)
                _buildNavItem(
                  icon: Icons.trending_up_rounded,
                  index: 1,
                  isSelected: visualIndex == 1,
                  isDark: isDark,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                ),
                
                // Camera (Index 2 - Hero/Center)
                _buildCameraItem(
                  index: 2,
                  isDark: isDark,
                ),
                
                // Summary (Index 3)
                _buildNavItem(
                  icon: Icons.assessment_rounded,
                  index: 3,
                  isSelected: visualIndex == 3,
                  isDark: isDark,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                ),
                
                // Settings (Index 4)
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  index: 4,
                  isSelected: visualIndex == 4,
                  isDark: isDark,
                  unselectedColor: unselectedColor,
                  selectedColor: selectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build regular navigation item
  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isSelected,
    required bool isDark,
    required Color unselectedColor,
    required Color selectedColor,
  }) {
    final iconColor = isSelected ? selectedColor : unselectedColor;
    final shouldAnimate = _lastTappedIndex == index;

    return GestureDetector(
      onTap: () => _handleTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with optional bounce animation
            AnimatedBuilder(
              animation: _iconScaleAnimation,
              builder: (context, child) {
                final scale = shouldAnimate ? _iconScaleAnimation.value : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    icon,
                    size: _FloatingPillDesign.iconSizeRegular,
                    color: iconColor,
                  ),
                );
              },
            ),
            
            SizedBox(height: _FloatingPillDesign.dotSpacing),
            
            // Active indicator dots
            _buildIndicatorDots(
              isSelected: isSelected,
              color: selectedColor,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  /// Build camera navigation item (special)
  Widget _buildCameraItem({
    required int index,
    required bool isDark,
  }) {
    final gradientColors = isDark
        ? _FloatingPillDesign.cameraGradientDark
        : _FloatingPillDesign.cameraGradientLight;
    
    final shouldAnimate = _lastTappedIndex == index;

    return GestureDetector(
      onTap: () => _handleTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera with gradient background and bounce animation
            AnimatedBuilder(
              animation: _iconScaleAnimation,
              builder: (context, child) {
                final scale = shouldAnimate ? _iconScaleAnimation.value : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: _FloatingPillDesign.cameraCircleSize,
                    height: _FloatingPillDesign.cameraCircleSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.4),
                          blurRadius: 12.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: _FloatingPillDesign.iconSizeCamera,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: _FloatingPillDesign.dotSpacing),
            
            // Camera indicator dot (always visible)
            Container(
              width: _FloatingPillDesign.dotSizeCamera,
              height: _FloatingPillDesign.dotSizeCamera,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build indicator dots below icons
  Widget _buildIndicatorDots({
    required bool isSelected,
    required Color color,
    required bool isDark,
  }) {
    if (!isSelected) {
      // Single faded dot for unselected
      return Container(
        width: _FloatingPillDesign.dotSize,
        height: _FloatingPillDesign.dotSize,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
      );
    }

    // Two dots for selected with animation
    return AnimatedContainer(
      duration: _FloatingPillDesign.animationDuration,
      curve: _FloatingPillDesign.animationCurve,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _FloatingPillDesign.dotSize,
            height: _FloatingPillDesign.dotSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: _FloatingPillDesign.dotGap),
          Container(
            width: _FloatingPillDesign.dotSize,
            height: _FloatingPillDesign.dotSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}