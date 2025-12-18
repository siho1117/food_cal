// lib/widgets/food/helpers/food_card_pickers.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../common/number_picker_dialog.dart';
import '../../common/currency_picker_dialog.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../main.dart';

/// Static helper class for food card picker dialogs.
///
/// This class provides reusable picker methods for editing food card values:
/// - Calories (0-9999)
/// - Serving size (0.1-20.0, with 1 decimal place)
/// - Macronutrients: protein, carbs, fat (0-999g)
/// - Cost ($0.00-$999.99, with optional manual input for higher amounts)
///
/// **Design Pattern:**
/// These are static methods because they:
/// - Don't need instance state
/// - Can be called from anywhere
/// - Are pure utility functions
/// - Return Future<T?> for async/await pattern
///
/// **Usage:**
/// ```dart
/// // In your widget
/// final newCalories = await FoodCardPickers.showCaloriesPicker(
///   context: context,
///   currentValue: 500,
/// );
/// if (newCalories != null) {
///   setState(() {
///     caloriesController.text = newCalories.toString();
///   });
/// }
/// ```
class FoodCardPickers {
  // Private constructor to prevent instantiation
  FoodCardPickers._();

  /// Shows a number picker dialog for selecting calories.
  ///
  /// **Parameters:**
  /// - [context] - BuildContext for showing dialog
  /// - [currentValue] - Current calories value (default: 0)
  ///
  /// **Returns:**
  /// - [Future<int?>] - Selected calories (0-9999), or null if cancelled
  ///
  /// **Range:** 0 to 9999 calories, step size: 1
  static Future<int?> showCaloriesPicker({
    required BuildContext context,
    required int currentValue,
  }) async {
    return await showNumberPickerDialog(
      context: context,
      title: AppLocalizations.of(context)!.editCalories,
      initialValue: currentValue,
      minValue: 0,
      maxValue: 9999,
      step: 1,
      icon: AnimatedEmojis.fire,
    );
  }

  /// Shows a decimal picker dialog for selecting serving size.
  ///
  /// **Parameters:**
  /// - [context] - BuildContext for showing dialog
  /// - [currentValue] - Current serving size value (default: 1.0)
  ///
  /// **Returns:**
  /// - [Future<double?>] - Selected serving size (0.1-20.0), or null if cancelled
  ///
  /// **Range:** 0.1 to 20.0 servings, 1 decimal place (e.g., 1.5)
  static Future<double?> showServingSizePicker({
    required BuildContext context,
    required double currentValue,
  }) async {
    return await showDecimalPickerDialog(
      context: context,
      title: AppLocalizations.of(context)!.editServingSize,
      initialValue: currentValue,
      minValue: 0.1,
      maxValue: 20.0,
      decimalPlaces: 1,
      icon: AnimatedEmojis.spaghetti,
    );
  }

  /// Shows a number picker dialog for selecting macronutrient values.
  ///
  /// This is a generic picker for protein, carbs, or fat grams.
  ///
  /// **Parameters:**
  /// - [context] - BuildContext for showing dialog
  /// - [label] - Label for the macro (e.g., "Protein", "Carbs", "Fat")
  /// - [currentValue] - Current macro value in grams (default: 0)
  /// - [emojiPath] - Path to PNG emoji asset (e.g., FoodEmojis.cutOfMeat)
  ///
  /// **Returns:**
  /// - [Future<int?>] - Selected grams (0-999), or null if cancelled
  ///
  /// **Range:** 0 to 999 grams, step size: 1
  static Future<int?> showMacroPicker({
    required BuildContext context,
    required String label,
    required int currentValue,
    required String emojiPath,
  }) async {
    return await showNumberPickerDialog(
      context: context,
      title: AppLocalizations.of(context)!.editMacro(label),
      initialValue: currentValue,
      minValue: 0,
      maxValue: 999,
      step: 1,
      emojiPath: emojiPath,
    );
  }

