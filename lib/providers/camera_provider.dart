// lib/providers/camera_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import '../data/repositories/food_repository.dart';

class CameraProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final FoodRepository _foodRepository = FoodRepository();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Capture photo from camera and auto-save to food log
  Future<void> captureFromCamera(BuildContext context) async {
    await _captureAnalyzeAndSave(ImageSource.camera, context);
  }

  /// Select image from gallery and auto-save to food log
  Future<void> selectFromGallery(BuildContext context) async {
    await _captureAnalyzeAndSave(ImageSource.gallery, context);
  }

  /// Complete flow: capture → analyze → save → navigate home
  Future<void> _captureAnalyzeAndSave(ImageSource source, BuildContext context) async {
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
        _showErrorAndReturn(context, 'No food items were detected in the image. Please try again.');
        return;
      }

      // Step 4: Auto-save to food log
      final saveSuccess = await _foodRepository.saveFoodEntries(recognizedItems);
      
      if (!saveSuccess) {
        _showErrorAndReturn(context, 'Failed to save food items. Please try again.');
        return;
      }

      // Step 5: Navigate to home page and show success
      if (context.mounted) {
        _navigateToHomeWithSuccess(context, recognizedItems.length);
      }

    } catch (e) {
      print('Error in camera flow: $e');
      _showErrorAndReturn(context, 'Error processing image: $e');
    } finally {
      _setLoading(false);
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

  /// Resize and optimize image for better API performance
  Future<File> _resizeAndOptimizeImage(
    File originalFile, 
    int targetWidth, 
    int targetHeight, 
    int quality
  ) async {
    try {
      final Uint8List originalBytes = await originalFile.readAsBytes();
      
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      
      if (compressedBytes == null) {
        return originalFile;
      }
      
      final File compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      print('Error optimizing image: $e');
      return originalFile;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get appropriate meal type based on current time
  String _getSuggestedMealType() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'lunch';
    } else if (hour >= 16 && hour < 21) {
      return 'dinner';
    } else {
      return 'snack';
    }
  }
}