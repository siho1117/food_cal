// lib/providers/camera_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';

import '../data/services/photo_compression_service.dart';
import '../data/repositories/food_repository.dart';
import '../data/exceptions/api_exceptions.dart';
import '../widgets/loading/food_recognition_loading_dialog.dart';
import '../main.dart'; // Import for navigatorKey
import '../services/food_image_service.dart';
import 'home_provider.dart';
import 'navigation_provider.dart';

/// **Camera Provider - UI Orchestration Layer**
///
/// Responsibilities:
/// - Handle image picker (camera/gallery)
/// - Save images to gallery (camera only)
/// - Coordinate loading states
/// - Call pure API service
/// - Handle results and update UI
///
/// This is the UI orchestration layer that coordinates:
/// User Interaction → Loading States → API Service → Results Handling
class CameraProvider {
  // Singleton pattern
  static final CameraProvider _instance = CameraProvider._internal();
  factory CameraProvider() => _instance;
  CameraProvider._internal();

  // Image picker for camera/gallery
  final ImagePicker _picker = ImagePicker();

  // Pure API service - NO UI concerns
  final PhotoCompressionService _apiService = PhotoCompressionService();

  // Repository for data persistence
  final FoodRepository _foodRepository = FoodRepository();

  /// Capture photo from camera and auto-save to food log
  Future<void> captureFromCamera(BuildContext context) async {
    await _captureAnalyzeAndSave(context, isCamera: true);
  }

  /// Select image from gallery and auto-save to food log
  Future<void> selectFromGallery(BuildContext context) async {
    await _captureAnalyzeAndSave(context, isCamera: false);
  }

