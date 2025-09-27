// lib/providers/camera_provider.dart
// STEP 4: Updated to use GetIt for dependency injection
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// ADD THIS IMPORT for GetIt
import '../config/dependency_injection.dart';

import '../data/repositories/food_repository.dart';

class CameraProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  
  // CHANGE THIS LINE: Get repository from dependency injection
  // OLD: final FoodRepository _foodRepository = FoodRepository();
  // NEW: Get from GetIt container
  final FoodRepository _foodRepository = getIt<FoodRepository>();

  // === EVERYTHING ELSE STAYS THE SAME ===

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Capture photo from camera and auto-save to food log
  Future<void> captureFromCamera(BuildContext context, {VoidCallback? onDismissed}) async {
    await _captureAnalyzeAndSave(ImageSource.camera, context, onDismissed: onDismissed);
  }

  /// Select image from gallery and auto-save to food log
  Future<void> selectFromGallery(BuildContext context, {VoidCallback? onDismissed}) async {
    await _captureAnalyzeAndSave(ImageSource.gallery, context, onDismissed: onDismissed);
  }

  /// Complete flow: capture → analyze → save → navigate home
  Future<void> _captureAnalyzeAndSave(
    ImageSource source, 
    BuildContext context, 
    {VoidCallback? onDismissed}
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // Step 1: Capture image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        // User cancelled
        _setLoading(false);
        return;
      }

      // Step 2: Process image
      final File originalFile = File(pickedFile.path);
      final File optimizedFile = await _resizeAndOptimizeImage(
        originalFile, 
        256, 
        256, 
        45
      );

      // Step 3: Analyze with API
      final recognizedItems = await _foodRepository.recognizeFood(
        optimizedFile,
        _getSuggestedMealType(),
      );

      if (recognizedItems.isEmpty) {
        if (context.mounted) {
          _showErrorAndReturn(context, 'No food items were detected in the image. Please try again.');
        }
        return;
      }

      // Step 4: Auto-save to food log
      final saveSuccess = await _foodRepository.saveFoodEntries(recognizedItems);
      
      if (!saveSuccess) {
        if (context.mounted) {
          _showErrorAndReturn(context, 'Failed to save food items. Please try again.');
        }
        return;
      }

      // Step 5: Navigate to home page and show success
      if (context.mounted) {
        _navigateToHomeWithSuccess(context, recognizedItems.length, onDismissed);
      }

    } catch (e) {
      debugPrint('Error in camera flow: $e');
      if (context.mounted) {
        _showErrorAndReturn(context, 'Error processing image: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Navigate to home page and show success message
  void _navigateToHomeWithSuccess(BuildContext context, int itemCount, VoidCallback? onDismissed) {
    // Call dismissal callback FIRST to update bottom nav immediately
    onDismissed?.call();
    
    // Navigate to home (index 0 in bottom navigation)
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    
    // Show success message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
    _setError(message);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _clearError();
            },
          ),
        ),
      );
    }
  }

  /// Resize and optimize image for better API performance
  /// Optimizes in memory without creating temporary files
  Future<File> _resizeAndOptimizeImage(
    File originalFile, 
    int targetWidth, 
    int targetHeight, 
    int quality
  ) async {
    try {
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.absolute.path,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes != null) {
        // Write compressed bytes back to the original file
        await originalFile.writeAsBytes(compressedBytes);
        return originalFile;
      } else {
        // Fallback to original file if compression fails
        return originalFile;
      }
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Fallback to original file if compression fails
      return originalFile;
    }
  }

  /// Get suggested meal type based on time of day
  String _getSuggestedMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch'; 
    if (hour < 18) return 'snack';
    return 'dinner';
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message and notify listeners
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}