  /// Shows a cost picker dialog for selecting cost per serving (editable mode).
  ///
  /// This is used in the food log edit dialog where users can modify
  /// existing food items.
  ///
  /// **Parameters:**
  /// - [context] - BuildContext for showing dialog
  /// - [currentValue] - Current cost value (default: 0.0)
  ///
  /// **Returns:**
  /// - [Future<double?>] - Selected cost ($0.00-$999.99+), or null if cancelled
  ///
  /// **Features:**
  /// - CupertinoPicker for dollars and cents ($0.00-$999.99)
  /// - Manual input field with two-way sync
  /// - Currency symbol ($) displayed in both picker and input
  static Future<double?> showCostPicker({
    required BuildContext context,
    required double currentValue,
  }) async {
    double? result;
    await showDialog<void>(
      context: context,
      builder: (context) => CurrencyPickerDialog(
        initialValue: currentValue,
        title: AppLocalizations.of(context)!.addCostPerServing,
        icon: AnimatedEmojis.moneyWithWings,
        onSave: (value) async {
          result = value;
        },
      ),
    );
    return result;
  }

  /// Shows a cost picker dialog in preview mode (after AI recognition).
  ///
  /// This is used during the 8-second preview period after food recognition,
  /// allowing users to add cost information before the item is saved.
  ///
  /// **Parameters:**
  /// - [context] - BuildContext for showing dialog (not used, kept for API consistency)
  /// - [currentValue] - Current cost value (default: 0.0)
  /// - [onCostPickerOpened] - Callback fired when picker opens (cancels preview timer)
  ///
  /// **Returns:**
  /// - [Future<double?>] - Selected cost ($0.00-$999.99+), or null if cancelled
  ///
  /// **Special behavior:**
  /// - Calls [onCostPickerOpened] to cancel the 8-second auto-dismiss timer
  /// - Uses overlay-based approach with CurrencyPickerDialog for guaranteed z-index control
  /// - This ensures the picker always appears above the preview overlay
  static Future<double?> showCostPickerInPreview({
    required BuildContext context,
    required double currentValue,
    VoidCallback? onCostPickerOpened,
  }) async {
    // Notify parent that cost picker is opening (cancels preview timer)
    onCostPickerOpened?.call();

    // Use overlay-based approach for guaranteed z-index control
    // This bypasses Flutter's dialog system and ensures proper stacking
    final result = await _showCurrencyPickerAsOverlay(
      initialValue: currentValue,
    );

    return result;
  }

  /// Shows CurrencyPickerDialog as an overlay for guaranteed z-index control.
  ///
  /// This is a private helper that wraps the CurrencyPickerDialog in an OverlayEntry
  /// to ensure it appears above all other UI elements, including the preview overlay.
  ///
  /// **Parameters:**
  /// - [initialValue] - The starting cost value
  ///
  /// **Returns:**
  /// - [Future<double?>] - The selected cost, or null if cancelled
  static Future<double?> _showCurrencyPickerAsOverlay({
    required double initialValue,
  }) async {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint('❌ [CostPicker] Overlay state unavailable');
      return null;
    }

    // Create a completer to wait for result
    final completer = Completer<double?>();
    OverlayEntry? overlayEntry;
    bool isOverlayRemoved = false; // Safety flag to prevent double removal

    // Helper function to safely remove overlay (prevents race condition)
    void safeRemoveOverlay() {
      if (!isOverlayRemoved && overlayEntry != null) {
        isOverlayRemoved = true;
        try {
          overlayEntry.remove();
        } catch (e) {
          debugPrint('❌ [CostPicker] Error removing overlay: $e');
        }
      }
    }

    // Create overlay entry with CurrencyPickerDialog
    // We need to wrap in Navigator so that CurrencyPickerDialog's Navigator.pop() works
    overlayEntry = OverlayEntry(
      builder: (context) => Navigator(
        onGenerateRoute: (settings) {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onTap: () {
                  // Tapping outside dismisses (returns null)
                  if (!completer.isCompleted) {
                    completer.complete(null);
                  }
                  safeRemoveOverlay();
                },
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // Prevent taps on dialog from dismissing
                    },
                    child: CurrencyPickerDialog(
                      initialValue: initialValue,
                      title: AppLocalizations.of(context)!.addCostPerServing,
                      icon: AnimatedEmojis.moneyWithWings,
                      onSave: (value) async {
                        // Complete the future and remove overlay
                        if (!completer.isCompleted) {
                          completer.complete(value);
                        }
                        safeRemoveOverlay();
                      },
                    ),
                  ),
                ),
              ),
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        },
      ),
    );

    // Insert overlay on top
    overlayState.insert(overlayEntry);

    // Wait for result with safety timeout and cleanup
    try {
      return await completer.future;
    } finally {
      // Ensure overlay is always removed, even if something goes wrong
      safeRemoveOverlay();
    }
  }

}
