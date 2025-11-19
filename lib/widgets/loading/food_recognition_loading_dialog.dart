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

/// Shows skeleton card loading overlay during food recognition.
///
/// Displays an animated skeleton version of a food card while the API
/// processes the image. This provides visual feedback to the user.
///
/// **Parameters:**
/// - [context] - BuildContext (nullable, not currently used)
/// - [imagePath] - Optional path to display captured image in skeleton card
///
/// **Usage:**
/// ```dart
/// showFoodRecognitionLoading(null, imagePath: '/path/to/image.jpg');
/// // ... perform API call ...
/// hideFoodRecognitionLoading();
/// ```
void showFoodRecognitionLoading(BuildContext? context, {String? imagePath}) {
  try {
    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [FoodRecognition] Overlay state unavailable');
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
  } catch (e, stackTrace) {
    debugPrint('❌ [FoodRecognition] Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

/// Removes the loading overlay from the screen.
///
/// Should be called after the API request completes (success or failure)
/// to clean up the loading state.
void hideFoodRecognitionLoading() {
  try {
    if (_loadingOverlay != null) {
      _loadingOverlay?.remove();
      _loadingOverlay = null;
    }
  } catch (e) {
    debugPrint('❌ [FoodRecognition] Error removing overlay: $e');
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

/// Shows preview of recognized food card for 8 seconds.
///
/// This function displays the completed food card after AI recognition
/// and gives the user 8 seconds to review it. During this time, the user can:
/// - Add cost information (which cancels the auto-dismiss timer)
/// - Tap outside to dismiss early
/// - Let it auto-dismiss after 8 seconds
///
/// **Parameters:**
/// - [foodItem] - The recognized food item to display
/// - [imagePath] - Path to the captured food image
///
/// **Returns:**
/// - [Future<FoodItem>] - The food item, potentially updated with cost if user added it
///
/// **Timer behavior:**
/// - Auto-dismisses after 8 seconds if user doesn't interact
/// - Timer is cancelled if user opens cost picker (via [cancelPreviewTimer])
/// - User can manually dismiss by tapping outside the card
///
/// **Usage:**
/// ```dart
/// final updatedItem = await showFoodRecognitionPreview(
///   foodItem: recognizedItem,
///   imagePath: '/path/to/image.jpg',
/// );
/// // updatedItem may have cost added by user during preview
/// ```
Future<FoodItem> showFoodRecognitionPreview({
  required FoodItem foodItem,
  required String imagePath,
}) async {
  try {
    // Reset timer cancellation flag and updated item
    _previewTimerCancelled = false;
    _updatedFoodItem = foodItem;

    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [Preview] Overlay state unavailable');
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
                onTap: hideFoodRecognitionPreview,
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

    // Wait for 8 seconds or until timer is cancelled
    await Future.delayed(const Duration(seconds: 8));

    // Only auto-dismiss if timer wasn't cancelled
    if (!_previewTimerCancelled) {
      hideFoodRecognitionPreview();
    }

    // Return the potentially updated food item
    return _updatedFoodItem ?? foodItem;
  } catch (e, stackTrace) {
    debugPrint('❌ [Preview] Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
    return foodItem;
  }
}

/// Updates the food item's cost during preview period.
///
/// Called when user selects a cost in the cost picker overlay.
/// This updates the internal state and forces a rebuild of the preview card.
///
/// **Parameters:**
/// - [cost] - The new cost value selected by user
void updatePreviewFoodItemCost(double cost) {
  if (_updatedFoodItem != null) {
    _updatedFoodItem = _updatedFoodItem!.copyWith(cost: cost);

    // Force rebuild of the overlay with updated cost
    _previewOverlay?.markNeedsBuild();
  }
}

/// Cancels the 8-second auto-dismiss timer.
///
/// This is called automatically when the user opens the cost picker,
/// preventing the preview from auto-dismissing while they're entering cost.
/// The preview will remain open until the user manually dismisses it.
void cancelPreviewTimer() {
  _previewTimerCancelled = true;
}

/// Removes the preview overlay from the screen.
///
/// Can be called:
/// - Automatically after 8 seconds (if timer not cancelled)
/// - Manually by user tapping outside the card
/// - By other code that needs to dismiss the preview
void hideFoodRecognitionPreview() {
  try {
    if (_previewOverlay != null) {
      _previewOverlay?.remove();
      _previewOverlay = null;
    }
  } catch (e) {
    debugPrint('❌ [Preview] Error removing overlay: $e');
    _previewOverlay = null;
  }
}
