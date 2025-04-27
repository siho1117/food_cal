import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../data/services/fallback_provider.dart';
import '../screens/food_recognition_results_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'snack'; // Default meal type
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  @override
  void dispose() {
    if (_isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }
  
  // Initialize the camera
  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Request camera permission
      var status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Initialize the camera controller with the first (back) camera
      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      // Initialize and check for errors
      await _cameraController.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Capture photo from camera
  Future<void> capturePhoto() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is not initialized')),
      );
      return;
    }
    
    try {
      // Take the picture
      final XFile image = await _cameraController.takePicture();
      
      // Convert to File
      final File imageFile = File(image.path);
      
      setState(() {
        _capturedImage = imageFile;
      });
      
      // Show the captured image and options
      _showImageOptions();
    } catch (e) {
      print('Error capturing photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing photo: $e')),
      );
    }
  }
  
  // Select image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        
        // Show the captured image and options
        _showImageOptions();
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  // Show options for the captured image
  void _showImageOptions() {
    if (_capturedImage == null) return;
    
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
                      _selectedMealType = newValue;
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
                      // Navigate to food recognition results screen
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
  
  // Test VM connection (keeping this for now)
  void testVMConnection() async {
    setState(() {
      _isLoading = true;
    });
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Testing VM connection...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    final provider = FallbackProvider();
    
    try {
      // Test the connection
      final result = await provider.testConnection();
      
      // Show success message with the response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection successful!\nResponse: ${result.toString().substring(0, min(100, result.toString().length))}...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      
      print('Full response: $result');
      
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper function for string truncation
  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: Stack(
        children: [
          // Camera preview or placeholder
          _isInitialized
              ? Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                )
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'Camera initializing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
          
          // Loading indicator
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          
          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 100, // Above the bottom nav bar
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: Colors.black45,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                    onPressed: pickImageFromGallery,
                  ),
                  
                  // Capture button
                  GestureDetector(
                    onTap: capturePhoto,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  
                  // VM Test button (keeping for now)
                  IconButton(
                    icon: const Icon(Icons.cloud_sync, color: Colors.white, size: 30),
                    onPressed: testVMConnection,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}