// lib/data/services/image_storage_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../storage/local_storage.dart';
import '../../config/constants/app_constants.dart';

/// Service responsible for image file storage and management
/// FIXED: Now stores relative paths to avoid container UUID issues
class ImageStorageService {
  final LocalStorage _storage = LocalStorage();

  // Private constructor for singleton
  ImageStorageService._internal();
  static final ImageStorageService _instance = ImageStorageService._internal();
  factory ImageStorageService() => _instance;

  /// Get the food images directory path
  Future<Directory> _getFoodImagesDirectory() async {
    final documentsDir = await _storage.getTemporaryDirectory();
    final foodImagesDir = Directory('${documentsDir.path}/${AppConstants.tempImageFolderKey}');
    
    if (!await foodImagesDir.exists()) {
      await foodImagesDir.create(recursive: true);
    }
    
    return foodImagesDir;
  }

  /// Save an image file to local storage
  /// Returns the RELATIVE path (just filename), or null if failed
  Future<String?> saveImageFile(File imageFile) async {
    try {
      final foodImagesDir = await _getFoodImagesDirectory();

      // Generate a unique filename based on timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'food_$timestamp.jpg';
      final newPath = '${foodImagesDir.path}/$filename';

      // Copy the file to our app's storage
      await imageFile.copy(newPath);

      // IMPORTANT: Return only the filename, not the full path
      return filename;
    } catch (e) {
      debugPrint('Error saving image file: $e');
      return null;
    }
  }

  /// Get an image file from storage using relative path (filename)
  /// Returns the File object if it exists, null otherwise
  Future<File?> getImageFile(String imagePath) async {
    try {
      String fullPath;
      
      // Handle both relative and absolute paths for backward compatibility
      if (imagePath.startsWith('/') || imagePath.contains('Application')) {
        // It's an absolute path - try to use it directly first
        final file = File(imagePath);
        if (await file.exists()) {
          return file;
        }
        
        // If absolute path doesn't work, extract filename and try relative
        final filename = imagePath.split('/').last;
        final foodImagesDir = await _getFoodImagesDirectory();
        fullPath = '${foodImagesDir.path}/$filename';
      } else {
        // It's a relative path (filename) - build full path
        final foodImagesDir = await _getFoodImagesDirectory();
        fullPath = '${foodImagesDir.path}/$imagePath';
      }
      
      final file = File(fullPath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting image file: $e');
      return null;
    }
  }

  /// Check if an image file exists using relative path (filename)
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = await getImageFile(imagePath);
      return file != null;
    } catch (e) {
      return false;
    }
  }

  /// Delete an image file from storage using relative path (filename)
  /// Returns true if successfully deleted, false otherwise
  Future<bool> deleteImageFile(String imagePath) async {
    try {
      final file = await getImageFile(imagePath);
      if (file != null) {
        await file.delete();
        return true;
      }
      return false;
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

  /// Get the size of an image file in bytes using relative path (filename)
  /// Returns the file size, or 0 if file doesn't exist or error
  Future<int> getImageFileSize(String imagePath) async {
    try {
      final file = await getImageFile(imagePath);
      if (file != null) {
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
      final foodImagesDir = await _getFoodImagesDirectory();
      
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
      final foodImagesDir = await _getFoodImagesDirectory();
      
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

  /// Create backup of image file using relative path (filename)
  /// Returns the filename of backup file, or null if failed
  Future<String?> createImageBackup(String imagePath, String backupSuffix) async {
    try {
      final file = await getImageFile(imagePath);
      if (file == null) return null;
      
      // Extract filename without extension
      final filename = imagePath.contains('/') ? imagePath.split('/').last : imagePath;
      final pathParts = filename.split('.');
      final extension = pathParts.isNotEmpty ? pathParts.last : 'jpg';
      final baseNameWithoutExtension = filename.substring(0, filename.length - extension.length - 1);
      final backupFilename = '${baseNameWithoutExtension}_$backupSuffix.$extension';
      
      // Create backup in same directory
      final foodImagesDir = await _getFoodImagesDirectory();
      final backupPath = '${foodImagesDir.path}/$backupFilename';
      
      await file.copy(backupPath);
      return backupFilename; // Return relative path (filename)
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

  /// DEBUG: Enhanced image storage debugging
  Future<Map<String, dynamic>> debugImageStorage() async {
    try {
      debugPrint('=== IMAGE STORAGE DEBUG ===');
      
      final foodImagesDir = await _getFoodImagesDirectory();
      debugPrint('Food images directory: ${foodImagesDir.path}');
      debugPrint('Directory exists: ${await foodImagesDir.exists()}');
      
      if (await foodImagesDir.exists()) {
        final entities = await foodImagesDir.list().toList();
        final imageFiles = entities.where((e) => e is File && _isImageFile(e.path)).toList();
        
        debugPrint('Files in directory: ${entities.length}');
        debugPrint('Image files: ${imageFiles.length}');
        
        // Show first few image files
        for (int i = 0; i < imageFiles.length && i < 5; i++) {
          final file = imageFiles[i] as File;
          final filename = file.path.split('/').last;
          final size = await file.length();
          final modified = await file.lastModified();
          debugPrint('  $filename - ${size} bytes - $modified');
        }
        
        if (imageFiles.length > 5) {
          debugPrint('  ... and ${imageFiles.length - 5} more files');
        }
      }
      
      debugPrint('=== END IMAGE STORAGE DEBUG ===');
      
      return {
        'directory': foodImagesDir.path,
        'exists': await foodImagesDir.exists(),
        'fileCount': await foodImagesDir.exists() 
            ? (await foodImagesDir.list().toList()).length 
            : 0,
      };
    } catch (e) {
      debugPrint('Error in image storage debug: $e');
      return {'error': e.toString()};
    }
  }

  /// MIGRATION: Convert absolute paths to relative paths
  Future<String?> migrateAbsoluteToRelativePath(String absolutePath) async {
    try {
      if (!absolutePath.startsWith('/') && !absolutePath.contains('Application')) {
        // Already a relative path
        return absolutePath;
      }
      
      // Extract filename from absolute path
      final filename = absolutePath.split('/').last;
      
      // Check if file exists with this filename
      final file = await getImageFile(filename);
      if (file != null) {
        return filename;
      }
      
      return null; // File doesn't exist
    } catch (e) {
      debugPrint('Error migrating path: $e');
      return null;
    }
  }
}