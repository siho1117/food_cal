import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'food_image_service.dart';

/// Service for app initialization tasks
///
/// Handles startup tasks like:
/// - Cleaning up old food_images directory (deprecated ImageStorageService)
/// - Cleaning up old food card images (35+ days)
/// - Other initialization logic as needed
class AppInitializationService {
  /// Initialize the app on startup
  ///
  /// Call this in main() or in the main app widget's initState.
  ///
  /// Tasks performed:
  /// 1. Clean up food card images older than 35 days
  /// 2. (Future: other initialization tasks)
  ///
  /// Usage:
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await AppInitializationService.initialize();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> initialize() async {
    debugPrint('🚀 App initialization started...');

    // Clean up old food_images directory (from old ImageStorageService)
    await _cleanupOldImageDirectory();

    // Clean up old food card images
    await _cleanupOldImages();

    debugPrint('✅ App initialization complete');
  }

  /// Clean up old food_images directory from deprecated ImageStorageService
  static Future<void> _cleanupOldImageDirectory() async {
    try {
      debugPrint('🧹 Cleaning up old food_images directory...');
      final appDir = await getApplicationDocumentsDirectory();
      final oldImageDir = Directory('${appDir.path}/food_images');

      if (await oldImageDir.exists()) {
        // Delete the entire directory and its contents
        await oldImageDir.delete(recursive: true);
        debugPrint('✅ Deleted old food_images directory');
      } else {
        debugPrint('✅ Old food_images directory not found (already cleaned)');
      }
    } catch (e) {
      debugPrint('❌ Error during old directory cleanup: $e');
    }
  }

  /// Clean up food card images older than 35 days
  static Future<void> _cleanupOldImages() async {
    try {
      debugPrint('🧹 Cleaning up old food card images...');
      final deletedCount = await FoodImageService.cleanupOldImages();

      if (deletedCount > 0) {
        debugPrint('✅ Deleted $deletedCount old food card image(s)');
      } else {
        debugPrint('✅ No old food card images to clean up');
      }
    } catch (e) {
      debugPrint('❌ Error during image cleanup: $e');
    }
  }

  /// Get app storage statistics
  ///
  /// Useful for debugging or showing storage info to user.
  ///
  /// Usage:
  /// ```dart
  /// final stats = await AppInitializationService.getStorageStats();
  /// print('Food images: ${stats['imageCount']} files, ${stats['storageMB']} MB');
  /// ```
  static Future<Map<String, dynamic>> getStorageStats() async {
    final imageCount = await FoodImageService.getImageCount();
    final storageBytes = await FoodImageService.getTotalStorageUsed();
    final storageMB = storageBytes / (1024 * 1024);

    return {
      'imageCount': imageCount,
      'storageBytes': storageBytes,
      'storageMB': storageMB.toStringAsFixed(2),
    };
  }
}
