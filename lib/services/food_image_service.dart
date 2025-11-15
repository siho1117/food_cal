import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Service for managing food card images
///
/// Features:
/// - Creates optimized copies of user photos (smaller file size)
/// - Stores images with metadata (creation timestamp)
/// - Automatically deletes images older than 35 days
/// - Manages storage efficiently
class FoodImageService {
  static const String _imageDirectoryName = 'food_card_images';
  static const int _imageRetentionDays = 35;
  static const int _maxImageWidth = 1200;
  static const int _maxImageHeight = 1200;
  static const int _imageQuality = 85; // 85% quality = good balance

  /// Pick image from camera or gallery and save optimized copy
  ///
  /// Returns the file path of the saved image, or null if cancelled/failed.
  ///
  /// The image is automatically optimized:
  /// - Resized to max 1200×1200 (preserves aspect ratio)
  /// - Compressed to 85% quality
  /// - Typically reduces file size to 200-500 KB
  ///
  /// Usage:
  /// ```dart
  /// final imagePath = await FoodImageService.pickAndSaveImage(
  ///   source: ImageSource.camera,
  /// );
  /// ```
  static Future<String?> pickAndSaveImage({
    required ImageSource source,
  }) async {
    try {
      // Pick image with optimization
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: source,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _imageQuality,
      );

      if (photo == null) {
        return null; // User cancelled
      }

      // Save to app storage
      return await _saveImageToStorage(photo);
    } catch (e) {
      debugPrint('❌ Error picking/saving image: $e');
      return null;
    }
  }

  /// Save existing image file as optimized food card image
  ///
  /// This is used during food analysis to save the analysis photo
  /// as a good quality food card image BEFORE compression.
  ///
  /// Returns ONLY the filename (relative path) to avoid iOS container UUID issues
  ///
  /// The image is automatically optimized:
  /// - Resized to max 1200×1200 (preserves aspect ratio)
  /// - Compressed to 85% quality
  /// - Typically reduces file size to 200-500 KB
  ///
  /// Usage:
  /// ```dart
  /// // During food analysis:
  /// final originalPhoto = File(imageFile.path);
  /// final foodCardPath = await FoodImageService.saveImageFromFile(originalPhoto);
  /// ```
  static Future<String> saveImageFromFile(File imageFile) async {
    try {
      // Get app's permanent storage directory
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/$_imageDirectoryName');

      // Create directory if doesn't exist
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'food_$timestamp.jpg';
      final savedPath = '${imageDir.path}/$fileName';

      // Compress and save the image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: _maxImageWidth,
        minHeight: _maxImageHeight,
        quality: _imageQuality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null) {
        // Write compressed bytes to file
        final savedFile = File(savedPath);
        await savedFile.writeAsBytes(compressedBytes);

        debugPrint('✅ Saved food card image from file: $savedPath');
        // IMPORTANT: Return only filename (relative path)
        return fileName;
      } else {
        // Fallback: just copy the original if compression fails
        await imageFile.copy(savedPath);
        debugPrint('⚠️ Compression failed, copied original: $savedPath');
        // IMPORTANT: Return only filename (relative path)
        return fileName;
      }
    } catch (e) {
      debugPrint('❌ Error saving image from file: $e');
      rethrow;
    }
  }

  /// Save XFile to permanent app storage
  ///
  /// Creates directory structure:
  /// /app_documents/food_card_images/food_1234567890.jpg
  ///
  /// Returns ONLY the filename (relative path) to avoid iOS container UUID issues
  static Future<String> _saveImageToStorage(XFile photo) async {
    // Get app's permanent storage directory
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/$_imageDirectoryName');

    // Create directory if doesn't exist
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // Generate filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'food_$timestamp.jpg';
    final savedPath = '${imageDir.path}/$fileName';

    // Copy file to permanent storage
    await File(photo.path).copy(savedPath);

    debugPrint('✅ Saved food card image: $savedPath');

    // IMPORTANT: Return only filename (relative path) to avoid iOS container issues
    return fileName;
  }

  /// Get the full file path from a relative path (filename)
  ///
  /// Handles both:
  /// - New relative paths (filename only): "food_1234567890.jpg"
  /// - Old absolute paths (for backward compatibility): "/var/.../food_1234567890.jpg"
  ///
  /// Returns File object if exists, null otherwise.
  ///
  /// Usage:
  /// ```dart
  /// final imageFile = await FoodImageService.getImageFile(foodItem.imagePath);
  /// if (imageFile != null) {
  ///   // Display image
  ///   Image.file(imageFile);
  /// }
  /// ```
  static Future<File?> getImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      String fullPath;

      // Handle both relative and absolute paths for backward compatibility
      if (imagePath.startsWith('/') || imagePath.contains('Application')) {
        // It's an old absolute path - try to use it directly first
        final file = File(imagePath);
        if (await file.exists()) {
          return file;
        }

        // If absolute path doesn't work, extract filename and try relative
        final filename = imagePath.split('/').last;
        final appDir = await getApplicationDocumentsDirectory();
        final imageDir = Directory('${appDir.path}/$_imageDirectoryName');
        fullPath = '${imageDir.path}/$filename';
      } else {
        // It's a new relative path (filename) - build full path
        final appDir = await getApplicationDocumentsDirectory();
        final imageDir = Directory('${appDir.path}/$_imageDirectoryName');
        fullPath = '${imageDir.path}/$imagePath';
      }

      final file = File(fullPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting image file: $e');
      return null;
    }
  }

  /// Delete a specific food card image
  ///
  /// Call this when a food item is deleted by the user.
  /// Handles both relative and absolute paths for backward compatibility.
  ///
  /// Usage:
  /// ```dart
  /// await FoodImageService.deleteImage(foodItem.imagePath);
  /// ```
  static Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    try {
      final file = await getImageFile(imagePath);
      if (file != null && await file.exists()) {
        await file.delete();
        debugPrint('✅ Deleted food card image: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Clean up images older than 35 days
  ///
  /// Call this periodically (e.g., on app startup) to free storage.
  /// Automatically deletes food card images that are 35+ days old.
  ///
  /// Returns the number of images deleted.
  ///
  /// Usage:
  /// ```dart
  /// final deletedCount = await FoodImageService.cleanupOldImages();
  /// debugPrint('Cleaned up $deletedCount old images');
  /// ```
  static Future<int> cleanupOldImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/$_imageDirectoryName');

      if (!await imageDir.exists()) {
        return 0; // No images to clean
      }

      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: _imageRetentionDays));
      int deletedCount = 0;

      // List all files in directory
      final files = imageDir.listSync();

      for (final file in files) {
        if (file is File && file.path.endsWith('.jpg')) {
          // Get file creation/modification time
          final fileStat = await file.stat();
          final fileDate = fileStat.modified;

          // Delete if older than 35 days
          if (fileDate.isBefore(cutoffDate)) {
            try {
              await file.delete();
              deletedCount++;
              debugPrint('🗑️ Deleted old image: ${file.path}');
            } catch (e) {
              debugPrint('❌ Failed to delete old image: $e');
            }
          }
        }
      }

      if (deletedCount > 0) {
        debugPrint('✅ Cleanup complete: deleted $deletedCount old food card images');
      } else {
        debugPrint('✅ Cleanup complete: no old images to delete');
      }

      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error during image cleanup: $e');
      return 0;
    }
  }

  /// Get total storage used by food card images
  ///
  /// Returns size in bytes.
  ///
  /// Usage:
  /// ```dart
  /// final bytes = await FoodImageService.getTotalStorageUsed();
  /// final mb = bytes / (1024 * 1024);
  /// debugPrint('Food images using ${mb.toStringAsFixed(2)} MB');
  /// ```
  static Future<int> getTotalStorageUsed() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/$_imageDirectoryName');

      if (!await imageDir.exists()) {
        return 0;
      }

      int totalBytes = 0;
      final files = imageDir.listSync();

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalBytes += stat.size;
        }
      }

      return totalBytes;
    } catch (e) {
      debugPrint('❌ Error calculating storage: $e');
      return 0;
    }
  }

  /// Get count of food card images
  ///
  /// Usage:
  /// ```dart
  /// final count = await FoodImageService.getImageCount();
  /// ```
  static Future<int> getImageCount() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/$_imageDirectoryName');

      if (!await imageDir.exists()) {
        return 0;
      }

      final files = imageDir.listSync();
      return files.where((f) => f is File && f.path.endsWith('.jpg')).length;
    } catch (e) {
      debugPrint('❌ Error counting images: $e');
      return 0;
    }
  }
}
