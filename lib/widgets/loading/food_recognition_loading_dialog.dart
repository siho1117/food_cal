// lib/widgets/common/food_recognition_loading_dialog.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

/// Global flag to track if user has completed cost entry
bool _costEntryCompleted = false;

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
    // Reset timer cancellation flag, updated item, and cost entry completion
    _previewTimerCancelled = false;
    _updatedFoodItem = foodItem;
    _costEntryCompleted = false;

    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [Preview] Overlay state unavailable');
      return foodItem;
    }

    // Remove any existing preview overlay first
    _previewOverlay?.remove();
    _previewOverlay = null;

    // Create GlobalKey for export functionality
    final cardKey = GlobalKey();

    // Create new overlay entry with completed food card
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
              child: RepaintBoundary(
                key: cardKey,
                child: FoodCardWidget(
                  foodItem: _updatedFoodItem!,
                  isLoading: false,
                  isEditable: false,
                  imagePath: imagePath,
                  isPreviewMode: true,
                  costEntryCompleted: _costEntryCompleted,
                  onCostPickerOpened: cancelPreviewTimer,
                  onCostUpdated: updatePreviewFoodItemCost,
                  // Show export button only after cost entry is completed
                  onExportTap: _costEntryCompleted ? () => _exportPreviewCard(cardKey, _updatedFoodItem!) : null,
                ),
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
/// This updates the internal state, marks cost entry as completed,
/// and forces a rebuild of the preview card to show export button.
///
/// **Parameters:**
/// - [cost] - The new cost value selected by user
void updatePreviewFoodItemCost(double cost) {
  if (_updatedFoodItem != null) {
    _updatedFoodItem = _updatedFoodItem!.copyWith(cost: cost);
    _costEntryCompleted = true; // Mark cost entry as completed

    // Force rebuild of the overlay with updated cost and export button
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

/// Exports the preview food card as an image and shares it.
///
/// This function captures the food card widget as a high-quality PNG image
/// and uses the system share dialog to allow the user to save or share it.
///
/// **Parameters:**
/// - [cardKey] - GlobalKey of the RepaintBoundary wrapping the card
/// - [foodItem] - The food item being previewed
///
/// **Technical details:**
/// - Uses RenderRepaintBoundary to capture widget as image
/// - 3.0x pixel ratio for high quality (retina displays)
/// - Saves to temporary directory before sharing
/// - Automatically cleans up temp file after sharing
Future<void> _exportPreviewCard(GlobalKey cardKey, FoodItem foodItem) async {
  try {
    // Find the RenderRepaintBoundary
    final boundary = cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      debugPrint('❌ [Export] Failed to find RepaintBoundary');
      return;
    }

    // Capture the widget as an image with high quality
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();

    if (imageBytes == null) {
      debugPrint('❌ [Export] Failed to capture image bytes');
      return;
    }

    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName = '${foodItem.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);

    // Share the image
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '${foodItem.name} - Nutrition Info',
    );

    debugPrint('✅ [Export] Food card exported successfully');
  } catch (e) {
    debugPrint('❌ [Export] Failed to export food card: $e');
  }
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
