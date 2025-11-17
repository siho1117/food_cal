// lib/widgets/common/food_recognition_loading_dialog.dart
import 'package:flutter/material.dart';
import '../../main.dart'; // Import for navigatorKey
import '../../data/models/food_item.dart';
import '../food/food_card.dart';

// ═══════════════════════════════════════════════════════════════
// SKELETON CARD LOADING OVERLAY
// ═══════════════════════════════════════════════════════════════

/// Global overlay entry to manage the loading display
OverlayEntry? _loadingOverlay;

/// Show skeleton card loading overlay with optional image path
void showFoodRecognitionLoading(BuildContext? context, {String? imagePath}) {
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

    // Create new overlay entry with skeleton card loading UI
    _loadingOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: FoodCardWidget(
            foodItem: FoodItem.skeleton(),
            isLoading: true,
            isEditable: false,
            imagePath: imagePath,
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

// ═══════════════════════════════════════════════════════════════
// PREVIEW CARD OVERLAY (8-second review period)
// ═══════════════════════════════════════════════════════════════

/// Global overlay entry for preview
OverlayEntry? _previewOverlay;

/// Show preview of completed food card for 8 seconds
/// Returns a Future that completes when the preview is dismissed
Future<void> showFoodRecognitionPreview({
  required FoodItem foodItem,
  required String imagePath,
}) async {
  try {
    debugPrint('👁️ showFoodRecognitionPreview called');

    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ Overlay state is null');
      return;
    }

    // Remove any existing preview overlay first
    _previewOverlay?.remove();
    _previewOverlay = null;

    // Create new overlay entry with completed food card (no export button)
    _previewOverlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: FoodCardWidget(
            foodItem: foodItem,
            isLoading: false,
            isEditable: false,
            imagePath: imagePath,
          ),
        ),
      ),
    );

    // Insert overlay
    overlayState.insert(_previewOverlay!);
    debugPrint('✅ Preview overlay inserted');

    // Wait for 8 seconds
    await Future.delayed(const Duration(seconds: 8));

    // Remove overlay after 8 seconds
    hideFoodRecognitionPreview();
  } catch (e, stackTrace) {
    debugPrint('❌ Error showing preview overlay: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// Hide preview overlay
void hideFoodRecognitionPreview() {
  try {
    debugPrint('🔚 hideFoodRecognitionPreview called');
    if (_previewOverlay != null) {
      _previewOverlay?.remove();
      _previewOverlay = null;
      debugPrint('✅ Preview overlay removed');
    } else {
      debugPrint('ℹ️ No preview overlay to remove');
    }
  } catch (e) {
    debugPrint('❌ Error removing preview overlay: $e');
    _previewOverlay = null;
  }
}
