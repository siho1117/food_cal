// lib/widgets/common/activity_emoji.dart
import 'package:flutter/material.dart';

/// Widget for displaying activity emoji PNG images
///
/// Uses locally bundled PNG images for exercise activity icons.
/// These images may be animated PNGs (APNG) depending on the source.
class ActivityEmoji extends StatelessWidget {
  /// Path to the PNG asset file
  final String assetPath;

  /// Size of the emoji (width and height)
  final double size;

  const ActivityEmoji(
    this.assetPath, {
    super.key,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to error icon if asset fails to load
        debugPrint('ActivityEmoji: Failed to load $assetPath - $error');
        return Icon(
          Icons.error_outline,
          size: size,
          color: Colors.grey,
        );
      },
    );
  }
}

/// All activity emoji PNG paths organized by activity type
///
/// This class provides constants for all bundled activity emoji assets.
class ActivityEmojis {
  ActivityEmojis._(); // Private constructor to prevent instantiation

  // ========================================
  // 🏃 ACTIVITY EMOJIS
  // ========================================

  /// 🚶 Person walking - For walking activities
  static const String personWalking = 'assets/emojis/activities/person_walking_animated_default.png';

  /// 🏃 Person running - For running/jogging activities
  static const String personRunning = 'assets/emojis/activities/person_running_animated_default.png';

  /// 🏋️ Person lifting weights - For strength training
  static const String personLiftingWeights = 'assets/emojis/activities/person_lifting_weights_animated_default.png';

  /// 🚴 Person biking - For cycling activities
  static const String personBiking = 'assets/emojis/activities/person_biking_animated_default.png';

  /// 🏊 Person swimming - For swimming activities
  static const String personSwimming = 'assets/emojis/activities/person_swimming_animated_default.png';

  /// 🧘 Person in lotus position - For yoga/meditation
  static const String personLotus = 'assets/emojis/activities/person_in_lotus_position_animated_default.png';

  /// 🤸 Person cartwheeling - For gymnastics/flexibility
  static const String personCartwheeling = 'assets/emojis/activities/person_cartwheeling_animated_default.png';

  /// Get all activity emoji paths
  static List<String> get all => [
    personWalking,
    personRunning,
    personLiftingWeights,
    personBiking,
    personSwimming,
    personLotus,
    personCartwheeling,
  ];
}
