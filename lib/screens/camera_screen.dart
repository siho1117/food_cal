// lib/screens/camera_screen.dart - BASIC STANDARD SCREEN
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/repositories/food_repository.dart';
import '../config/design_system/theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final FoodRepository _foodRepository = FoodRepository();
  bool _isProcessing = false;

  // Handle camera capture
  Future<void> _captureFromCamera() async {
    if (_isProcessing) return;
    await _captureImage(ImageSource.camera);
  }

  // Handle gallery selection  
  Future<void> _selectFromGallery() async {
    if (_isProcessing) return;
    await _captureImage(ImageSource.gallery);
  }

  // Core image capture and processing logic
  Future<void> _captureImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Step 2: Process image
      final File imageFile = File(pickedFile.path);
      
      // Step 3: Analyze food
      final recognizedItems = await _foodRepository.recognizeFood(
        imageFile,
        _getSuggestedMealType(),
      );

      if (recognizedItems.isEmpty) {
        if (mounted) {
          _showError('No food detected. Please try again.');
        }
        return;
      }

      // Step 4: Save food items
      final success = await _foodRepository.saveFoodEntries(recognizedItems);
      
      if (!success) {
        if (mounted) {
          _showError('Failed to save food items.');
        }
        return;
      }

      // Step 5: Success - navigate to home
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        _showSuccess(recognizedItems.length);
      }

    } catch (e) {
      if (mounted) {
        _showError('Error processing image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Get meal type based on time
  String _getSuggestedMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 18) return 'snack';
    return 'dinner';
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success message
  void _showSuccess(int itemCount) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              itemCount == 1 
                ? 'Food item added to your log!' 
                : '$itemCount food items added!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      appBar: AppBar(
        title: const Text(
          'Food Recognition',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.secondaryBeige,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlue),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 48,
                      color: AppTheme.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Take a Photo or Select from Gallery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Point your camera at food or select an existing photo to analyze nutrition information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Camera actions
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera button
                    _buildActionButton(
                      icon: Icons.camera_alt,
                      label: _isProcessing ? 'Processing...' : 'Take Photo',
                      color: AppTheme.primaryBlue,
                      textColor: Colors.white,
                      onPressed: _isProcessing ? null : _captureFromCamera,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Gallery button
                    _buildActionButton(
                      icon: Icons.photo_library,
                      label: _isProcessing ? 'Processing...' : 'Choose from Gallery',
                      color: Colors.white,
                      textColor: AppTheme.primaryBlue,
                      onPressed: _isProcessing ? null : _selectFromGallery,
                      isBordered: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
    bool isBordered = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: _isProcessing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, size: 24),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: isBordered ? 0 : 2,
          side: isBordered 
              ? const BorderSide(color: AppTheme.primaryBlue, width: 2)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}