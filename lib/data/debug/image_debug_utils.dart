// lib/data/debug/image_debug_utils.dart
import 'package:flutter/foundation.dart';
import '../services/image_storage_service.dart';

/// Debug utilities for troubleshooting image storage
/// These methods should only be used in debug mode
class ImageDebugUtils {
  final ImageStorageService _imageService = ImageStorageService();

  /// DEBUG: Enhanced image storage debugging
  Future<Map<String, dynamic>> debugImageStorage() async {
    try {
      debugPrint('=== IMAGE STORAGE DEBUG ===');

      // Get all images from the service
      final allImages = await _imageService.getAllFoodImages();
      debugPrint('Total image files found: ${allImages.length}');

      // Show first few image files
      for (int i = 0; i < allImages.length && i < 5; i++) {
        final file = allImages[i];
        final filename = file.path.split('/').last;
        final size = await file.length();
        final modified = await file.lastModified();
        debugPrint('  $filename - $size bytes - $modified');
      }

      if (allImages.length > 5) {
        debugPrint('  ... and ${allImages.length - 5} more files');
      }

      // Get storage size
      final totalSize = await _imageService.getTotalImageStorageUsed();
      final formattedSize = _imageService.formatStorageSize(totalSize);
      debugPrint('Total storage used: $formattedSize');

      debugPrint('=== END IMAGE STORAGE DEBUG ===');

      return {
        'fileCount': allImages.length,
        'totalSize': totalSize,
        'formattedSize': formattedSize,
      };
    } catch (e) {
      debugPrint('Error in image storage debug: $e');
      return {'error': e.toString()};
    }
  }
}
