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

  QuickEditFoodController({
    required this.foodItem,
    this.onUpdated,
  }) {
    // Initialize controllers with food item data
    nameController = TextEditingController(text: foodItem.name);
    servingSizeController = TextEditingController(text: foodItem.servingSize.toString());
    caloriesController = TextEditingController(text: foodItem.calories.round().toString());
    proteinController = TextEditingController(text: foodItem.proteins.round().toString());
    carbsController = TextEditingController(text: foodItem.carbs.round().toString());
    fatController = TextEditingController(text: foodItem.fats.round().toString());
    costController = TextEditingController(
      text: foodItem.cost?.toStringAsFixed(2) ?? ''
    );

    // Initialize image path
    imagePath = foodItem.imagePath;
  }

  /// Dispose all text controllers
  void dispose() {
    nameController.dispose();
    servingSizeController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    costController.dispose();
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
    final calories = double.parse(caloriesController.text);
    final protein = double.parse(proteinController.text);
    final carbs = double.parse(carbsController.text);
    final fat = double.parse(fatController.text);

    final costText = costController.text.trim();
    final cost = costText.isNotEmpty ? double.tryParse(costText) : null;

    isLoading = true;

    try {
      // Determine if this is a new item (empty name on original food item)
      final isNewItem = foodItem.name.isEmpty;

      // Create updated/new food item
      final updatedItem = foodItem.copyWith(
        name: name,
        servingSize: servingSize,
        calories: calories,
        proteins: protein,
        carbs: carbs,
        fats: fat,
        cost: cost,
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
