// lib/widgets/common/food_recognition_loading_dialog.dart
import 'package:flutter/material.dart';
import '../../main.dart'; // Import for navigatorKey

// ═══════════════════════════════════════════════════════════════
// SIMPLE OVERLAY APPROACH - Just show "testing" text
// ═══════════════════════════════════════════════════════════════

/// Global overlay entry to manage the loading display
OverlayEntry? _loadingOverlay;

/// Show simple loading text overlay using global navigator key
void showFoodRecognitionLoading(BuildContext? context) {
  try {
    debugPrint('🎯 showFoodRecognitionLoading called');

    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ Overlay state is null');
      return;
    }

    // Remove any existing overlay first
    _loadingOverlay?.remove();
    _loadingOverlay = null;

    // Create new overlay entry
    _loadingOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'testing',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlay using global overlay state
    overlayState.insert(_loadingOverlay!);
    debugPrint('✅ Overlay inserted');
  } catch (e, stackTrace) {
    debugPrint('❌ Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// Hide loading overlay
void hideFoodRecognitionLoading() {
  try {
    debugPrint('🔚 hideFoodRecognitionLoading called');
    if (_loadingOverlay != null) {
      _loadingOverlay?.remove();
      _loadingOverlay = null;
      debugPrint('✅ Overlay removed');
    } else {
      debugPrint('ℹ️ No overlay to remove');
    }
  } catch (e) {
    debugPrint('❌ Error removing overlay: $e');
    _loadingOverlay = null;
  }
}
