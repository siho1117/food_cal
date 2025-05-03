import 'dart:io';
import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isInitialized) return;
    
    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
      _isInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _isInitialized = false;
    });
    
    try {
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
      
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController.initialize();
      await _cameraController.setFlashMode(FlashMode.off);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
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
  
  Future<void> _toggleFlashMode() async {
    if (!_isInitialized) return;
    
    FlashMode newMode;
    
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
      final XFile image = await _cameraController.takePicture();
      final String imagePath = image.path;
      
      final tempDir = await getTemporaryDirectory();
      final String appImagePath = '${tempDir.path}/food_capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final File originalFile = File(imagePath);
      final File copiedFile = await originalFile.copy(appImagePath);
      
      await originalFile.delete();
      
      final File optimizedFile = await _resizeAndOptimizeImage(
        copiedFile, 
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
      
      await originalFile.delete();
      
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
        
        final tempDir = await getTemporaryDirectory();
        final String tempPath = '${tempDir.path}/gallery_temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        final File copiedFile = await originalFile.copy(tempPath);
        
        final File optimizedFile = await _resizeAndOptimizeImage(
          copiedFile, 
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
    final screenHeight = MediaQuery.of(context).size.height;
    final navBarHeight = 75.0;
    final controlPanelHeight = screenHeight * 0.14;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isInitialized) 
            Container(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController.value.previewSize!.height,
                  height: _cameraController.value.previewSize!.width,
                  child: GestureDetector(
                    onTapUp: _onFocusPanel,
                    child: CameraPreview(_cameraController),
                  ),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: controlPanelHeight,
            child: CameraUI.buildControlPanel(controlPanelHeight),
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: navBarHeight * 0.9,
            child: CameraUI.buildControlButtons(
              navBarHeight: navBarHeight,
              onGalleryTap: pickImageFromGallery,
              onFlashTap: _toggleFlashMode,
              flashIcon: CameraUI.getFlashModeIcon(_currentFlashMode),
            ),
          ),
          
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
}