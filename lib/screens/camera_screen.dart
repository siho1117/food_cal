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
          75
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
          75
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
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
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
                  color: AppTheme.primaryBlue,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMealType,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.primaryBlue,
                    ),
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
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _capturedImage = null;
                      });
                      // Launch camera again
                      capturePhoto();
                    },
                    icon: const Icon(Icons.replay, size: 20),
                    label: const Text('Retake'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                    ),
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
      appBar: AppBar(
        title: const Text(
          'FOOD PHOTO',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gallery button - LARGE & TOP
              Container(
                width: double.infinity,
                height: 120,
                margin: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : pickImageFromGallery,
                  icon: const Icon(
                    Icons.photo_library,
                    size: 36,
                  ),
                  label: const Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              // Camera button - LARGE & BOTTOM
              Container(
                width: double.infinity,
                height: 120,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : capturePhoto,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 36,
                        ),
                  label: Text(
                    _isLoading ? 'Loading...' : 'Camera',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}