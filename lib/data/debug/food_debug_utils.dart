// lib/data/debug/food_debug_utils.dart
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/food_storage_service.dart';
import '../services/image_storage_service.dart';

/// Debug utilities for troubleshooting food data and image storage
/// These methods should only be used in debug mode
class FoodDebugUtils {
  final FoodStorageService _storageService = FoodStorageService();
  final ImageStorageService _imageService = ImageStorageService();

  /// DEBUG: Check food item images and their paths
  Future<void> debugFoodItemImages() async {
    try {
      final allEntries = await _storageService.getAllFoodEntries();
      debugPrint('=== FOOD ITEM IMAGE DEBUG ===');
      debugPrint('Total food entries: ${allEntries.length}');

      int entriesWithImages = 0;
      int existingImages = 0;
      int migratedPaths = 0;

      for (final entry in allEntries) {
        if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
          entriesWithImages++;

          // Use ImageStorageService to properly check relative paths
          final imageFile = await _imageService.getImageFile(entry.imagePath!);
          final exists = imageFile != null;

          debugPrint('Food: ${entry.name}');
          debugPrint('  Image path: ${entry.imagePath}');
          debugPrint('  Image exists: $exists');
          debugPrint('  Timestamp: ${entry.timestamp}');

          if (exists) {
            existingImages++;
            final size = await imageFile.length();
            debugPrint('  Image size: $size bytes');
          } else {
            // Try to migrate absolute path to relative
            final relativePath = await _imageService
                .migrateAbsoluteToRelativePath(entry.imagePath!);
            if (relativePath != null) {
              debugPrint(
                  '  MIGRATION: Can migrate to relative path: $relativePath');
              migratedPaths++;
            } else {
              debugPrint('  ERROR: Image file not found and cannot migrate');
            }
          }
          debugPrint('---');
        } else {
          debugPrint('Food: ${entry.name} (NO IMAGE PATH)');
        }
      }

      debugPrint('Summary:');
      debugPrint('  Total entries: ${allEntries.length}');
      debugPrint('  Entries with image paths: $entriesWithImages');
      debugPrint('  Images that actually exist: $existingImages');
      debugPrint('  Paths that can be migrated: $migratedPaths');
      debugPrint('=== END FOOD ITEM DEBUG ===');
    } catch (e) {
      debugPrint('Error debugging food items: $e');
    }
  }

  /// MIGRATION: Fix all food entries with absolute paths
  Future<void> migrateImagePaths() async {
    try {
      debugPrint('=== STARTING IMAGE PATH MIGRATION ===');

      final allEntries = await _storageService.getAllFoodEntries();
      int migratedCount = 0;
      int failedCount = 0;

      for (final entry in allEntries) {
        if (entry.imagePath != null &&
            entry.imagePath!.isNotEmpty &&
            (entry.imagePath!.startsWith('/') ||
                entry.imagePath!.contains('Application'))) {
          // Try to migrate this absolute path
          final relativePath =
              await _imageService.migrateAbsoluteToRelativePath(entry.imagePath!);

          if (relativePath != null) {
            // Update the food entry with the relative path
            final updatedEntry = entry.copyWith(imagePath: relativePath);
            final success = await _storageService.updateFoodEntry(updatedEntry);

            if (success) {
              migratedCount++;
              debugPrint('✅ Migrated: ${entry.name} -> $relativePath');
            } else {
              failedCount++;
              debugPrint('❌ Failed to update: ${entry.name}');
            }
          } else {
            failedCount++;
            debugPrint('❌ Cannot migrate: ${entry.name} - image not found');
          }
        }
      }

      debugPrint('=== MIGRATION COMPLETE ===');
      debugPrint('Successfully migrated: $migratedCount');
      debugPrint('Failed migrations: $failedCount');
    } catch (e) {
      debugPrint('Error during migration: $e');
    }
  }

  /// DEBUG: Test the complete image workflow
  Future<void> debugCompleteImageWorkflow() async {
    try {
      debugPrint('=== COMPLETE IMAGE WORKFLOW DEBUG ===');

      debugPrint('Checking image storage...');

      // Check food items
      await debugFoodItemImages();

      // Test image service methods
      final allImages = await _imageService.getAllFoodImages();
      debugPrint('Images found by getAllFoodImages(): ${allImages.length}');
      for (final img in allImages) {
        debugPrint('  Image: ${img.path}');
      }

      debugPrint('=== END COMPLETE WORKFLOW DEBUG ===');
    } catch (e) {
      debugPrint('Error in complete workflow debug: $e');
    }
  }

  /// DEBUG: Clear all data for testing
  Future<void> debugClearAllData() async {
    try {
      debugPrint('=== CLEARING ALL DEBUG DATA ===');

      // Clear images
      final deletedCount = await _imageService.clearAllImages();

      debugPrint('Deleted $deletedCount image files');
      debugPrint(
          'Note: Food entries not cleared - add method to FoodStorageService if needed');
      debugPrint('=== DEBUG CLEAR COMPLETE ===');
    } catch (e) {
      debugPrint('Error clearing debug data: $e');
    }
  }

  /// DEBUG: Create test food entry with image
  Future<void> debugCreateTestFoodWithImage() async {
    try {
      debugPrint('=== CREATING TEST FOOD WITH IMAGE ===');

      // Create a test food item (without actual image file)
      final testFood = FoodItem(
        id: 'debug_test_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Debug Test Food',
        calories: 100.0,
        proteins: 5.0,
        carbs: 15.0,
        fats: 2.0,
        mealType: 'snack',
        timestamp: DateTime.now(),
        servingSize: 1.0,
        servingUnit: 'serving',
        imagePath: '/fake/path/to/test/image.jpg', // Fake path for testing
      );

      final saved = await _storageService.saveFoodEntry(testFood);
      debugPrint('Test food saved: $saved');
      debugPrint('Test food image path: ${testFood.imagePath}');
      debugPrint('=== TEST FOOD CREATION COMPLETE ===');
    } catch (e) {
      debugPrint('Error creating test food: $e');
    }
  }
}
