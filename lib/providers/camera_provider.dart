// lib/providers/camera_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import '../data/repositories/food_repository.dart';
import '../screens/food_recognition_results_screen.dart';

class CameraProvider extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  final ImagePicker _picker = ImagePicker();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Image state
  File? _capturedImage;
  File? get capturedImage => _capturedImage;

  // Meal type selection
  String _selectedMealType = 'snack';
  String get selectedMealType => _selectedMealType;

  // Available meal types
  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
  List<String> get mealTypes => _mealTypes;

  /// Set the selected meal type
  void setMealType(String mealType) {
    if (_mealTypes.contains(mealType)) {
      _selectedMealType = mealType;
      notifyListeners();
    }
  }

  /// Capture photo from camera
  Future<void> captureFromCamera() async {
    await _captureImage(ImageSource.camera);
  }

  /// Select image from gallery
  Future<void> selectFromGallery() async {
    await _captureImage(ImageSource.gallery);
  }

  /// Internal method to handle image capture/selection
  Future<void> _captureImage(ImageSource source) async {
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

        _capturedImage = optimizedFile;
        _setLoading(false);
      } else {
        // User cancelled
        _setLoading(false);
      }
    } catch (e) {
      _setError('Error capturing image: $e');
      _setLoading(false);
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

  /// Analyze the captured image using the food repository
  Future<void> analyzeImage(BuildContext context) async {
    if (_capturedImage == null) {
      _setError('No image to analyze');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Navigate to recognition results screen
      // The existing FoodRecognitionResultsScreen will handle the API call
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FoodRecognitionResultsScreen(
            imageFile: _capturedImage!,
            mealType: _selectedMealType,
          ),
        ),
      ).then((_) {
        // Clear the current image when returning from results
        clearCurrentImage();
      });

      _setLoading(false);
    } catch (e) {
      _setError('Error analyzing image: $e');
      _setLoading(false);
    }
  }

  /// Clear the current captured image
  void clearCurrentImage() {
    _capturedImage = null;
    _clearError();
    notifyListeners();
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

  /// Refresh/reset the provider state
  void refreshData() {
    clearCurrentImage();
    _clearError();
    _setLoading(false);
  }

  /// Get formatted meal type for display
  String getFormattedMealType(String mealType) {
    if (mealType.isEmpty) return 'Snack';
    return mealType.substring(0, 1).toUpperCase() + 
           mealType.substring(1).toLowerCase();
  }

  /// Check if there's a captured image ready for analysis
  bool get hasImageToAnalyze => _capturedImage != null && !_isLoading;

  /// Get appropriate meal type based on current time
  String getSuggestedMealType() {
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

  /// Auto-set meal type based on current time (useful for initialization)
  void setSuggestedMealType() {
    setMealType(getSuggestedMealType());
  }
}