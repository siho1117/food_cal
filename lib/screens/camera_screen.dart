// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/camera_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/camera/camera_actions_widget.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    // Keep the CameraProvider for state management
    return ChangeNotifierProvider(
      create: (_) => CameraProvider(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        appBar: CustomAppBar(
          onSettingsTap: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        // No Consumer needed here since CameraActionsWidget will consume the provider
        body: const CameraActionsWidget(),
      ),
    );
  }

  /// Public method for external capture triggering (for bottom nav integration)
  void capturePhoto() {
    final cameraProvider = context.read<CameraProvider>();
    cameraProvider.captureFromCamera(context);
  }
}