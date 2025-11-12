// lib/widgets/common/quick_actions_dialog.dart
import 'package:flutter/material.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/nutrition_colors.dart';
import '../../providers/camera_provider.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(
              top: AppWidgetTheme.spaceMD,
              bottom: AppWidgetTheme.spaceLG,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceXXL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Actions',
                  style: AppTypography.displaySmall.copyWith(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Close button
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceXL),

          // Actions Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceXXL),
            child: Column(
              children: [
                // Row 1: Food Actions
                _buildActionRow(
                  context,
                  leftAction: _QuickAction(
                    icon: Icons.camera_alt_rounded,
                    label: 'Take Photo',
                    subtitle: 'Scan food',
                    color: NutritionColors.caloriesColor,
                    onTap: () => _handleCameraAction(context),
                  ),
                  rightAction: _QuickAction(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    subtitle: 'Choose photo',
                    color: NutritionColors.caloriesColor.withValues(alpha: 0.8),
                    onTap: () => _handleGalleryAction(context),
                  ),
                ),

                SizedBox(height: AppWidgetTheme.spaceLG),

                // Row 2: Exercise & Weight
                _buildActionRow(
                  context,
                  leftAction: _QuickAction(
                    icon: Icons.fitness_center_rounded,
                    label: 'Exercise',
                    subtitle: 'Log activity',
                    color: NutritionColors.exerciseColor,
                    onTap: () => _handleExerciseAction(context),
                  ),
                  rightAction: _QuickAction(
                    icon: Icons.monitor_weight_rounded,
                    label: 'Weight',
                    subtitle: 'Update weight',
                    color: NutritionColors.budgetColor,
                    onTap: () => _handleWeightAction(context),
                  ),
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
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required _QuickAction leftAction,
    required _QuickAction rightAction,
  }) {
    return Row(
      children: [
        Expanded(child: _QuickActionCard(action: leftAction)),
        SizedBox(width: AppWidgetTheme.spaceMD),
        Expanded(child: _QuickActionCard(action: rightAction)),
      ],
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
    // TODO: Navigate to exercise log screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise logging coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleWeightAction(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Show weight input dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight update coming soon!'),
        duration: Duration(seconds: 2),
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

/// Beautiful card for each quick action
class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusLG),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                action.color.withValues(alpha: 0.12),
                action.color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusLG),
            border: Border.all(
              color: action.color.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(AppWidgetTheme.spaceLG),
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24,
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
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: AppWidgetTheme.spaceXXS),
                    Text(
                      action.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.grey.shade600,
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

