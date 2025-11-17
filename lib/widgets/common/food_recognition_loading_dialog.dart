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
