// lib/widgets/common/food_recognition_loading_dialog.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/design_system/dialog_theme.dart';

// ═══════════════════════════════════════════════════════════════
// DESIGN OPTION ENUM - Easy switching between designs
// ═══════════════════════════════════════════════════════════════

/// Available design options for the loading dialog
/// Change this in showFoodRecognitionLoading() to test different designs
enum LoadingDialogDesign {
  /// Option 1: Food Analysis Theme with phases
  foodAnalysis,

  /// Option 2: Simple Circular Progress (not implemented yet)
  simpleCircular,

  /// Option 3: Shimmer/Skeleton Loading (not implemented yet)
  shimmer,

  /// Option 4: Lottie Animation (not implemented yet)
  lottie,
}

// ═══════════════════════════════════════════════════════════════
// PUBLIC API - Show the loading dialog
// ═══════════════════════════════════════════════════════════════

/// Show food recognition loading dialog
///
/// Call this before starting the recognition process:
/// ```dart
/// showFoodRecognitionLoading(context);
/// try {
///   final result = await recognitionService.captureFromCamera();
///   Navigator.pop(context); // Close dialog
/// } catch (e) {
///   Navigator.pop(context); // Close dialog
/// }
/// ```
void showFoodRecognitionLoading(
  BuildContext context, {
  LoadingDialogDesign design = LoadingDialogDesign.foodAnalysis,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    barrierColor: Colors.black.withValues(alpha: 0.5), // Blur background
    builder: (context) => PopScope(
      canPop: false, // Prevent back button dismissal
      child: _getDialogForDesign(design),
    ),
  );
}

/// Get the appropriate dialog widget for the selected design
Widget _getDialogForDesign(LoadingDialogDesign design) {
  switch (design) {
    case LoadingDialogDesign.foodAnalysis:
      return const FoodAnalysisLoadingDialog();
    case LoadingDialogDesign.simpleCircular:
      // TODO: Implement simple circular design
      return const FoodAnalysisLoadingDialog();
    case LoadingDialogDesign.shimmer:
      // TODO: Implement shimmer design
      return const FoodAnalysisLoadingDialog();
    case LoadingDialogDesign.lottie:
      // TODO: Implement Lottie design
      return const FoodAnalysisLoadingDialog();
  }
}

// ═══════════════════════════════════════════════════════════════
// OPTION 1: FOOD ANALYSIS THEME
// ═══════════════════════════════════════════════════════════════

/// Loading dialog with food analysis theme and phases
/// Shows progress through different recognition phases
class FoodAnalysisLoadingDialog extends StatefulWidget {
  const FoodAnalysisLoadingDialog({super.key});

  @override
  State<FoodAnalysisLoadingDialog> createState() =>
      _FoodAnalysisLoadingDialogState();
}

class _FoodAnalysisLoadingDialogState
    extends State<FoodAnalysisLoadingDialog> {
  int _currentPhaseIndex = 0;
  Timer? _phaseTimer;

  // Recognition phases
  final List<RecognitionPhase> _phases = const [
    RecognitionPhase(
      icon: '📸',
      title: 'Analyzing image...',
      description: 'Processing photo',
    ),
    RecognitionPhase(
      icon: '🍽️',
      title: 'Identifying food...',
      description: 'Recognizing items',
    ),
    RecognitionPhase(
      icon: '📊',
      title: 'Calculating nutrition...',
      description: 'Computing values',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startPhaseRotation();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  /// Rotate through phases every 2 seconds
  void _startPhaseRotation() {
    _phaseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentPhaseIndex = (_currentPhaseIndex + 1) % _phases.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPhase = _phases[_currentPhaseIndex];

    return Dialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      child: Padding(
        padding: AppDialogTheme.contentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated food icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2), // Scale from 0.8 to 1.0
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Text(
                currentPhase.icon,
                style: const TextStyle(fontSize: 64),
              ),
            ),

            const SizedBox(height: AppDialogTheme.spaceLG),

            // Circular progress indicator
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppDialogTheme.colorPrimaryDark,
                ),
              ),
            ),

            const SizedBox(height: AppDialogTheme.spaceLG),

            // Phase title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                currentPhase.title,
                key: ValueKey(currentPhase.title),
                style: AppDialogTheme.titleStyle.copyWith(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppDialogTheme.spaceXS),

            // Phase description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                currentPhase.description,
                key: ValueKey(currentPhase.description),
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppDialogTheme.spaceXS),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════

/// Represents a phase in the food recognition process
class RecognitionPhase {
  final String icon;
  final String title;
  final String description;

  const RecognitionPhase({
    required this.icon,
    required this.title,
    required this.description,
  });
}
