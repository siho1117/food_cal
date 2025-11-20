// lib/widgets/food/helpers/food_card_pickers.dart
import 'package:flutter/material.dart';
import '../../common/number_picker_dialog.dart';
import '../../common/cost_picker_overlay.dart';

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
      title: 'Select Calories',
      initialValue: currentValue,
      minValue: 0,
      maxValue: 9999,
      step: 1,
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
      title: 'Select Serving Size',
      initialValue: currentValue,
      minValue: 0.1,
      maxValue: 20.0,
      decimalPlaces: 1,
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
  ///
  /// **Returns:**
  /// - [Future<int?>] - Selected grams (0-999), or null if cancelled
  ///
  /// **Range:** 0 to 999 grams, step size: 1
  static Future<int?> showMacroPicker({
    required BuildContext context,
    required String label,
    required int currentValue,
  }) async {
    return await showNumberPickerDialog(
      context: context,
      title: 'Select $label (g)',
      initialValue: currentValue,
      minValue: 0,
      maxValue: 999,
      step: 1,
    );
  }

  /// Shows a cost picker overlay for selecting cost per serving (editable mode).
  ///
  /// This is used in the food log edit dialog where users can modify
  /// existing food items.
  ///
  /// **Parameters:**
  /// - [currentValue] - Current cost value (default: 0.0)
  ///
  /// **Returns:**
  /// - [Future<double?>] - Selected cost ($0.00-$999.99+), or null if cancelled
  ///
  /// **Features:**
  /// - Dual-column picker for dollars and cents ($0.00-$999.99)
  /// - Manual input field for amounts > $999
  /// - Uses overlay system for guaranteed z-index control
  static Future<double?> showCostPicker({
    required double currentValue,
  }) async {
    return await showCostPickerOverlay(
      initialValue: currentValue,
      showManualInput: true, // Enable manual input for food log editing
      maxDollars: 999,
    );
  }

  /// Shows a cost picker overlay in preview mode (after AI recognition).
  ///
  /// This is used during the 8-second preview period after food recognition,
  /// allowing users to add cost information before the item is saved.
  ///
  /// **Parameters:**
  /// - [currentValue] - Current cost value (default: 0.0)
  /// - [onCostPickerOpened] - Callback fired when picker opens (cancels preview timer)
  ///
  /// **Returns:**
  /// - [Future<double?>] - Selected cost ($0.00-$999.99+), or null if cancelled
  ///
  /// **Special behavior:**
  /// - Calls [onCostPickerOpened] to cancel the 8-second auto-dismiss timer
  /// - Same UI as edit mode for consistency
  static Future<double?> showCostPickerInPreview({
    required double currentValue,
    VoidCallback? onCostPickerOpened,
  }) async {
    // Notify parent that cost picker is opening (cancels preview timer)
    onCostPickerOpened?.call();

    // Show cost picker using custom overlay (guaranteed to be on top)
    // Include manual input for consistency with edit mode
    return await showCostPickerOverlay(
      initialValue: currentValue,
      showManualInput: true,
      maxDollars: 999,
    );
  }

}
