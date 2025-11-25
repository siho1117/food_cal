// lib/widgets/progress/combined_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../providers/progress_data.dart';
import '../../providers/theme_provider.dart';
import 'weight_edit_dialog.dart';

class CombinedWeightWidget extends StatelessWidget {
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightEntered;

  const CombinedWeightWidget({
    super.key,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightEntered,
  });

  String _formatWeight(double? weight) {
    if (weight == null) return '--';
    final displayWeight = isMetric ? weight : weight * 2.20462;
    return displayWeight.toStringAsFixed(1);
  }

  String _getUnit() => isMetric ? 'kg' : 'lbs';

  double _calculateProgress(double? start, double? current, double? target) {
    if (start == null || current == null || target == null) return 0.0;
    if ((start - target).abs() < 0.01) return 1.0;

    final progress = (start - current) / (start - target);
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressData, ThemeProvider>(
      builder: (context, progressData, themeProvider, child) {
        final startingWeight = progressData.startingWeight;
        final targetWeight = progressData.targetWeight;
        final progress = _calculateProgress(startingWeight, currentWeight, targetWeight);

        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return GestureDetector(
          onTap: () => _showWeightDialog(context, progressData),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
              border: Border.all(
                color: borderColor,
                width: AppWidgetTheme.cardBorderWidth,
              ),
            ),
            padding: AppWidgetTheme.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, progressData, textColor),

                SizedBox(height: AppWidgetTheme.spaceLG),

                // Visual Journey Timeline
                _buildJourneyTimeline(
                  context,
                  startingWeight,
                  currentWeight,
                  targetWeight,
                  progress,
                  textColor,
                ),

                SizedBox(height: AppWidgetTheme.spaceLG),

                // Progress Stats Card
                _buildProgressStats(
                  startingWeight,
                  currentWeight,
                  targetWeight,
                  progress,
                  textColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProgressData progressData, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: AppWidgetTheme.iconSizeSmall,
              color: textColor,
            ),
            SizedBox(width: AppWidgetTheme.spaceMS),
            Text(
              'Weight',
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeLG,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: textColor,
                shadows: AppWidgetTheme.textShadows,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showWeightDialog(context, progressData),
          child: Container(
            padding: EdgeInsets.all(AppWidgetTheme.spaceXS),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
              borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXS),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: AppWidgetTheme.iconSizeSmall,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyTimeline(
    BuildContext context,
    double? start,
    double? current,
    double? target,
    double progress,
    Color textColor,
  ) {
    return Column(
      children: [
        // Labels row - all on same level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Start',
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
              ),
            ),
            Text(
              'Current',
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
              ),
            ),
            Text(
              'Goal',
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
              ),
            ),
          ],
        ),

        SizedBox(height: AppWidgetTheme.spaceXS),

        // Numbers row - aligned to current weight center
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Start weight
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatWeight(start),
                  style: TextStyle(
                    fontSize: AppWidgetTheme.fontSizeML,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHighest),
                  ),
                ),
              ],
            ),
            // Current weight (prominent)
            Text(
              _formatWeight(current),
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeXXL,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            // Goal weight
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatWeight(target),
                  style: TextStyle(
                    fontSize: AppWidgetTheme.fontSizeML,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHighest),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: AppWidgetTheme.spaceMD),

        // Progress bar with markers
        _buildProgressBar(context, progress, textColor),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress, Color textColor) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [
            textColor,
            textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
          ],
          stops: [progress, progress],
        ),
      ),
    );
  }

  Widget _buildProgressStats(
    double? start,
    double? current,
    double? target,
    double progress,
    Color textColor,
  ) {
    // Calculate stats
    double? lost;
    double? remaining;

    if (start != null && current != null) {
      lost = (start - current).abs();
    }
    if (current != null && target != null) {
      remaining = (current - target).abs();
    }

    final progressPercent = (progress * 100).round();

    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Progress percentage
          _buildStatItem(
            label: 'Progress',
            value: '$progressPercent%',
            textColor: textColor,
          ),
          // Divider
          Container(
            width: 1,
            height: 36,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityMediumHigh),
          ),
          // Lost/Gained
          _buildStatItem(
            label: start != null && current != null && start > current ? 'Lost' : 'Gained',
            value: lost != null ? '${_formatWeight(lost)} ${_getUnit()}' : '--',
            textColor: textColor,
          ),
          // Divider
          Container(
            width: 1,
            height: 36,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityMediumHigh),
          ),
          // Remaining
          _buildStatItem(
            label: 'To Go',
            value: remaining != null ? '${_formatWeight(remaining)} ${_getUnit()}' : '--',
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeMD,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: AppWidgetTheme.spaceXXS),
        Text(
          label,
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeXS,
            fontWeight: FontWeight.w500,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          ),
        ),
      ],
    );
  }

  void _showWeightDialog(BuildContext context, ProgressData progressData) {
    showWeightEditDialog(
      context: context,
      initialWeight: currentWeight ?? 70.0,
      isMetric: isMetric,
      targetWeight: progressData.targetWeight,
      onAddWeight: (weight, isMetric) async {
        onWeightEntered(weight, isMetric);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weight updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveTarget: (targetWeight) async {
        await progressData.updateTargetWeight(targetWeight);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target weight updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }
}
