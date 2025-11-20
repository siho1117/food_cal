// lib/widgets/home/quick_edit_food_controller.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/constants/app_constants.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';
import '../../services/food_image_service.dart';

/// Controller for QuickEditFoodDialog business logic
///
/// Separates business logic from UI to keep the dialog widget focused on presentation.
/// Handles validation, data persistence, and image management.
///
/// **DATA MODEL CONVENTIONS:**
///
/// This controller manages the conversion between two representations of nutrition data:
///
/// 1. **Storage (FoodItem)**: Per-unit values
///    - FoodItem stores nutrition as "per serving unit" values
///    - Example: calories=500, proteins=20, servingSize=1.0
///    - To get total nutrition: multiply by servingSize
///
/// 2. **Display (TextEditingControllers)**: Total values
///    - Controllers show total nutrition for the current serving size
///    - Example: servingSize=2.0 → controllers show 1000 cal, 40g protein
///    - This allows users to see/edit the total they're consuming
///
/// **CONVERSION PATTERN:**
/// - **On Load**: Multiply per-unit values by servingSize (per-unit → total)
/// - **On Save**: Divide total values by servingSize (total → per-unit)
///
/// **AUTO-RECALCULATION:**
/// When servingSize changes, nutrition values are automatically recalculated
/// proportionally using the original per-unit values as a baseline.
class QuickEditFoodController {
  final FoodItem foodItem;
  final VoidCallback? onUpdated;

  final FoodRepository _foodRepository = FoodRepository();

  // Text controllers
  late final TextEditingController nameController;
  late final TextEditingController servingSizeController;
  late final TextEditingController caloriesController;
  late final TextEditingController proteinController;
  late final TextEditingController carbsController;
  late final TextEditingController fatController;
  late final TextEditingController costController;

  // State
  bool isLoading = false;
  String? imagePath;

  // Original values for proportional calculation when serving size changes
  late final double _originalServingSize;
  late final double _originalCalories;
  late final double _originalProtein;
  late final double _originalCarbs;
  late final double _originalFat;

  QuickEditFoodController({
    required this.foodItem,
    this.onUpdated,
  }) {
    // Store original per-unit values for proportional recalculation
    _originalServingSize = foodItem.servingSize;
    _originalCalories = foodItem.calories;
    _originalProtein = foodItem.proteins;
    _originalCarbs = foodItem.carbs;
    _originalFat = foodItem.fats;

    // Calculate total values for display (per-unit × servingSize)
    // This ensures that when reopening the dialog, we show the total values
    // that match the serving size, not just the per-unit values
    final totalCalories = (foodItem.calories * foodItem.servingSize).round();
    final totalProtein = (foodItem.proteins * foodItem.servingSize).round();
    final totalCarbs = (foodItem.carbs * foodItem.servingSize).round();
    final totalFat = (foodItem.fats * foodItem.servingSize).round();
    final totalCost = foodItem.cost != null ? foodItem.cost! * foodItem.servingSize : null;

    // Initialize controllers with total values (not per-unit values)
    nameController = TextEditingController(text: foodItem.name);
    servingSizeController = TextEditingController(text: foodItem.servingSize.toString());
    caloriesController = TextEditingController(text: totalCalories.toString());
    proteinController = TextEditingController(text: totalProtein.toString());
    carbsController = TextEditingController(text: totalCarbs.toString());
    fatController = TextEditingController(text: totalFat.toString());
    costController = TextEditingController(
      text: totalCost?.toStringAsFixed(2) ?? ''
    );

    // Initialize image path
    imagePath = foodItem.imagePath;

    // Add listener to serving size controller for auto-recalculation
    servingSizeController.addListener(_onServingSizeChanged);
  }

  /// Dispose all text controllers
  void dispose() {
    servingSizeController.removeListener(_onServingSizeChanged);
    nameController.dispose();
    servingSizeController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    costController.dispose();
  }

  /// Converts a total nutrition value to per-unit value by dividing by serving size.
  ///
  /// This helper method encapsulates the conversion logic from display values (total)
  /// to storage values (per-unit). It safely handles division by zero.
  ///
  /// **Parameters:**
  /// - [total] - The total nutrition value for the current serving size
  /// - [servingSize] - The current serving size multiplier
  ///
  /// **Returns:**
  /// - Per-unit value (total / servingSize), or total unchanged if servingSize is 0
  ///
  /// **Example:**
  /// ```dart
  /// _toPerUnit(1000.0, 2.0) // Returns 500.0 (calories per serving)
  /// _toPerUnit(40.0, 2.0)   // Returns 20.0 (protein per serving)
  /// ```
  static double _toPerUnit(double total, double servingSize) {
    return servingSize > 0 ? total / servingSize : total;
  }

  /// Called when serving size changes to auto-recalculate nutrition values.
  ///
  /// This maintains the proportional relationship between serving size and nutrition values.
  /// When the user changes serving size, calories and macros are automatically updated
  /// based on the original values when the dialog was opened.
  ///
  /// **Example:**
  /// - Original: 1.0 serving, 500 cal, 20g protein
  /// - User changes to 2.0 servings
  /// - Auto-updates to: 1000 cal, 40g protein
  void _onServingSizeChanged() {
    final newServingSizeText = servingSizeController.text.trim();
    if (newServingSizeText.isEmpty) return;

    final newServingSize = double.tryParse(newServingSizeText);
    if (newServingSize == null || newServingSize <= 0) return;

    // Avoid division by zero
    if (_originalServingSize <= 0) return;

    // Calculate the ratio of new serving size to original
    final ratio = newServingSize / _originalServingSize;

    // Apply ratio to original values to get new proportional values
    final newCalories = (_originalCalories * ratio).round();
    final newProtein = (_originalProtein * ratio).round();
    final newCarbs = (_originalCarbs * ratio).round();
    final newFat = (_originalFat * ratio).round();

    // Update controllers (temporarily remove listener to avoid infinite loop)
    servingSizeController.removeListener(_onServingSizeChanged);

    caloriesController.text = newCalories.toString();
    proteinController.text = newProtein.toString();
    carbsController.text = newCarbs.toString();
    fatController.text = newFat.toString();

    servingSizeController.addListener(_onServingSizeChanged);
  }

