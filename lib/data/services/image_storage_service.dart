// lib/data/services/image_storage_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';
import '../../config/constants/app_constants.dart';

/// Service responsible for image file storage and management
/// Handles saving, retrieving, and deleting image files
class ImageStorageService {
  final LocalStorage _storage = LocalStorage();

  // Private constructor for singleton
  ImageStorageService._internal();
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;

  /// Save an image file to local storage
  /// Returns the path to the saved image, or null if failed
  Future<String?> saveImageFile(File imageFile) async {
    try {
      // Get the app's documents directory (via LocalStorage method)
      final documentsDir = await _storage.getTemporaryDirectory();

      // Create a folder for food images if it doesn't exist
      final foodImagesDir = Directory('${documentsDir.path}/${AppConstants.tempImageFolderKey}');
      if (!await foodImagesDir.exists()) {
        await foodImagesDir.create(recursive: true);
      }

      // Generate a unique filename based on timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${foodImagesDir.path}/food_$timestamp.jpg';

      // Copy the file to our app's storage
      final savedImage = await imageFile.copy(newPath);

      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image file: $e');
      return null;
    }
  }

  /// Get an image file from storage
  /// Returns the File object if it exists, null otherwise
  Future<File?> getImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image file: $e');
      return null;
    }
  }

  /// Check if an image file exists
  Future<bool> imageExists(String imagePath) async {
    try {
      if (imagePath.isEmpty) return false;
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete an image file from storage
  /// Returns true if successfully deleted, false otherwise
  Future<bool> deleteImageFile(String imagePath) async {
    try {
      if (imagePath.isEmpty) return false;
      
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false; // File didn't exist
    } catch (e) {
      debugPrint('Error deleting image file: $e');
      return false;
    }
  }

  /// Delete multiple image files
  /// Returns the number of files successfully deleted
  Future<int> deleteImageFiles(List<String> imagePaths) async {
    int deletedCount = 0;
    
    for (final path in imagePaths) {
      if (await deleteImageFile(path)) {
        deletedCount++;
      }
    }
    
    return deletedCount;
  }

  /// Get the size of an image file in bytes
  /// Returns the file size, or 0 if file doesn't exist or error
  Future<int> getImageFileSize(String imagePath) async {
    try {
      if (imagePath.isEmpty) return 0;
      
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting image file size: $e');
      return 0;
    }
  }

  /// Get all food image files from storage
  /// Returns a list of File objects
  Future<List<File>> getAllFoodImages() async {
    try {
      final documentsDir = await _storage.getTemporaryDirectory();
      final foodImagesDir = Directory('${documentsDir.path}/${AppConstants.tempImageFolderKey}');
      
      if (!await foodImagesDir.exists()) {
        return [];
      }

      final entities = await foodImagesDir.list().toList();
      final imageFiles = <File>[];
      
      for (final entity in entities) {
        if (entity is File && _isImageFile(entity.path)) {
          imageFiles.add(entity);
        }
      }
      
      // Sort by modification time (newest first)
      imageFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      return imageFiles;
    } catch (e) {
      debugPrint('Error getting all food images: $e');
      return [];
    }
  }

  /// Clean up old image files (older than specified days)
  /// Returns the number of files deleted
  Future<int> cleanupOldImages({int olderThanDays = 30}) async {
    try {
      final allImages = await getAllFoodImages();
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      int deletedCount = 0;
      
      for (final imageFile in allImages) {
        try {
          final lastModified = await imageFile.lastModified();
          if (lastModified.isBefore(cutoffDate)) {
            await imageFile.delete();
            deletedCount++;
          }
        } catch (e) {
          // Continue with other files if one fails
          continue;
        }
      }
      
      return deletedCount;
    } catch (e) {
      debugPrint('Error cleaning up old images: $e');
      return 0;
    }
  }

  /// Get total storage used by food images in bytes
  Future<int> getTotalImageStorageUsed() async {
    try {
      final allImages = await getAllFoodImages();
      int totalSize = 0;
      
      for (final imageFile in allImages) {
        try {
          totalSize += await imageFile.length();
        } catch (e) {
          // Continue counting other files if one fails
          continue;
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating total image storage: $e');
      return 0;
    }
  }

  /// Format storage size for display (bytes to human readable)
  String formatStorageSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Clear all food images from storage
  /// Returns the number of files deleted
  Future<int> clearAllImages() async {
    try {
      final documentsDir = await _storage.getTemporaryDirectory();
      final foodImagesDir = Directory('${documentsDir.path}/${AppConstants.tempImageFolderKey}');
      
      if (!await foodImagesDir.exists()) {
        return 0;
      }

      final entities = await foodImagesDir.list().toList();
      int deletedCount = 0;
      
      for (final entity in entities) {
        try {
          if (entity is File) {
            await entity.delete();
            deletedCount++;
          }
        } catch (e) {
          // Continue with other files if one fails
          continue;
        }
      }
      
      return deletedCount;
    } catch (e) {
      debugPrint('Error clearing all images: $e');
      return 0;
    }
  }

  /// Create backup of image file
  /// Returns the path to backup file, or null if failed
  Future<String?> createImageBackup(String imagePath, String backupSuffix) async {
    try {
      if (imagePath.isEmpty) return null;
      
      final originalFile = File(imagePath);
      if (!await originalFile.exists()) return null;
      
      // Create backup path
      final pathParts = imagePath.split('.');
      final extension = pathParts.isNotEmpty ? pathParts.last : 'jpg';
      final basePathWithoutExtension = imagePath.substring(0, imagePath.length - extension.length - 1);
      final backupPath = '${basePathWithoutExtension}_$backupSuffix.$extension';
      
      // Copy file to backup location
      final backupFile = await originalFile.copy(backupPath);
      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating image backup: $e');
      return null;
    }
  }

  /// Check if a file path represents an image file
  bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
}