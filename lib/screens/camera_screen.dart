// lib/screens/camera_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import '../config/theme.dart';
import '../screens/food_recognition_results_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/camera/camera_ui.dart'; // Import camera UI components

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  // Image state
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'snack'; // Default meal type
  bool _isLoading = false;
  
  Future<void> capturePhoto() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use ImagePicker to launch the native camera
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (pickedFile != null) {
        final File originalFile = File(pickedFile.path);
        
        // Process the image
        final File optimizedFile = await _resizeAndOptimizeImage(
          originalFile, 
          256, 
          256, 
          45
        );
        
        if (mounted) {
          setState(() {
            _capturedImage = optimizedFile;
            _isLoading = false;
          });
          
          _showImageOptions();
        }
      } else {
        // User cancelled taking a picture
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error capturing photo: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: $e')),
        );
      }
    }
  }
  
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
        quality: 45, // Using 45% quality for better compression
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
  
  Future<void> pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      
      if (image != null) {
        final File originalFile = File(image.path);
        
        final File optimizedFile = await _resizeAndOptimizeImage(
          originalFile, 
          256, 
          256, 
          45
        );
        
        if (mounted) {
          setState(() {
            _capturedImage = optimizedFile;
            _isLoading = false;
          });
          
          _showImageOptions();
        }
      } else {
        // User cancelled picking an image
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
  
  void _showImageOptions() {
    if (_capturedImage == null || !mounted) return;
    
    CameraUI.showImageOptionsSheet(
      context: context,
      imageFile: _capturedImage!,
      mealType: _selectedMealType,
      onMealTypeChanged: (String newValue) {
        setState(() {
          _selectedMealType = newValue;
        });
      },
      onRetake: () {
        setState(() {
          _capturedImage = null;
        });
        capturePhoto();
      },
      onAnalyze: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FoodRecognitionResultsScreen(
              imageFile: _capturedImage!,
              mealType: _selectedMealType,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      // Add CustomAppBar component
      appBar: CustomAppBar(
        onSettingsTap: () {
          // Navigate to settings screen
          Navigator.of(context).pushNamed('/settings');
        },
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gallery button from CameraUI
              CameraUI.buildGalleryButton(
                onPressed: _isLoading ? null : pickImageFromGallery,
                isLoading: _isLoading,
              ),
              
              // Camera button from CameraUI
              CameraUI.buildCameraButton(
                onPressed: _isLoading ? null : capturePhoto,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}