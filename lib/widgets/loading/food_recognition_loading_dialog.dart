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

/// Global timer cancellation flag
bool _previewTimerCancelled = false;

/// Global variable to store updated food item with cost
FoodItem? _updatedFoodItem;

/// Show preview of completed food card for 8 seconds
/// Timer can be cancelled by calling cancelPreviewTimer()
/// Returns the FoodItem (potentially updated with cost if user added it)
Future<FoodItem> showFoodRecognitionPreview({
  required FoodItem foodItem,
  required String imagePath,
}) async {
  try {
    debugPrint('👁️ showFoodRecognitionPreview called');

    // Reset timer cancellation flag and updated item
    _previewTimerCancelled = false;
    _updatedFoodItem = foodItem;

    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ Overlay state is null');
      return foodItem;
    }

    // Remove any existing preview overlay first
    _previewOverlay?.remove();
    _previewOverlay = null;

    // Create new overlay entry with completed food card (no export button)
    _previewOverlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Background tap area for dismissing
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  debugPrint('👆 Tapped outside preview card - dismissing');
                  hideFoodRecognitionPreview();
                },
                child: Container(
                  color: Colors.black.withValues(alpha: 0.75),
                ),
              ),
            ),
            // Card in center - taps on this don't dismiss
            Center(
              child: FoodCardWidget(
                foodItem: _updatedFoodItem!,
                isLoading: false,
                isEditable: false,
                imagePath: imagePath,
                isPreviewMode: true,
                onCostPickerOpened: cancelPreviewTimer,
                onCostUpdated: updatePreviewFoodItemCost,
              ),
            ),
          ],
        ),
      ),
    );

    // Insert overlay
    overlayState.insert(_previewOverlay!);
    debugPrint('✅ Preview overlay inserted');

    // Wait for 8 seconds or until timer is cancelled
    await Future.delayed(const Duration(seconds: 8));

    // Only auto-dismiss if timer wasn't cancelled
    if (!_previewTimerCancelled) {
      debugPrint('⏰ 8-second timer completed - auto-dismissing');
      hideFoodRecognitionPreview();
    } else {
      debugPrint('⏸️ Timer was cancelled - preview stays open');
    }

    // Return the potentially updated food item
    return _updatedFoodItem ?? foodItem;
  } catch (e, stackTrace) {
    debugPrint('❌ Error showing preview overlay: $e');
    debugPrint('Stack trace: $stackTrace');
    return foodItem;
  }
}

/// Update the food item's cost during preview
/// Called when user selects a cost in the picker
void updatePreviewFoodItemCost(double cost) {
  if (_updatedFoodItem != null) {
    debugPrint('💰 Updating preview food item cost to: \$${cost.toStringAsFixed(2)}');
    _updatedFoodItem = _updatedFoodItem!.copyWith(cost: cost);

    // Force rebuild of the overlay with updated cost
    if (_previewOverlay != null) {
      _previewOverlay!.markNeedsBuild();
    }
  }
}

/// Cancel the 8-second auto-dismiss timer
/// Called when user interacts with cost picker
void cancelPreviewTimer() {
  debugPrint('🛑 Preview timer cancelled - preview will stay open');
  _previewTimerCancelled = true;
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
