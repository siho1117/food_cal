// lib/screens/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/camera_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/camera/camera_actions_widget.dart';
import '../widgets/camera/meal_type_selector_widget.dart';
import '../widgets/camera/image_preview_bottom_sheet.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    // Provide the CameraProvider to the widget tree
    return ChangeNotifierProvider(
      create: (_) => CameraProvider()..setSuggestedMealType(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        // Add CustomAppBar component
        appBar: CustomAppBar(
          onSettingsTap: () {
            // Navigate to settings screen
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        body: Consumer<CameraProvider>(
          builder: (context, cameraProvider, child) {
            // Listen for captured image changes and show bottom sheet
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (cameraProvider.capturedImage != null) {
                ImagePreviewBottomSheet.show(context);
              }
            });

            return Stack(
              children: [
                // Main content
                const CameraActionsWidget(),
                
                // Floating meal type selector
                const MealTypeSelectorWidget(showAsFloating: true),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Public method for external capture triggering (for bottom nav integration)
  void capturePhoto() {
    final cameraProvider = context.read<CameraProvider>();
    cameraProvider.captureFromCamera();
  }
}