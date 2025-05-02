// lib/widgets/camera/camera_ui.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io'; 
import 'dart:math' as math;
import '../../config/theme.dart';

/// UI elements for the camera screen
class CameraUI {
  /// Builds the bottom control area (semi-transparent black background)
  static Widget buildControlPanel(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.black.withOpacity(0.5),
    );
  }

  /// Builds the camera control buttons (gallery, capture, flash)
  static Widget buildControlButtons({
    required double navBarHeight,
    required Function() onGalleryTap,
    required Function() onFlashTap,
    required IconData flashIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button (left side)
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 26),
            onPressed: onGalleryTap,
            padding: EdgeInsets.zero,
          ),
          
          // Spacer where orange button will be
          const SizedBox(width: 80),
          
          // Flash toggle button (right side)
          IconButton(
            icon: Icon(
              flashIcon,
              color: Colors.white,
              size: 26,
            ),
            onPressed: onFlashTap,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  /// Builds the invisible capture button area
  static Widget buildCaptureButtonArea(Function() onCaptureTap) {
    return GestureDetector(
      onTap: onCaptureTap,
      child: Container(
        width: 75, // Large enough to cover the entire orange button
        height: 100, // Extend up high enough to cover the full button
        color: Colors.transparent, // Completely invisible
      ),
    );
  }

  /// Builds the meal selection bottom sheet
  static void showImageOptionsSheet({
    required BuildContext context,
    required File imageFile,
    required String mealType,
    required Function(String) onMealTypeChanged,
    required Function() onRetake,
    required Function() onAnalyze,
  }) {
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
                  imageFile,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Meal type selector
              DropdownButton<String>(
                value: mealType,
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setModalState(() {
                      onMealTypeChanged(newValue);
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
                      onRetake();
                    },
                    icon: const Icon(Icons.replay, size: 20),
                    label: const Text('Retake'),
                  ),
                  
                  // Analyze button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAnalyze();
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

  /// Helper method to get icon for flash mode
  static IconData getFlashModeIcon(FlashMode mode) {
    switch (mode) {
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
}