// lib/data/services/photo_compression_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../models/food_item.dart';
import '../repositories/food_repository.dart';
import '../../config/constants/app_constants.dart';
import '../exceptions/api_exceptions.dart';
/// **PURE API SERVICE - Image Compression & Food Recognition**
///
/// This service is PURELY focused on API operations:
/// 1. Compress & optimize images for API (settings from AppConstants)
/// 2. Call food recognition API
/// 3. Return results
///
/// **Design Principles:**
/// - **Pure API Focus**: No UI concerns, no image picker logic
/// - Isolated business logic only
/// - Reusable across different UI implementations
/// - Robust error handling with comprehensive validation
/// - Cost-effective compression (~20KB per image @ 300x300)
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
  /// - Settings defined in AppConstants (single source of truth)
  /// - GUARANTEED exact dimensions using image package
  /// - OpenAI/Gemini supports: png, jpeg, gif, webp (we use JPEG for simplicity)
  /// - Aggressive compression to reduce costs at scale
  Future<File> _optimizeForAPI(File originalFile) async {
    // ⚠️ IMPORTANT: Settings imported from AppConstants - DO NOT override here
    // All image optimization settings are defined in app_constants.dart
    // Current production: 300x300 @ 50% = ~700-800 tokens (~$0.00040/request)
    const int targetWidth = AppConstants.targetImageWidth;
    const int targetHeight = AppConstants.targetImageHeight;
    const int quality = AppConstants.imageCompressionQuality;

    debugPrint('🔄 Optimizing image for API...');
    debugPrint('   Original size: ${await originalFile.length()} bytes');
    debugPrint('   Target: ${targetWidth}x$targetHeight @ $quality% quality');

    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/api_optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Read original image bytes
      final originalBytes = await originalFile.readAsBytes();

      // Decode image using image package
      img.Image? image = img.decodeImage(originalBytes);

      if (image == null) {
        debugPrint('❌ Failed to decode image, using original');
        return originalFile;
      }

      debugPrint('   Original dimensions: ${image.width}x${image.height}');

      // CRITICAL: Resize to exact target dimensions (not maintaining aspect ratio)
      // This ensures consistent token usage regardless of input image
      final img.Image resized = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.average, // Good balance of quality/speed
      );

      debugPrint('   Resized dimensions: ${resized.width}x${resized.height}');

      // Encode as JPEG with specified quality
      final List<int> jpegBytes = img.encodeJpg(resized, quality: quality);

      // Write to file
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(jpegBytes);

      final compressedSize = jpegBytes.length;
      debugPrint('✅ Compression successful: $compressedSize bytes');
      debugPrint('   Reduction: ${((1 - compressedSize / await originalFile.length()) * 100).toStringAsFixed(1)}%');

      // ⚠️ DIAGNOSTIC: Verify compression meets production targets
      if (compressedSize > 30000) { // 30KB threshold
        debugPrint('⚠️  WARNING: Compressed file larger than expected (>30KB)');
        debugPrint('   Expected ~15-20KB, got ${(compressedSize/1024).toStringAsFixed(1)}KB');
      } else {
        debugPrint('✅ Production compression successful - token usage ~700-800');
      }

      return compressedFile;
    } catch (e) {
      debugPrint('❌ Compression failed: $e');
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
