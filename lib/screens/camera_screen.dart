// lib/screens/camera_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import '../config/theme.dart';
import '../screens/food_recognition_results_screen.dart';

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
  
  Future<void> capturePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (pickedFile != null) {
        final File originalFile = File(pickedFile.path);
        
        // Process the image (resize/optimize)
        final File optimizedFile = await _resizeAndOptimizeImage(
          originalFile, 
          256, 
          256, 
          75
        );
        
        if (mounted) {
          setState(() {
            _capturedImage = optimizedFile;
          });
          
          _showImageOptions();
        }
      }
    } catch (e) {
      print('Error capturing photo: $e');
      if (mounted) {
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
  
  Future<void> pickImageFromGallery() async {
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
          75
        );
        
        if (mounted) {
          setState(() {
            _capturedImage = optimizedFile;
          });
          
          _showImageOptions();
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
  
  void _showImageOptions() {
    if (_capturedImage == null || !mounted) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Food Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _capturedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Meal type selector
              DropdownButton<String>(
                value: _selectedMealType,
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setModalState(() {
                      setState(() {
                        _selectedMealType = newValue;
                      });
                    });
                  }
                },
                items: ['breakfast', 'lunch', 'dinner', 'snack'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.substring(0, 1).toUpperCase() + value.substring(1),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _capturedImage = null;
                      });
                    },
                    icon: const Icon(Icons.replay, size: 20),
                    label: const Text('Retake'),
                  ),
                  
                  // Analyze button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FoodRecognitionResultsScreen(
                            imageFile: _capturedImage!,
                            mealType: _selectedMealType,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Analyze Food'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'FOOD PHOTO',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Take a photo of your food to analyze its nutritional content',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Image preview area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _capturedImage != null
                        ? Image.file(
                            _capturedImage!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No photo yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap the camera button to take a photo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),
                
                // Button area
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      ElevatedButton.icon(
                        onPressed: pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 3,
                        ),
                      ),
                      
                      // Camera button
                      ElevatedButton.icon(
                        onPressed: capturePhoto,
                        icon: const Icon(Icons.camera_alt, size: 24),
                        label: const Text('Take Photo', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // If the image was just captured, show a quick tip
            if (_capturedImage != null)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Tap "Analyze Food" to continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}