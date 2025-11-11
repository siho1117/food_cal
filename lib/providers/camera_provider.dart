// lib/providers/camera_provider.dart
import 'package:flutter/material.dart';

import '../data/services/photo_compression_service.dart';
import '../data/repositories/food_repository.dart';

class CameraProvider extends ChangeNotifier {
  // Core service - isolated business logic
  final PhotoCompressionService _recognitionService = PhotoCompressionService();

  // Repository for data persistence
  final FoodRepository _foodRepository = FoodRepository();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
    try {
      _setLoading(true);
      _clearError();

      // Step 1 & 2: Use core service to capture + optimize + recognize
      // This handles: camera/gallery → save to gallery → optimize → API call
      final FoodRecognitionResult result = isCamera
          ? await _recognitionService.captureFromCamera()
          : await _recognitionService.selectFromGallery();

      // Handle cancellation (user closed camera/gallery)
      if (result.isCancelled) {
        _setLoading(false);
        return;
      }

      // Handle errors
      if (result.hasError) {
        _setLoading(false);
        if (context.mounted) {
          _showErrorAndReturn(context, result.error ?? 'Unknown error occurred');
        }
        return;
      }

      // Handle success - but check if we got items
      if (!result.isSuccess || result.items == null || result.items!.isEmpty) {
        _setLoading(false);
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

      // Step 4: Close loading and navigate
      _hideLoadingDialog(context);

      if (context.mounted) {
        _navigateToHomeWithSuccess(context, result.items!.length);
      }

    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.description}');
      _hideLoadingDialog(context);
      if (context.mounted) {
        _showErrorAndReturn(context, 'Camera error: ${e.description}');
      }
    } catch (e) {
      debugPrint('Error in camera flow: $e');
      _hideLoadingDialog(context);
      if (context.mounted) {
        _showErrorAndReturn(context, 'Error: $e');
      }
    } finally {
      _setLoading(false);
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
                Text(
                  'Analyzing food...',
                  style: TextStyle(
                    color: const Color(0xFF1A1A1A),
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

  /// Navigate to home page and show success message
  void _navigateToHomeWithSuccess(BuildContext context, int itemCount) {
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