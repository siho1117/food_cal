// lib/widgets/common/food_recognition_loading_dialog.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../main.dart'; // Import for navigatorKey
import '../../data/models/food_item.dart';
import '../../config/design_system/dialog_theme.dart';
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
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDialogTheme.backdropBlurSigmaX,
          sigmaY: AppDialogTheme.backdropBlurSigmaY,
        ),
        child: Material(
          color: Colors.black.withValues(alpha: 0.15),
          child: Center(
            child: FoodCardWidget(
              foodItem: FoodItem.skeleton(),
              isLoading: true,
              isEditable: false,
              imagePath: imagePath,
            ),
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

/// Preview phase enum to track which timer period we're in
enum _PreviewPhase {
  initial,   // 8-second initial preview (before cost entry)
  postCost,  // 1-second final preview (after cost entry)
}

/// Global variable to track current preview phase
_PreviewPhase _previewPhase = _PreviewPhase.initial;

/// Global variable to store updated food item with cost
FoodItem? _updatedFoodItem;

/// Global flag to track if user has completed cost entry (one-time only)
bool _costEntryCompleted = false;

/// Global flag to track if cost picker is currently open
bool _costPickerIsOpen = false;

/// Completer to signal when preview is actually dismissed
/// This ensures the function only returns when preview closes
Completer<FoodItem>? _previewCompleter;

/// Shows preview of recognized food card with two-phase timer system.
///
/// **Phase 1 (Initial - 8 seconds):**
/// - User can only edit cost (one-time only)
/// - Auto-dismisses after 8 seconds if user doesn't interact
/// - Timer is cancelled if user opens cost picker
///
/// **Phase 2 (Post-cost - 1 second):**
/// - Triggered after user completes cost entry
/// - All fields become read-only (including cost)
/// - Auto-dismisses after 1 second
/// - User can still tap outside to dismiss early
///
/// **Parameters:**
/// - [foodItem] - The recognized food item to display
/// - [imagePath] - Path to the captured food image
///
/// **Returns:**
/// - [Future<FoodItem>] - The food item with cost if user added it
Future<FoodItem> showFoodRecognitionPreview({
  required FoodItem foodItem,
  required String imagePath,
}) async {
  try {
    // Reset state for new preview
    _previewPhase = _PreviewPhase.initial;
    _updatedFoodItem = foodItem;
    _costEntryCompleted = false;
    _costPickerIsOpen = false;

    // Create a new Completer that will be completed when preview closes
    _previewCompleter = Completer<FoodItem>();

    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [Preview] Overlay state unavailable');
      return foodItem;
    }

    // Remove any existing preview overlay first
    _previewOverlay?.remove();
    _previewOverlay = null;

    // Create new overlay entry with completed food card
    _previewOverlay = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDialogTheme.backdropBlurSigmaX,
          sigmaY: AppDialogTheme.backdropBlurSigmaY,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Background tap area for dismissing
              Positioned.fill(
                child: GestureDetector(
                  onTap: hideFoodRecognitionPreview,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.15),
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
                  costEntryCompleted: _costEntryCompleted,
                  onCostPickerOpened: _onCostPickerOpened,
                  onCostPickerClosed: _onCostPickerClosed,
                  onCostUpdated: _onCostUpdated,
                  // Removed: All other edit callbacks (only cost is editable)
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Insert overlay
    overlayState.insert(_previewOverlay!);

    // ═══════════════════════════════════════════════════════════
    // PHASE 1: Initial 8-second timer with polling
    // ═══════════════════════════════════════════════════════════
    // Poll every 100ms to check if we should auto-dismiss
    // This allows proper cancellation when cost picker opens
    int elapsedMs = 0;
    const int timerDurationMs = 8000;
    const int pollIntervalMs = 100;

    while (elapsedMs < timerDurationMs) {
      await Future.delayed(const Duration(milliseconds: pollIntervalMs));
      elapsedMs += pollIntervalMs;

      // Stop polling if:
      // 1. Cost picker is open (user is entering cost)
      // 2. Phase changed (user completed cost entry and 3s timer started)
      // 3. Preview was dismissed
      if (_costPickerIsOpen || _previewPhase != _PreviewPhase.initial || _previewOverlay == null) {
        break;
      }
    }

    // Only auto-dismiss if:
    // 1. Cost picker is NOT open (user is not entering cost), AND
    // 2. We're still in initial phase (user didn't complete cost entry), AND
    // 3. Preview is still visible
    if (!_costPickerIsOpen && _previewPhase == _PreviewPhase.initial && _previewOverlay != null) {
      hideFoodRecognitionPreview();
    }

    // Wait for preview to ACTUALLY close before returning
    // This ensures save happens only after preview is dismissed
    return await _previewCompleter!.future;
  } catch (e, stackTrace) {
    debugPrint('❌ [Preview] Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
    // Complete the completer if it exists to prevent hanging
    if (_previewCompleter != null && !_previewCompleter!.isCompleted) {
      _previewCompleter!.complete(foodItem);
    }
    return foodItem;
  }
}

/// Called when user opens the cost picker.
///
/// Sets the flag to pause the initial 8-second timer while
/// user is entering cost information.
void _onCostPickerOpened() {
  _costPickerIsOpen = true;
}

/// Called when cost picker is closed (either with OK or Cancel).
///
/// This handles the scenario where user opens cost picker but cancels:
/// - If cost was updated: Phase 2 timer already started (handled by _onCostUpdated)
/// - If cancelled: Start 1-second timer to auto-close preview
void _onCostPickerClosed() {
  _costPickerIsOpen = false;

  // If cost was NOT entered (user cancelled), start 1-second timer
  // to auto-close the preview
  if (!_costEntryCompleted && _previewPhase == _PreviewPhase.initial) {
    _startPostCancelTimer();
  }
}

/// Starts a 1-second timer after cost picker is cancelled (no cost entered).
///
/// Auto-dismisses the preview after 1 second.
void _startPostCancelTimer() async {
  await Future.delayed(const Duration(seconds: 1));

  // Auto-close if still in initial phase (user didn't try again)
  if (_previewPhase == _PreviewPhase.initial && _previewOverlay != null) {
    hideFoodRecognitionPreview();
  }
}

/// Called when user completes cost entry.
///
/// This triggers Phase 2 of the preview:
/// 1. Updates the food item with the selected cost
/// 2. Marks cost entry as completed (makes cost field read-only)
/// 3. Switches to Phase 2 (1-second final preview)
/// 4. Starts 1-second auto-dismiss timer
///
/// **Parameters:**
/// - [cost] - The cost value selected by user
void _onCostUpdated(double cost) {
  if (_updatedFoodItem != null) {
    // Update food item with cost
    _updatedFoodItem = _updatedFoodItem!.copyWith(cost: cost);
    _costEntryCompleted = true; // Mark cost entry as completed (one-time only)

    // Switch to Phase 2
    _previewPhase = _PreviewPhase.postCost;

    // Force rebuild to make cost field read-only
    _previewOverlay?.markNeedsBuild();

    // Start 1-second timer for Phase 2
    _startPostCostTimer();
  }
}

/// Starts the 1-second timer after cost entry (Phase 2).
///
/// Auto-dismisses the preview after 1 second unless user
/// manually dismisses by tapping outside.
void _startPostCostTimer() async {
  await Future.delayed(const Duration(seconds: 1));

  // Auto-close if we're still in post-cost phase
  if (_previewPhase == _PreviewPhase.postCost) {
    hideFoodRecognitionPreview();
  }
}

/// Removes the preview overlay from the screen.
///
/// Can be called:
/// - Automatically after 8 seconds (if timer not cancelled)
/// - Manually by user tapping outside the card
/// - By other code that needs to dismiss the preview
///
/// This function also completes the Completer to signal that
/// the preview is closed and data can now be saved.
void hideFoodRecognitionPreview() {
  try {
    if (_previewOverlay != null) {
      _previewOverlay?.remove();
      _previewOverlay = null;
    }

    // Complete the Completer with the final food item
    // This allows showFoodRecognitionPreview() to return
    if (_previewCompleter != null && !_previewCompleter!.isCompleted) {
      _previewCompleter!.complete(_updatedFoodItem);
    }
  } catch (e) {
    debugPrint('❌ [Preview] Error removing overlay: $e');
    _previewOverlay = null;
    // Still try to complete the Completer to prevent hanging
    if (_previewCompleter != null && !_previewCompleter!.isCompleted) {
      _previewCompleter!.complete(_updatedFoodItem);
    }
  }
}
