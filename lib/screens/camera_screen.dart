import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import '../config/theme.dart';
import '../screens/food_recognition_results_screen.dart';
import '../widgets/camera/camera_ui.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  // Camera state
  bool _isLoading = false;
  bool _isInitialized = false;
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  
  // Image state
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'snack'; // Default meal type
  
  // Flash mode state
  FlashMode _currentFlashMode = FlashMode.off;
  
  @override
  void initState() {
    super.initState();
    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    if (_isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (!_isInitialized) return;
    
    // If app is inactive, dispose camera
    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
      _isInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize camera when app is resumed
      _initializeCamera();
    }
  }
  
  // Initialize the camera
  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _isInitialized = false;
    });
    
    try {
      // Request camera permission
      var status = await Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera found')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      // Find the back camera
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      
      // Print the sensor orientation for debugging
      print('Camera sensor orientation: ${backCamera.sensorOrientation}');
      
      // Initialize the camera controller with high resolution
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize the camera
      await _cameraController.initialize();
      
      // Set initial flash mode
      await _cameraController.setFlashMode(FlashMode.off);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
        print('Camera initialized successfully!');
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
        setState(() {
          _isLoading = false;
          _isInitialized = false;
        });
      }
    }
  }
  
  // Handle auto-focus at point
  Future<void> _onFocusPanel(TapUpDetails details) async {
    if (!_isInitialized) return;
    
    try {
      final screenSize = MediaQuery.of(context).size;
      
      final double x = details.localPosition.dx / screenSize.width;
      final double y = details.localPosition.dy / screenSize.height;
      
      await _cameraController.setFocusPoint(Offset(x, y));
      await _cameraController.setExposurePoint(Offset(x, y));
    } catch (e) {
      print('Error setting focus: $e');
    }
  }
  
  // Toggle flash mode
  Future<void> _toggleFlashMode() async {
    if (!_isInitialized) return;
    
    FlashMode newMode;
    
    // Cycle through available flash modes
    switch (_currentFlashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }
    
    try {
      await _cameraController.setFlashMode(newMode);
      setState(() {
        _currentFlashMode = newMode;
      });
    } catch (e) {
      print('Error setting flash mode: $e');
    }
  }
  
  // Capture photo from camera
  Future<void> capturePhoto() async {
    if (!_isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera is not initialized')),
        );
      }
      return;
    }
    
    try {
      // Take the picture
      final XFile image = await _cameraController.takePicture();
      
      // Get the image path
      final String imagePath = image.path;
      
      // Move the image to our app's temp directory to keep it private
      final tempDir = await getTemporaryDirectory();
      final String appImagePath = '${tempDir.path}/food_capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Copy to our app's directory
      final File originalFile = File(imagePath);
      final File copiedFile = await originalFile.copy(appImagePath);
      
      // Delete the original file from camera cache
      await originalFile.delete();
      
      // We'll always use portrait mode (90 degrees) for the captured image
      final int rotation = 90; // Fixed rotation for portrait mode
      
      // Resize and compress the image with rotation correction
      final File optimizedFile = await _resizeAndOptimizeImage(
        copiedFile, 
        256, 
        256, 
        75,
        rotation
      );
      
      if (mounted) {
        setState(() {
          _capturedImage = optimizedFile;
        });
        
        // Show the captured image and options
        _showImageOptions();
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
  
  // Resize and optimize image for network transfer with rotation correction
  Future<File> _resizeAndOptimizeImage(
    File originalFile, 
    int targetWidth, 
    int targetHeight, 
    int quality,
    int rotation
  ) async {
    try {
      final Uint8List originalBytes = await originalFile.readAsBytes();
      
      // Get a temporary file path for the resized image
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Use flutter_image_compress to resize and compress the image
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: targetWidth,
        minHeight: targetHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        rotate: rotation, // Apply portrait mode rotation
      );
      
      if (compressedBytes == null) {
        // If compression fails, return the original file
        return originalFile;
      }
      
      // Write the compressed bytes to a new file
      final File compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      // Delete the original file to save space
      await originalFile.delete();
      
      print('Image optimized: original size: ${originalBytes.length} bytes, new size: ${compressedBytes.length} bytes');
      return compressedFile;
    } catch (e) {
      print('Error optimizing image: $e');
      // If any error occurs, return the original file
      return originalFile;
    }
  }
  
  // Select image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75, // Use moderate quality
      );
      
      if (image != null) {
        // Optimize the gallery image
        final File originalFile = File(image.path);
        
        // Create a temp directory path for copying the image into app's space
        final tempDir = await getTemporaryDirectory();
        final String tempPath = '${tempDir.path}/gallery_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Copy the image to our temp directory to avoid modifying original gallery image
        final File copiedFile = await originalFile.copy(tempPath);
        
        // For gallery images, we don't need to rotate since they already have orientation metadata
        final File optimizedFile = await _resizeAndOptimizeImage(
          copiedFile, 
          256, 
          256, 
          75,
          0 // No rotation for gallery images
        );
        
        if (mounted) {
          setState(() {
            _capturedImage = optimizedFile;
          });
          
          // Show the captured image and options
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
  
  // Show options for the captured image using the UI helper
  void _showImageOptions() {
    if (_capturedImage == null || !mounted) return;
    
    CameraUI.showImageOptionsSheet(
      context: context,
      imageFile: _capturedImage!,
      mealType: _selectedMealType,
      onMealTypeChanged: (newValue) {
        setState(() {
          _selectedMealType = newValue;
        });
      },
      onRetake: () {
        setState(() {
          _capturedImage = null;
        });
      },
      onAnalyze: () {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for positioning UI elements
    final screenHeight = MediaQuery.of(context).size.height;
    final navBarHeight = 75.0; // Height of your CurvedNavigationBar
    
    // Calculate bottom control panel height
    final controlPanelHeight = screenHeight * 0.14;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or loading indicator
          if (_isInitialized) 
            _buildCameraPreview()
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          
          // Semi-transparent black background for camera controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: controlPanelHeight,
            child: CameraUI.buildControlPanel(controlPanelHeight),
          ),
          
          // Camera control buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: navBarHeight * 0.9, // Position just above the navigation bar
            child: CameraUI.buildControlButtons(
              navBarHeight: navBarHeight,
              onGalleryTap: pickImageFromGallery,
              onFlashTap: _toggleFlashMode,
              flashIcon: CameraUI.getFlashModeIcon(_currentFlashMode),
            ),
          ),
          
          // Invisible touch detector over the orange button area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: CameraUI.buildCaptureButtonArea(capturePhoto),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );
  }
  
  // Build camera preview with simplified orientation handling
  Widget _buildCameraPreview() {
    if (!_cameraController.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Camera initializing...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Get screen size
    final size = MediaQuery.of(context).size;
    // Get the camera preview size
    final previewSize = _cameraController.value.previewSize!;
    
    // Calculate the preview aspect ratio (always in portrait mode)
    final previewAspectRatio = previewSize.height / previewSize.width;
    
    // Calculate scale to fill screen
    final screenAspectRatio = size.width / size.height;
    final scale = screenAspectRatio < previewAspectRatio
        ? size.height / size.width * previewAspectRatio
        : size.width / size.height / previewAspectRatio;
    
    return GestureDetector(
      onTapUp: _onFocusPanel,
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: AspectRatio(
            aspectRatio: 1 / previewAspectRatio,
            child: CameraPreview(_cameraController),
          ),
        ),
      ),
    );
  }
}