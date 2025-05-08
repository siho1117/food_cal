import 'package:flutter/material.dart';
import '../theme.dart';

/// Extension methods on BuildContext for responsive sizing and theming.
///
/// These extensions provide quick access to MediaQuery, Theme, and other 
/// context-dependent utilities to reduce code duplication.
extension ContextExtensions on BuildContext {
  /// Get the MediaQuery data
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get the current theme
  ThemeData get theme => Theme.of(this);
  
  /// Get screen size
  Size get screenSize => mediaQuery.size;
  
  /// Get screen width
  double get screenWidth => screenSize.width;
  
  /// Get screen height
  double get screenHeight => screenSize.height;
  
  /// Check if device is in portrait mode
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  
  /// Check if device is in landscape mode
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  
  /// Get status bar height
  double get statusBarHeight => mediaQuery.padding.top;
  
  /// Get bottom padding (for safe areas)
  double get bottomPadding => mediaQuery.padding.bottom;
  
  /// Get screen width percentage
  double widthPercent(double percent) => screenWidth * percent;
  
  /// Get screen height percentage
  double heightPercent(double percent) => screenHeight * percent;
  
  /// Get responsive width based on screen size
  /// 
  /// Returns smaller value for phones, larger for tablets
  double responsiveWidth(double phone, double tablet) {
    return screenWidth < 600 ? phone : tablet;
  }
  
  /// Get responsive height based on screen size
  /// 
  /// Returns smaller value for phones, larger for tablets
  double responsiveHeight(double phone, double tablet) {
    return screenWidth < 600 ? phone : tablet;
  }
  
  /// Get responsive value for any dimension based on screen size
  double responsive(double phone, double tablet, double desktop) {
    if (screenWidth < 600) return phone;
    if (screenWidth < 1200) return tablet;
    return desktop;
  }
  
  /// Show a standard snackbar with consistent styling
  void showSnackBar({
    required String message,
    Color backgroundColor = AppTheme.primaryBlue,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }
  
  /// Show a success snackbar
  void showSuccessSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
      action: action,
    );
  }
  
  /// Show an error snackbar
  void showErrorSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      duration: duration,
      action: action,
    );
  }
  
  /// Navigate to a new screen
  Future<T?> navigateTo<T>(Widget screen) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
  /// Navigate to a new screen and replace the current one
  Future<T?> navigateReplace<T>(Widget screen) {
    return Navigator.of(this).pushReplacement<T, dynamic>(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
  
  /// Pop back to a specific route
  void popUntil(String routeName) {
    Navigator.of(this).popUntil(ModalRoute.withName(routeName));
  }
  
  /// Check if current platform is iOS
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;
  
  /// Check if current platform is Android
  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;
}