  /// Complete flow: capture → analyze → save → navigate home
  /// Handles UI loading states and orchestrates API service
  Future<void> _captureAnalyzeAndSave(
    BuildContext context, {
    required bool isCamera,
  }) async {
    File? imageFile;
    FoodRecognitionResult? result;

    // Get user's language from locale BEFORE any async operations
    final locale = Localizations.localeOf(context);
    final language = _getLanguageName(locale);
    debugPrint('📍 Using language for food recognition: $language (${locale.toString()})');

    try {
      // ═══════════════════════════════════════════════════════════
      // STEP 1: Pick Image - NO LOADING (let user select)
      // ═══════════════════════════════════════════════════════════
      final XFile? pickedFile = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
      );

      // User cancelled? Exit early
      if (pickedFile == null) {
        debugPrint('ℹ️ User cancelled image selection');
        return;
      }

      imageFile = File(pickedFile.path);

      // Validate file exists
      if (!await imageFile.exists()) {
        debugPrint('❌ Image file does not exist');
        if (context.mounted) {
          _showErrorAndReturn(context, 'Selected image file not found');
        }
        return;
      }

      // ═══════════════════════════════════════════════════════════
      // STEP 2: Save to Gallery (camera only)
      // ═══════════════════════════════════════════════════════════
      if (isCamera) {
        final saved = await _saveToGallery(imageFile);
        if (!saved) {
          debugPrint('⚠️ Failed to save to gallery, continuing anyway...');
        }
      }

      // ═══════════════════════════════════════════════════════════
      // STEP 3: Save Good Quality Copy for Food Card (BEFORE compression)
      // ═══════════════════════════════════════════════════════════
      String? foodCardImagePath;
      try {
        foodCardImagePath = await FoodImageService.saveImageFromFile(imageFile);
        debugPrint('✅ Saved food card image: $foodCardImagePath');
      } catch (e) {
        debugPrint('⚠️ Failed to save food card image: $e (continuing anyway)');
      }

      // ═══════════════════════════════════════════════════════════
      // STEP 4: NOW Show Loading (user has selected, processing starts)
      // ═══════════════════════════════════════════════════════════
      showFoodRecognitionLoading(null, imagePath: foodCardImagePath);

      // ═══════════════════════════════════════════════════════════
      // STEP 5: Call Pure API Service (compression + API)
      // ═══════════════════════════════════════════════════════════
      result = await _apiService.processImage(imageFile, language: language);

      // ═══════════════════════════════════════════════════════════
      // STEP 6: Hide Loading
      // ═══════════════════════════════════════════════════════════
      hideFoodRecognitionLoading();

      // Handle errors
      if (result.hasError) {
        if (context.mounted) {
          _showErrorAndReturn(context, result.error ?? 'Unknown error occurred');
        }
        return;
      }

      // Handle success - but check if we got items
      if (!result.isSuccess || result.items == null || result.items!.isEmpty) {
        if (context.mounted) {
          _showErrorAndReturn(context, 'No food items were detected in the image. Please try again.');
        }
        return;
      }

      // ═══════════════════════════════════════════════════════════
      // STEP 6: Attach Food Card Image to All Detected Items
      // ═══════════════════════════════════════════════════════════
      final itemsWithImages = result.items!.map((item) {
        return item.copyWith(imagePath: foodCardImagePath);
      }).toList();

      // ═══════════════════════════════════════════════════════════
      // STEP 6.5: Show Preview for 8 seconds (before saving)
      // Preview may be updated with cost if user adds it
      // ═══════════════════════════════════════════════════════════
      final firstItem = itemsWithImages.first;
      final updatedItem = await showFoodRecognitionPreview(
        foodItem: firstItem,
        imagePath: foodCardImagePath ?? '',
      );

      // Update the items list with the potentially updated item (with cost)
      final finalItemsToSave = itemsWithImages.map((item) {
        // Replace first item with updated one if cost was added
        if (item.id == firstItem.id) {
          return updatedItem;
        }
        return item;
      }).toList();

      // ═══════════════════════════════════════════════════════════
      // STEP 7: Save to Database (fast operation, no loading dialog needed)
      // ═══════════════════════════════════════════════════════════
      final saveSuccess = await _foodRepository.storageService.saveFoodEntries(finalItemsToSave);

      if (!saveSuccess) {
        if (context.mounted) {
          _showErrorAndReturn(context, 'Failed to save food items. Please try again.');
        }
        return;
      }

      // Step 4: Refresh home and show success (using global context)
      _showSuccessAndRefreshHome(result.items!.length);

    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.description}');
      hideFoodRecognitionLoading(); // Hide overlay if shown
      if (context.mounted) {
        _showErrorAndReturn(context, 'Camera error: ${e.description}');
      }
    } catch (e) {
      debugPrint('Error in camera flow: $e');
      hideFoodRecognitionLoading(); // Hide overlay if shown
      if (context.mounted) {
        _showErrorAndReturn(context, 'Error: $e');
      }
    }
  }

  /// Refresh home page, navigate to home, and show success message
  void _showSuccessAndRefreshHome(int itemCount) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final globalContext = navigatorKey.currentContext;

      if (globalContext == null) {
        debugPrint('Warning: Global context unavailable for refresh');
        return;
      }

      // Refresh HomeProvider to show latest data
      try {
        final homeProvider = Provider.of<HomeProvider>(globalContext, listen: false);
        await homeProvider.refreshData();
      } catch (e) {
        debugPrint('Error refreshing HomeProvider: $e');
      }

      // Navigate to Home page
      if (globalContext.mounted) {
        try {
          final navigationProvider = Provider.of<NavigationProvider>(globalContext, listen: false);
          navigationProvider.navigateToHome();
        } catch (e) {
          debugPrint('Error navigating to Home: $e');
        }
      }

      // Show success message
      if (globalContext.mounted) {
        ScaffoldMessenger.of(globalContext).showSnackBar(
          SnackBar(
            content: Text(
              itemCount == 1
                ? 'Food item added to your log!'
                : '$itemCount food items added to your log!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Optional: scroll to today's food log section
              },
            ),
          ),
        );
      }
    });
  }

  /// Show error message and stay on camera page
  void _showErrorAndReturn(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Save image to device gallery (camera only)
  /// Moved from service to provider for clean separation
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

  /// Convert locale to full language name for API
  /// Handles both language code and region variants (e.g., zh_CN vs zh_TW)
  String _getLanguageName(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    final countryCode = locale.countryCode?.toLowerCase();

    // Handle Chinese variants based on country/region
    if (languageCode == 'zh') {
      if (countryCode == 'tw' || countryCode == 'hk' || countryCode == 'mo') {
        return 'Traditional Chinese';  // Taiwan, Hong Kong, Macau
      } else {
        return 'Simplified Chinese';  // Default to Simplified for mainland China
      }
    }

    // Handle other languages
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'it':
        return 'Italian';
      case 'pt':
        return 'Portuguese';
      case 'ru':
        return 'Russian';
      case 'ar':
        return 'Arabic';
      case 'hi':
        return 'Hindi';
      case 'th':
        return 'Thai';
      case 'vi':
        return 'Vietnamese';
      default:
        return 'English'; // Default fallback
    }
  }

}