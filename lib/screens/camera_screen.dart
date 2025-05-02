import 'dart:io';
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

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isInitialized = false;
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();
  String _selectedMealType = 'snack'; // Default meal type
  
  // Focus indicator state
  Offset? _focusPoint;
  bool _showFocusCircle = false;
  
  // Zoom control state
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;
  
  // Flash control state
  FlashMode _currentFlashMode = FlashMode.off;
  
  @override
  void initState() {
    super.initState();
    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // Lock orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeCamera();
  }
  
  @override
  void dispose() {
    // Remove observer when disposing
    WidgetsBinding.instance.removeObserver(this);
    // Release orientation lock when leaving camera screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
      
      // Find the back camera
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      
      // Initialize the camera controller with medium resolution
      // Using medium instead of high since we'll resize anyway to save bandwidth
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Initialize and check for errors
      await _cameraController.initialize();
      
      // Lock the camera orientation to portrait
      // This helps ensure consistent camera preview in portrait mode
      await _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      
      // Get available zoom range
      await _getZoomLevel();
      
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
  
  // Get available zoom level from camera
  Future<void> _getZoomLevel() async {
    try {
      _minAvailableZoom = await _cameraController.getMinZoomLevel();
      _maxAvailableZoom = await _cameraController.getMaxZoomLevel();
      setState(() {});
    } catch (e) {
      print('Error getting zoom level: $e');
    }
  }
  
  // Handle focus at point
  Future<void> _onFocusPanel(TapUpDetails details) async {
    if (!_isInitialized) return;
    
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate focus point
    final offset = details.localPosition;
    final double x = offset.dx / screenSize.width;
    final double y = offset.dy / screenSize.height;
    
    // Show focus indicator
    setState(() {
      _focusPoint = offset;
      _showFocusCircle = true;
    });
    
    // Set focus and metering points on camera
    try {
      await _cameraController.setFocusPoint(Offset(x, y));
      await _cameraController.setExposurePoint(Offset(x, y));
      
      // Hide focus indicator after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _showFocusCircle = false;
        });
      }
    } catch (e) {
      print('Error setting focus: $e');
    }
  }
  
  // Handle zoom functionality
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!_isInitialized) return;
    
    // Calculate new zoom level
    double newZoomLevel = (_currentZoomLevel * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    
    // Only update if there's a significant change
    if ((newZoomLevel - _currentZoomLevel).abs() > 0.01) {
      setState(() {
        _currentZoomLevel = newZoomLevel;
      });
      
      // Set zoom level on camera
      _cameraController.setZoomLevel(newZoomLevel);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is not initialized')),
      );
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
      
      // Resize and compress the image to 256x256 with a moderate JPEG quality
      final File optimizedFile = await _resizeAndOptimizeImage(copiedFile, 256, 256, 75);
      
      setState(() {
        _capturedImage = optimizedFile;
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
  
  // Resize and optimize image for network transfer
  Future<File> _resizeAndOptimizeImage(File originalFile, int targetWidth, int targetHeight, int quality) async {
    try {
      // Import the image_processing package functions
      // Note: We're using the flutter_image_compress package in this case
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
        
        // Resize and optimize the copied image
        final File optimizedFile = await _resizeAndOptimizeImage(copiedFile, 256, 256, 75);
        
        setState(() {
          _capturedImage = optimizedFile;
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
  
  // Build focus indicator widget
  Widget _buildFocusCircle() {
    if (!_showFocusCircle || _focusPoint == null) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      left: _focusPoint!.dx - 24,
      top: _focusPoint!.dy - 24,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryBlue, width: 2),
          color: Colors.transparent,
        ),
        child: const Center(
          child: AnimatedOpacity(
            opacity: 0.7,
            duration: Duration(milliseconds: 300),
            child: Icon(
              Icons.circle,
              size: 12,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
  
  // Get flash mode icon
  IconData _getFlashModeIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }
  
  // Build the camera preview with proper aspect ratio
  Widget _buildCameraPreview() {
    if (!_isInitialized) {
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
    
    // Use a simpler approach that's known to work reliably
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: GestureDetector(
        onTapUp: _onFocusPanel,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview that fills the available space
            CameraPreview(_cameraController),
            
            // Transparent overlay for handling scale gestures
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (_) {},
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: (_) {},
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for precise positioning
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 75.0; // Height of your CurvedNavigationBar
    
    // Calculate bottom control panel height (approximately 20% of screen)
    final controlPanelHeight = screenHeight * 0.14;
    
    return Scaffold(
      backgroundColor: Colors.black,
      // Use a full-screen body without the camera button
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              // Camera preview with focus and zoom
              if (_isInitialized) 
                _buildCameraPreview(),
              
              // Zoom level indicator (only show when zooming)
              if (_isInitialized && _currentZoomLevel > 1.0)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              
              // Focus circle
              if (_isInitialized)
                _buildFocusCircle(),
              
              // Loading indicator
              if (_isLoading || !_isInitialized)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              
              // Semi-transparent black background for camera controls (20% of screen)
              // You can adjust the opacity here (0.7 is darker, 0.3 is lighter)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: controlPanelHeight,
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Change this value to adjust darkness
                ),
              ),
              
              // Camera controls - now only include gallery and flash buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: navBarHeight * 0.9, // Position just above the navigation bar
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.transparent, // Transparent background
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button (left side) - removed black circle background
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 26),
                        onPressed: pickImageFromGallery,
                        padding: EdgeInsets.zero,
                      ),
                      
                      // Spacer where orange button will be
                      const SizedBox(width: 80),
                      
                      // Flash toggle button (right side) - removed black circle background
                      IconButton(
                        icon: Icon(
                          _getFlashModeIcon(),
                          color: Colors.white,
                          size: 26,
                        ),
                        onPressed: _toggleFlashMode,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Invisible touch detector over the orange button area
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: capturePhoto,
                    child: Container(
                      width: 75, // Large enough to cover the entire orange button
                      height: 100, // Extend up high enough to cover the full button
                      color: Colors.transparent, // Completely invisible
                    ),
                  ),
                ),
              ),

              // Orientation warning - show only in landscape
              if (orientation == Orientation.landscape)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.screen_rotation,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Please rotate your device to portrait mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
    );
  }
}