// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/camera_provider.dart';
import '../widgets/camera/camera_actions_widget.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CameraProvider(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: null,
        extendBodyBehindAppBar: true,
        body: GestureDetector(
          // Tap anywhere on background to go back
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            // Semi-transparent dark overlay
            color: Colors.black.withOpacity(0.7),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom transparent app bar
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        // Title
                        const Text(
                          'Food Recognition',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Settings button
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                  // Camera actions widget with gesture detection blocker
                  Expanded(
                    child: GestureDetector(
                      // Prevent background tap when tapping on buttons area
                      onTap: () {}, // Empty onTap blocks the parent GestureDetector
                      child: const CameraActionsWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Public method for external capture triggering (for bottom nav integration)
  void capturePhoto() {
    final cameraProvider = context.read<CameraProvider>();
    cameraProvider.captureFromCamera(context);
  }
}