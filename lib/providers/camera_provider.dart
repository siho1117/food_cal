// lib/providers/camera_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import '../screens/food_recognition_results_screen.dart';

class CameraProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Capture photo from camera and go directly to analysis
  Future<void> captureFromCamera(BuildContext context) async {
    await _captureAndAnalyze(ImageSource.camera, context);
  }

  /// Select image from gallery and go directly to analysis
  Future<void> selectFromGallery(BuildContext context) async {
    await _captureAndAnalyze(ImageSource.gallery, context);
  }

  /// Internal method to capture image and immediately analyze
  Future<void> _captureAndAnalyze(ImageSource source, BuildContext context) async {
    _setLoading(true);
    _clearError();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        final File originalFile = File(pickedFile.path);
        
        // Process the image (resize and optimize)
        final File optimizedFile = await _resizeAndOptimizeImage(
          originalFile, 
          256, 
          256, 
          45
        );

        // Navigate directly to analysis screen
        _navigateToAnalysis(context, optimizedFile);
      }
    } catch (e) {
      _setError('Error capturing image: $e');
      
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Navigate to food recognition results screen
  void _navigateToAnalysis(BuildContext context, File imageFile) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FoodRecognitionResultsScreen(
            imageFile: imageFile,
            mealType: _getSuggestedMealType(),
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