  /// Pick image from camera or gallery
  Future<String?> pickImage(ImageSource source) async {
    try {
      final newImagePath = await FoodImageService.pickAndSaveImage(source: source);
      if (newImagePath != null) {
        imagePath = newImagePath;
        debugPrint('✅ Food card image saved: $newImagePath');
      }
      return newImagePath;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      rethrow;
    }
  }

  /// Remove current image
  void removeImage() {
    imagePath = null;
  }

  /// Validate form inputs
  String? validateInputs() {
    // Validate name
    final name = nameController.text.trim();
    if (name.isEmpty) {
      return AppConstants.nameRequired;
    }
    if (name.length > AppConstants.maxFoodNameLength) {
      return AppConstants.nameTooLong;
    }

    // Validate serving size
    final servingSize = double.tryParse(servingSizeController.text);
    if (servingSize == null || servingSize <= 0) {
      return AppConstants.invalidServingSize;
    }

    // Validate calories
    final calories = double.tryParse(caloriesController.text);
    if (calories == null || calories < AppConstants.minCaloriesValue) {
      return AppConstants.invalidCalories;
    }
    if (calories > AppConstants.maxCaloriesValue) {
      return AppConstants.invalidCalories;
    }

    // Validate protein
    final protein = double.tryParse(proteinController.text);
    if (protein == null || protein < AppConstants.minNutrientValue) {
      return AppConstants.invalidProtein;
    }
    if (protein > AppConstants.maxNutrientValue) {
      return AppConstants.invalidProtein;
    }

    // Validate carbs
    final carbs = double.tryParse(carbsController.text);
    if (carbs == null || carbs < AppConstants.minNutrientValue) {
      return AppConstants.invalidCarbs;
    }
    if (carbs > AppConstants.maxNutrientValue) {
      return AppConstants.invalidCarbs;
    }

    // Validate fat
    final fat = double.tryParse(fatController.text);
    if (fat == null || fat < AppConstants.minNutrientValue) {
      return AppConstants.invalidFat;
    }
    if (fat > AppConstants.maxNutrientValue) {
      return AppConstants.invalidFat;
    }

    // Validate cost (optional, but if provided must be valid)
    final costText = costController.text.trim();
    if (costText.isNotEmpty) {
      final cost = double.tryParse(costText);
      if (cost == null || cost < 0) {
        return AppConstants.invalidCost;
      }
    }

    return null; // All valid
  }

  /// Save the updated food item
  Future<bool> save() async {
    final validationError = validateInputs();
    if (validationError != null) {
      throw Exception(validationError);
    }

    final name = nameController.text.trim();
    final servingSize = double.parse(servingSizeController.text);
    final caloriesTotal = double.parse(caloriesController.text);
    final proteinTotal = double.parse(proteinController.text);
    final carbsTotal = double.parse(carbsController.text);
    final fatTotal = double.parse(fatController.text);

    final costText = costController.text.trim();
    final costTotal = costText.isNotEmpty ? double.tryParse(costText) : null;

    isLoading = true;

    try {
      // Determine if this is a new item (empty name on original food item)
      final isNewItem = foodItem.name.isEmpty;

      // Convert total values back to per-unit values for storage
      // The controllers contain total values (after auto-recalculation),
      // but FoodItem stores per-unit values that get multiplied by servingSize for display
      final caloriesPerUnit = _toPerUnit(caloriesTotal, servingSize);
      final proteinPerUnit = _toPerUnit(proteinTotal, servingSize);
      final carbsPerUnit = _toPerUnit(carbsTotal, servingSize);
      final fatPerUnit = _toPerUnit(fatTotal, servingSize);
      final costPerUnit = costTotal != null ? _toPerUnit(costTotal, servingSize) : null;

      // Create updated/new food item with per-unit values
      final updatedItem = foodItem.copyWith(
        name: name,
        servingSize: servingSize,
        calories: caloriesPerUnit,
        proteins: proteinPerUnit,
        carbs: carbsPerUnit,
        fats: fatPerUnit,
        cost: costPerUnit,
        imagePath: imagePath,
      );

      // Save to repository - use saveFoodEntry for new items, updateFoodEntry for existing
      final success = isNewItem
          ? await _foodRepository.storageService.saveFoodEntry(updatedItem)
          : await _foodRepository.storageService.updateFoodEntry(updatedItem);

      if (success) {
        onUpdated?.call();
      }

      return success;
    } catch (e) {
      debugPrint('Error saving food item: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Delete the food item
  Future<bool> delete() async {
    isLoading = true;

    try {
      // Delete the food entry from storage
      final success = await _foodRepository.storageService.deleteFoodEntry(
        foodItem.id,
        foodItem.timestamp,
      );

      if (success) {
        // Also delete the associated food card image
        if (foodItem.imagePath != null) {
          await FoodImageService.deleteImage(foodItem.imagePath);
        }

        onUpdated?.call();
      }

      return success;
    } catch (e) {
      debugPrint('Error deleting food item: $e');
      rethrow;
    } finally {
      isLoading = false;
    }
  }
}
