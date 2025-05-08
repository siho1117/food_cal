import 'package:flutter/material.dart';

/// Utility class for responsive dimensions and scaling.
///
/// This class provides screen-aware sizing to maintain consistent
/// layouts across different device sizes.
class Dimensions {
  // Private constructor to prevent instantiation
  Dimensions._();
  
  // Standard device size breakpoints
  static const double phoneWidth = 600;
  static const double tabletWidth = 900;
  static const double desktopWidth = 1200;
  
  // Get actual screen width (must be called with BuildContext)
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  // Get actual screen height (must be called with BuildContext)
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Get screen size (must be called with BuildContext)
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }
  
  // Check if the device is a phone (width < 600)
  static bool isPhone(BuildContext context) {
    return screenWidth(context) < phoneWidth;
  }
  
  // Check if the device is a tablet (600 <= width < 1200)
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= phoneWidth && width < desktopWidth;
  }
  
  // Check if the device is a desktop (width >= 1200)
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= desktopWidth;
  }
  
  // Get a dimension that scales with screen width
  static double scaleWidth(BuildContext context, double size) {
    final width = screenWidth(context);
    // Reference design width (base width for scaling)
    const double referenceWidth = 375.0; // iPhone X width
    
    // Calculate the scaling factor
    final scaleFactor = width / referenceWidth;
    
    // Apply the scaling factor to the size
    return size * scaleFactor;
  }
  
  // Get a dimension that scales with screen height
  static double scaleHeight(BuildContext context, double size) {
    final height = screenHeight(context);
    // Reference design height (base height for scaling)
    const double referenceHeight = 812.0; // iPhone X height
    
    // Calculate the scaling factor
    final scaleFactor = height / referenceHeight;
    
    // Apply the scaling factor to the size
    return size * scaleFactor;
  }
  
  // Get a responsive dimension based on device type
  static double responsive(
    BuildContext context, {
    required double small, // Phone size
    required double medium, // Tablet size
    required double large, // Desktop size
  }) {
    if (isDesktop(context)) {
      return large;
    } else if (isTablet(context)) {
      return medium;
    } else {
      return small;
    }
  }
  
  // Standard spacing values - use these for consistent padding/margins
  static double get xxs => 4;
  static double get xs => 8;
  static double get s => 12;
  static double get m => 16;
  static double get l => 20;
  static double get xl => 24;
  static double get xxl => 32;
  static double get xxxl => 48;
  
  // Get responsive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(16);
    }
  }
  
  // Get responsive horizontal padding based on screen size
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
  }
  
  // Get responsive bottom padding with safe area
  static EdgeInsets getBottomPadding(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.only(bottom: bottomSafeArea + 16);
  }
  
  // Card sizing
  static double getCardHeight(BuildContext context, {CardSize size = CardSize.medium}) {
    switch (size) {
      case CardSize.small:
        return responsive(context, small: 100, medium: 120, large: 140);
      case CardSize.medium:
        return responsive(context, small: 160, medium: 200, large: 240);
      case CardSize.large:
        return responsive(context, small: 240, medium: 300, large: 360);
    }
  }
  
  // Icon sizing
  static double getIconSize(BuildContext context, {IconSize size = IconSize.medium}) {
    switch (size) {
      case IconSize.small:
        return responsive(context, small: 16, medium: 18, large: 20);
      case IconSize.medium:
        return responsive(context, small: 24, medium: 28, large: 32);
      case IconSize.large:
        return responsive(context, small: 36, medium: 48, large: 56);
    }
  }
  
  // Text scaling
  static double getTextSize(BuildContext context, {TextSize size = TextSize.medium}) {
    switch (size) {
      case TextSize.xs:
        return responsive(context, small: 10, medium: 11, large: 12);
      case TextSize.small:
        return responsive(context, small: 12, medium: 13, large: 14);
      case TextSize.medium:
        return responsive(context, small: 14, medium: 16, large: 18);
      case TextSize.large:
        return responsive(context, small: 18, medium: 20, large: 22);
      case TextSize.xl:
        return responsive(context, small: 20, medium: 24, large: 28);
      case TextSize.xxl:
        return responsive(context, small: 24, medium: 32, large: 36);
    }
  }
}

/// Enum for standardized card sizes
enum CardSize {
  small,
  medium,
  large,
}

/// Enum for standardized icon sizes
enum IconSize {
  small,
  medium,
  large,
}

/// Enum for standardized text sizes
enum TextSize {
  xs,
  small,
  medium,
  large,
  xl,
  xxl,
}