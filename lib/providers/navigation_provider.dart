// lib/providers/navigation_provider.dart
import 'package:flutter/material.dart';

/// Provider to manage bottom navigation state globally
///
/// Navigation indices:
/// - 0: Home
/// - 1: Progress
/// - 2: Quick Add (special - opens dialog)
/// - 3: Summary
/// - 4: Settings
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  /// Navigate to a specific tab by index
  void navigateTo(int index) {
    if (index != 2 && index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to Home tab (index 0)
  void navigateToHome() {
    navigateTo(0);
  }

  /// Navigate to Progress tab (index 1)
  void navigateToProgress() {
    navigateTo(1);
  }

  /// Navigate to Summary tab (index 3)
  void navigateToSummary() {
    navigateTo(3);
  }

  /// Navigate to Settings tab (index 4)
  void navigateToSettings() {
    navigateTo(4);
  }
}
