// lib/providers/camera_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/services/photo_compression_service.dart';
import '../data/repositories/food_repository.dart';
import '../widgets/common/food_recognition_loading_dialog.dart';
import '../main.dart'; // Import for navigatorKey
import 'home_provider.dart';

class CameraProvider {
  // Singleton pattern
  static final CameraProvider _instance = CameraProvider._internal();
  factory CameraProvider() => _instance;
  CameraProvider._internal();

  // Core service - isolated business logic
  final PhotoCompressionService _recognitionService = PhotoCompressionService();

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
  /// Uses isolated PhotoCompressionService for core logic
  Future<void> _captureAnalyzeAndSave(
    BuildContext context, {
    required bool isCamera,
  }) async {
    // Track if dialog is shown
    bool dialogShown = false;

    // Callback to show loading overlay
    void showLoadingCallback() {
      try {
        showFoodRecognitionLoading(context);
        dialogShown = true;
      } catch (e) {
        debugPrint('Error showing loading overlay: $e');
      }
    }

    try {
      // Step 1 & 2: Capture image and process (compression + API call)
      final FoodRecognitionResult result = isCamera
          ? await _recognitionService.captureFromCamera(
              onProcessingStart: showLoadingCallback,
            )
          : await _recognitionService.selectFromGallery(
              onProcessingStart: showLoadingCallback,
            );

      // Close loading overlay after processing completes (only if it was shown)
      if (dialogShown) {
        hideFoodRecognitionLoading();
      }

      // Handle cancellation (user closed camera/gallery)
      if (result.isCancelled) {
        return;
      }

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

      // Show loading dialog while saving to database
      if (context.mounted) {
        _showLoadingDialog(context);
      }

      // Step 3: Save to database
      final saveSuccess = await _foodRepository.storageService.saveFoodEntries(result.items!);

      if (!saveSuccess) {
        _hideLoadingDialog(context);
        if (context.mounted) {
          _showErrorAndReturn(context, 'Failed to save food items. Please try again.');
        }
        return;
      }

      // Step 4: Close loading dialog if context is still mounted
      if (context.mounted) {
        _hideLoadingDialog(context);
      }

      // Step 5: Refresh home and show success (using global context)
      _showSuccessAndRefreshHome(result.items!.length);

    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.description}');
      hideFoodRecognitionLoading(); // Hide overlay if shown
      _hideLoadingDialog(context);
      if (context.mounted) {
        _showErrorAndReturn(context, 'Camera error: ${e.description}');
      }
    } catch (e) {
      debugPrint('Error in camera flow: $e');
      hideFoodRecognitionLoading(); // Hide overlay if shown
      _hideLoadingDialog(context);
      if (context.mounted) {
        _showErrorAndReturn(context, 'Error: $e');
      }
    }
  }

  /// Show loading dialog
  void _showLoadingDialog(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Analyzing food...',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  void _hideLoadingDialog(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Refresh home page and show success message (no navigation needed)
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

}