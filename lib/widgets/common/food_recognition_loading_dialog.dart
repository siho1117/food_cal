// lib/widgets/common/food_recognition_loading_dialog.dart
import 'package:flutter/material.dart';
import '../../main.dart'; // Import for navigatorKey

// ═══════════════════════════════════════════════════════════════
// SIMPLE LOADING OVERLAY - We'll build step-by-step loading later
// ═══════════════════════════════════════════════════════════════

/// Global overlay entry to manage the loading display
OverlayEntry? _loadingOverlay;

/// Show simple loading overlay
/// TODO: We'll enhance this with step-by-step progress later
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

    // Create new overlay entry with simple loading UI
    _loadingOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading spinner
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                  ),
                ),
                SizedBox(height: 20),
                // Main message
                Text(
                  'Analyzing your food...',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                // Submessage
                Text(
                  'This may take a few seconds',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
