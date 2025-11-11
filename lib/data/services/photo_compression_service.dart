// lib/data/services/photo_compression_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../models/food_item.dart';
import '../repositories/food_repository.dart';

/// **CORE SERVICE - Photo Compression & Food Recognition Pipeline**
///
/// This is the heart of the app - handles the complete flow:
/// 1. Camera/Gallery photo capture (robust)
/// 2. Save original photo to device gallery (100% quality)
/// 3. Compress & optimize image for API (512x512 @ 60% JPEG)
/// 4. Call food recognition API
/// 5. Return results
///
/// **Design Principles:**
/// - Isolated from UI concerns
/// - Reusable across different UI implementations
/// - Robust error handling
/// - Production-ready camera handling
/// - Cost-effective compression (3MB → 55KB saves money at scale)
///
/// **This file should remain stable even if UI changes**
class PhotoCompressionService {
  final ImagePicker _picker = ImagePicker();
  final FoodRepository _repository = FoodRepository();

  // ═══════════════════════════════════════════════════════════
  // PUBLIC API - Main entry points
  // ═══════════════════════════════════════════════════════════

  /// Capture photo from camera → save to gallery → recognize food
  Future<FoodRecognitionResult> captureFromCamera() async {
    return await _processImageSource(
      ImageSource.camera,
      saveToGallery: true,
    );
  }

  /// Select photo from gallery → recognize food (no need to save again)
  Future<FoodRecognitionResult> selectFromGallery() async {
    return await _processImageSource(
      ImageSource.gallery,
      saveToGallery: false, // Already in gallery
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CORE PIPELINE - Private implementation
  // ═══════════════════════════════════════════════════════════

  /// Main processing pipeline
  Future<FoodRecognitionResult> _processImageSource(
    ImageSource source, {
    required bool saveToGallery,
  }) async {
    try {
      // STEP 1: Capture/Select Image (Robust camera handling)
      final XFile? pickedFile = await _pickImageRobust(source);

      if (pickedFile == null) {
        return FoodRecognitionResult.cancelled();
      }

      File imageFile = File(pickedFile.path);

      // STEP 2: Save to Gallery (if from camera)
      if (saveToGallery) {
        final saved = await _saveToGallery(imageFile);
        if (!saved) {
          debugPrint('⚠️ Failed to save to gallery, continuing anyway...');
        }
      }

      // STEP 3: Optimize for API (Reduce size, maintain quality)
      final File optimizedFile = await _optimizeForAPI(imageFile);

      // STEP 4: Call Food Recognition API (no meal type needed)
      final List<FoodItem> recognizedItems = await _repository.recognizeFood(
        optimizedFile,
      );

      // STEP 5: Return Results
      return FoodRecognitionResult.success(recognizedItems);
    } on CameraException catch (e) {
      return FoodRecognitionResult.error('Camera error: ${e.description}');
    } on ImageCompressionException catch (e) {
      return FoodRecognitionResult.error('Image processing error: $e');
    } catch (e) {
      return FoodRecognitionResult.error('Recognition failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 1: Robust Camera Handling
  // ═══════════════════════════════════════════════════════════

  /// Pick image with robust error handling and optimal settings
  Future<XFile?> _pickImageRobust(ImageSource source) async {
    try {
      // Pick image with production-ready settings
      final XFile? result = await _picker.pickImage(
        source: source,
        // Maximum quality for gallery storage (100%)
        imageQuality: 100,
        // Prefer rear camera for food photography
        preferredCameraDevice: CameraDevice.rear,
        // Max size to prevent memory issues on large images
        maxWidth: 4096,
        maxHeight: 4096,
        // Request EXIF data for orientation
        requestFullMetadata: true,
      );

      return result;
    } catch (e) {
      // Handle platform-specific camera errors
      if (e.toString().contains('camera') ||
          e.toString().contains('Camera')) {
        throw CameraException('CAMERA_ERROR', e.toString());
      }
      throw CameraException('PICK_FAILED', e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 2: Save to Gallery
  // ═══════════════════════════════════════════════════════════

  /// Save image to device gallery (like native camera app)
  Future<bool> _saveToGallery(File imageFile) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Save to gallery with proper metadata
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100, // Keep original quality in gallery
        name: 'food_${DateTime.now().millisecondsSinceEpoch}',
        isReturnImagePathOfIOS: true,
      );

      // Check if save was successful
      if (result == null || result == false) {
        debugPrint('❌ Failed to save to gallery');
        return false;
      }

      debugPrint('✅ Saved to gallery: $result');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving to gallery: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STEP 3: Image Optimization for API
  // ═══════════════════════════════════════════════════════════

  /// Optimize image for API transmission
  /// - JPEG format (universal compatibility across all platforms)
  /// - 512x512 @ 60% quality for optimal API performance (~55KB)
  /// - Handles orientation correction automatically
  /// - OpenAI supports: png, jpeg, gif, webp (we use JPEG for simplicity)
  Future<File> _optimizeForAPI(File originalFile) async {
    // Compression settings
    const int targetWidth = 512;
    const int targetHeight = 512;
    const int quality = 60;

    debugPrint('🔄 Optimizing image for API...');
    debugPrint('   Original size: ${await originalFile.length()} bytes');
    debugPrint('   Using JPEG compression (universal format)');

    try {
      final Uint8List? jpegBytes = await FlutterImageCompress.compressWithFile(
        originalFile.absolute.path,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        autoCorrectionAngle: true,
        keepExif: true,
      );

      if (jpegBytes != null && jpegBytes.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final jpegFile = File(
          '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await jpegFile.writeAsBytes(jpegBytes);

        debugPrint('✅ JPEG compression successful: ${jpegBytes.length} bytes');
        debugPrint('   Reduction: ${((1 - jpegBytes.length / await originalFile.length()) * 100).toStringAsFixed(1)}%');

        return jpegFile;
      } else {
        debugPrint('⚠️  Compression returned null, using original');
        return originalFile;
      }
    } catch (e) {
      debugPrint('❌ JPEG compression failed: $e');
      debugPrint('   Using original file as fallback');
      return originalFile;
    }
  }

}

// ═══════════════════════════════════════════════════════════
// RESULT TYPES
// ═══════════════════════════════════════════════════════════

/// Result of food recognition operation
class FoodRecognitionResult {
  final List<FoodItem>? items;
  final String? error;
  final bool isCancelled;

  FoodRecognitionResult._({
    this.items,
    this.error,
    this.isCancelled = false,
  });

  factory FoodRecognitionResult.success(List<FoodItem> items) {
    return FoodRecognitionResult._(items: items);
  }

  factory FoodRecognitionResult.error(String error) {
    return FoodRecognitionResult._(error: error);
  }

  factory FoodRecognitionResult.cancelled() {
    return FoodRecognitionResult._(isCancelled: true);
  }

  bool get isSuccess => items != null && items!.isNotEmpty;
  bool get hasError => error != null;
}

/// Custom exception for camera-related errors
class CameraException implements Exception {
  final String code;
  final String description;

  CameraException(this.code, this.description);

  @override
  String toString() => 'CameraException($code): $description';
}

/// Custom exception for image compression errors
class ImageCompressionException implements Exception {
  final String message;

  ImageCompressionException(this.message);

  @override
  String toString() => 'ImageCompressionException: $message';
}
