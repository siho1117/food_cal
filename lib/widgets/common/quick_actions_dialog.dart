// lib/widgets/common/quick_actions_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/accent_colors.dart';
import '../../providers/camera_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/progress_data.dart';
import '../../providers/settings_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../data/models/food_item.dart';
import '../../l10n/generated/app_localizations.dart';
import '../progress/exercise_entry_dialog.dart';
import '../progress/weight_edit_dialog.dart';
import '../home/quick_edit_food_dialog.dart';

/// Modern Quick Actions bottom sheet dialog
///
/// A unified hub for quick data entry:
/// - Add Food (Camera/Gallery)
/// - Log Exercise
/// - Update Weight
///
/// Design principles:
/// - Grid layout for scalability
/// - Icon-first design with clear hierarchy
/// - Separated loading states
/// - Smooth animations
void showQuickActionsDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => const _QuickActionsDialogContent(),
  );
}

class _QuickActionsDialogContent extends StatelessWidget {
  const _QuickActionsDialogContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.0),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(
              top: AppWidgetTheme.spaceMD,
              bottom: AppWidgetTheme.spaceLG,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Actions Grid - Option E Floating Tiles Layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceLG),
            child: Column(
              children: [
                // Row 1: Gallery/Manual stacked + Camera (large)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Stacked Gallery + Manual
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _FloatingTileSmall(
                            action: _QuickAction(
                              icon: Icons.photo_library_rounded,
                              label: l10n.gallery,
                              subtitle: l10n.pickFoodPhoto,
                              color: AccentColors.brightOrange,
                              onTap: () => _handleGalleryAction(context),
                            ),
                          ),
                          const SizedBox(height: AppWidgetTheme.spaceSM),
                          _FloatingTileSmall(
                            action: _QuickAction(
                              icon: Icons.edit_note_rounded,
                              label: l10n.type,
                              subtitle: l10n.logManually,
                              color: AccentColors.electricBlue,
                              onTap: () => _handleManualEntryAction(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppWidgetTheme.spaceSM),

                    // Right: Camera (PRIMARY - Large tile)
                    Expanded(
                      flex: 3,
                      child: _FloatingTileLarge(
                        action: _QuickAction(
                          icon: Icons.camera_alt_rounded,
                          label: l10n.takePhoto,
                          subtitle: l10n.scanFoodWithCamera,
                          color: AccentColors.coral,
                          onTap: () => _handleCameraAction(context),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppWidgetTheme.spaceSM),

                // Row 2: Weight + Exercise (matching flex ratios above)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _FloatingTileMedium(
                        action: _QuickAction(
                          icon: Icons.monitor_weight_rounded,
                          label: l10n.weight,
                          subtitle: l10n.update,
                          color: AccentColors.brightGreen,
                          onTap: () => _handleWeightAction(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppWidgetTheme.spaceSM),
                    Expanded(
                      flex: 3,
                      child: _FloatingTileMedium(
                        action: _QuickAction(
                          icon: Icons.fitness_center_rounded,
                          label: l10n.exercise,
                          subtitle: l10n.logActivity,
                          color: AccentColors.periwinkle,
                          onTap: () => _handleExerciseAction(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom safe area padding
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppWidgetTheme.spaceXXL,
          ),
        ],
          ),
        ),
      ),
    );
  }

  // Action Handlers - Close dialog smoothly, then call provider
  Future<void> _handleCameraAction(BuildContext context) async {
    // Close quick actions dialog and wait for animation to complete
    await Navigator.of(context).maybePop();

    // Small delay to ensure smooth transition
    await Future.delayed(const Duration(milliseconds: 100));

    // Call camera provider directly
    if (context.mounted) {
      CameraProvider().captureFromCamera(context);
    }
  }

  Future<void> _handleGalleryAction(BuildContext context) async {
    // Close quick actions dialog and wait for animation to complete
    await Navigator.of(context).maybePop();

    // Small delay for smooth transition (reduced from 400ms)
    // Note: Cannot pre-load OS gallery picker - it requires user interaction
    await Future.delayed(const Duration(milliseconds: 150));

    // Call camera provider directly
    // Note: The gallery refresh glitch is OS behavior and cannot be fully prevented
    if (context.mounted) {
      CameraProvider().selectFromGallery(context);
    }
  }

  void _handleExerciseAction(BuildContext context) {
    Navigator.of(context).pop();

    // Show exercise entry dialog
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => ExerciseEntryDialog(
        exerciseProvider: exerciseProvider,
        onExerciseSaved: () {
          // Navigate to Progress page after exercise is saved
          navigationProvider.navigateToProgress();
        },
      ),
    );
  }

  void _handleWeightAction(BuildContext context) {
    Navigator.of(context).pop();

    // Show weight edit dialog
    final progressData = Provider.of<ProgressData>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

    showWeightEditDialog(
      context: context,
      initialWeight: progressData.currentWeight ?? 70.0,
      isMetric: progressData.isMetric,
      targetWeight: progressData.targetWeight,
      startingWeight: progressData.startingWeight,
      onAddWeight: (weight, isMetric) async {
        await progressData.addWeightEntry(weight, isMetric);
        // Navigate to Progress page after weight is saved
        navigationProvider.navigateToProgress();
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.weightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveTarget: (targetWeight) async {
        await progressData.updateTargetWeight(targetWeight);
        // Navigate to Progress page after target weight is saved
        navigationProvider.navigateToProgress();
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.targetWeightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveStartingWeight: (startingWeight) async {
        await settingsProvider.updateStartingWeight(startingWeight);

        // Reload progress data to refresh the UI with new starting weight
        await progressData.refreshData();

        // Navigate to Progress page after starting weight is saved
        navigationProvider.navigateToProgress();
        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.startingWeightUpdated),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _handleManualEntryAction(BuildContext context) {
    Navigator.of(context).pop();

    // Show empty food card dialog for manual entry
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    final emptyFoodItem = FoodItem.empty();

    showDialog(
      context: context,
      builder: (context) => QuickEditFoodDialog(
        foodItem: emptyFoodItem,
        onUpdated: () {
          homeProvider.refreshData();
          // Navigate to Home page after food is saved
          navigationProvider.navigateToHome();
        },
      ),
    );
  }
}

/// Data model for quick action
class _QuickAction {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

/// Large floating tile - primary action with prominent styling
class _FloatingTileLarge extends StatelessWidget {
  final _QuickAction action;

  const _FloatingTileLarge({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          action.onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                action.color,
                action.color.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(AppWidgetTheme.spaceLG),
            height: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                // Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      action.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small floating tile - compact secondary action
class _FloatingTileSmall extends StatelessWidget {
  final _QuickAction action;

  const _FloatingTileSmall({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          action.onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: action.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(AppWidgetTheme.spaceMD),
            height: 66,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppWidgetTheme.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        action.label,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        action.subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Medium floating tile - secondary action
class _FloatingTileMedium extends StatelessWidget {
  final _QuickAction action;

  const _FloatingTileMedium({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          action.onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: action.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(AppWidgetTheme.spaceMD),
            height: 72,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppWidgetTheme.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        action.label,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        action.subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

