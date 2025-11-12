// lib/data/services/photo_compression_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../models/food_item.dart';
import '../repositories/food_repository.dart';

/// **PURE API SERVICE - Image Compression & Food Recognition**
///
/// This service is PURELY focused on API operations:
/// 1. Compress & optimize images for API (400x400 @ 55% JPEG - LOCKED SETTINGS)
/// 2. Call food recognition API
/// 3. Return results
///
/// **Design Principles:**
/// - **Pure API Focus**: No UI concerns, no image picker logic
/// - Isolated business logic only
/// - Reusable across different UI implementations
/// - Robust error handling with comprehensive validation
/// - Cost-effective compression (~30KB per image)
///
/// **What this service does NOT do:**
/// - Does NOT handle image picker (that's Provider's job)
/// - Does NOT save to gallery (that's Provider's job)
/// - Does NOT show loading UI (that's Provider's job)
///
/// **Philosophy: Keep API service pure and focused.**
/// **UI orchestration happens in the Provider layer.**
class PhotoCompressionService {
  final FoodRepository _repository = FoodRepository();

  // ═══════════════════════════════════════════════════════════
  // PUBLIC API - Pure API Operations Only
  // ═══════════════════════════════════════════════════════════

  /// **Compress image for API transmission**
  /// Takes any image file and returns optimized version
  /// - JPEG format at 400x400 @ 55% quality (~30KB)
  /// - Handles orientation correction automatically
  Future<File> compressForAPI(File imageFile) async {
    return await _optimizeForAPI(imageFile);
  }

  /// **Process image through food recognition API**
  /// Compresses image and calls API in one operation
  /// This is the main method for the complete API flow
  Future<FoodRecognitionResult> processImage(File imageFile) async {
    try {
      // STEP 1: Optimize for API (Reduce size, maintain quality)
      final File optimizedFile = await _optimizeForAPI(imageFile);

      // STEP 2: Call Food Recognition API
      debugPrint('🔥 Calling food recognition API...');
      final List<FoodItem> recognizedItems = await _repository.recognizeFood(
        optimizedFile,
      );

      // STEP 3: Return Results
      return FoodRecognitionResult.success(recognizedItems);
    } on ImageCompressionException catch (e) {
      return FoodRecognitionResult.error('Image processing error: $e');
    } catch (e) {
      return FoodRecognitionResult.error('Recognition failed: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRIVATE METHODS - Image Optimization
  // ═══════════════════════════════════════════════════════════

  /// Optimize image for API transmission
  /// - JPEG format (universal compatibility across all platforms)
  /// - 400x400 @ 55% quality for optimal API performance (~30KB)
  /// - Handles orientation correction automatically
  /// - OpenAI supports: png, jpeg, gif, webp (we use JPEG for simplicity)
  /// - Aggressive compression to reduce costs at scale
  Future<File> _optimizeForAPI(File originalFile) async {
    // ⚠️ IMPORTANT: Compression settings - DO NOT modify without approval
    // These settings are scientifically tested for optimal cost/quality balance:
    // - Tested: 256x256 @ 55% (too aggressive, 9% higher cost due to reasoning)
    // - Tested: 512x512 @ 60% (25% more expensive, no quality improvement)
    // - OPTIMAL: 400x400 @ 55% (best balance of cost, quality, and stability)
    // Current production: 400x400 @ 55% quality (~30KB per image, ~$0.000479/request)
    const int targetWidth = 400;
    const int targetHeight = 400;
    const int quality = 55;

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

        // Validate the compressed file
        if (!await jpegFile.exists() || await jpegFile.length() == 0) {
          debugPrint('⚠️  Compressed file validation failed, using original');
          return originalFile;
        }

        debugPrint('✅ JPEG compression successful: ${jpegBytes.length} bytes');
        debugPrint('   Reduction: ${((1 - jpegBytes.length / await originalFile.length()) * 100).toStringAsFixed(1)}%');

        return jpegFile;
      } else {
        debugPrint('⚠️  Compression returned null/empty, using original');
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
