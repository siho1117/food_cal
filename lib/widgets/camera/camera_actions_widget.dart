// lib/widgets/camera/camera_actions_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../providers/camera_provider.dart';

class CameraActionsWidget extends StatelessWidget {
  final VoidCallback onDismissed; // Add callback parameter

  const CameraActionsWidget({
    super.key,
    required this.onDismissed, // Make it required
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery button
                Container(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton.icon(
                    onPressed: cameraProvider.isLoading 
                        ? null 
                        : () => cameraProvider.selectFromGallery(
                            context,
                            onDismissed: onDismissed, // Pass callback to provider
                          ),
                    icon: cameraProvider.isLoading
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.photo_library,
                            size: 36,
                          ),
                    label: Text(
                      cameraProvider.isLoading ? 'Processing...' : 'Gallery',
                      style: const TextStyle(
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
                
                // Camera button
                Container(
                  width: double.infinity,
                  height: 120,
                  child: ElevatedButton.icon(
                    onPressed: cameraProvider.isLoading 
                        ? null 
                        : () => cameraProvider.captureFromCamera(
                            context,
                            onDismissed: onDismissed, // Pass callback to provider
                          ),
                    icon: cameraProvider.isLoading 
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 36,
                          ),
                    label: Text(
                      cameraProvider.isLoading ? 'Processing...' : 'Camera',
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
        );
      },
    );
  }
}