// lib/widgets/progress/combined_weight_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../config/design_system/widget_theme.dart';
import '../../providers/progress_data.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import 'weight_edit_dialog.dart' show showWeightEditDialog, WeightMode;

class CombinedWeightWidget extends StatefulWidget {
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightEntered;

  const CombinedWeightWidget({
    super.key,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightEntered,
  });

  @override
  State<CombinedWeightWidget> createState() => _CombinedWeightWidgetState();
}

class _CombinedWeightWidgetState extends State<CombinedWeightWidget> {
  double? _previousWeight;
  double? _previousStart;
  double? _previousTarget;
  double _previousProgress = 0.0;

  @override
  void didUpdateWidget(CombinedWeightWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track previous weight for animation
    if (oldWidget.currentWeight != widget.currentWeight) {
      _previousWeight = oldWidget.currentWeight;
    }
  }

  String _formatWeight(double? weight) {
    if (weight == null) return '--';
    final displayWeight = widget.isMetric ? weight : weight * 2.20462;
    return displayWeight.toStringAsFixed(1);
  }

  String _getUnit(AppLocalizations l10n) => widget.isMetric ? l10n.kg : l10n.lbs;

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
        final l10n = AppLocalizations.of(context)!;
        final startingWeight = progressData.startingWeight;
        final targetWeight = progressData.targetWeight;
        final progress = _calculateProgress(startingWeight, widget.currentWeight, targetWeight);

        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          GlassCardStyle.borderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        // Track previous values for animations
        final prevStart = _previousStart ?? startingWeight;
        final prevTarget = _previousTarget ?? targetWeight;
        final prevProgress = _previousProgress;

        _previousStart = startingWeight;
        _previousTarget = targetWeight;
        _previousProgress = progress;

        return GestureDetector(
          onTap: () => _showWeightDialog(context, progressData),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassCardStyle.blurSigma,
                sigmaY: GlassCardStyle.blurSigma,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                  borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: GlassCardStyle.borderWidth,
                  ),
                ),
                padding: AppWidgetTheme.cardPadding,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, progressData, textColor, l10n),

                SizedBox(height: AppWidgetTheme.spaceLG),

                // Visual Journey Timeline with animations
                _buildJourneyTimeline(
                  context,
                  progressData,
                  startingWeight,
                  widget.currentWeight,
                  targetWeight,
                  progress,
                  textColor,
                  prevStart,
                  _previousWeight,
                  prevTarget,
                  prevProgress,
                ),

                SizedBox(height: AppWidgetTheme.spaceLG),

                // Progress Stats Card
                _buildProgressStats(
                  startingWeight,
                  widget.currentWeight,
                  targetWeight,
                  progress,
                  textColor,
                  l10n,
                ),
              ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProgressData progressData, Color textColor, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const AnimatedEmoji(
              AnimatedEmojis.directHit,
              size: 26,
            ),
            SizedBox(width: AppWidgetTheme.spaceMS),
            Text(
              l10n.weight,
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
    ProgressData progressData,
    double? start,
    double? current,
    double? target,
    double progress,
    Color textColor,
    double? prevStart,
    double? prevCurrent,
    double? prevTarget,
    double prevProgress,
  ) {
    return Column(
      children: [
        // Labels row - all on same level with tap handlers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showWeightDialog(context, progressData, initialMode: WeightMode.start),
              child: Text(
                AppLocalizations.of(context)!.start,
                style: TextStyle(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.current,
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
              ),
            ),
            GestureDetector(
              onTap: () => _showWeightDialog(context, progressData, initialMode: WeightMode.target),
              child: Text(
                AppLocalizations.of(context)!.goal,
                style: TextStyle(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Numbers row with animated counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Start weight with animation - tappable to open dialog on Start tab
            GestureDetector(
              onTap: () => _showWeightDialog(context, progressData, initialMode: WeightMode.start),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedNumber(
                    value: start,
                    prevValue: prevStart,
                    isMetric: widget.isMetric,
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeML,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHighest),
                    ),
                  ),
                ],
              ),
            ),
            // Current weight (prominent) with animation
            _AnimatedNumber(
              value: current,
              prevValue: prevCurrent,
              isMetric: widget.isMetric,
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeXXL,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            // Goal weight with animation - tappable to open dialog on Target tab
            GestureDetector(
              onTap: () => _showWeightDialog(context, progressData, initialMode: WeightMode.target),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AnimatedNumber(
                    value: target,
                    prevValue: prevTarget,
                    isMetric: widget.isMetric,
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeML,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHighest),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar with animation
        _AnimatedProgressBar(
          progress: progress,
          prevProgress: prevProgress,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _buildProgressStats(
    double? start,
    double? current,
    double? target,
    double progress,
    Color textColor,
    AppLocalizations l10n,
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
            label: l10n.progress,
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
            label: start != null && current != null && start > current ? l10n.lost : l10n.gained,
            value: lost != null ? '${_formatWeight(lost)} ${_getUnit(l10n)}' : '--',
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
            label: l10n.toGo,
            value: remaining != null ? '${_formatWeight(remaining)} ${_getUnit(l10n)}' : '--',
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

  void _showWeightDialog(BuildContext context, ProgressData progressData, {WeightMode initialMode = WeightMode.current}) {
    final settingsProvider = context.read<SettingsProvider>();

    showWeightEditDialog(
      context: context,
      initialWeight: widget.currentWeight ?? 70.0,
      isMetric: widget.isMetric,
      targetWeight: progressData.targetWeight,
      startingWeight: progressData.startingWeight,
      initialMode: initialMode,
      onAddWeight: (weight, isMetric) async {
        widget.onWeightEntered(weight, isMetric);

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
}

/// Animated number widget that smoothly counts up/down when value changes
class _AnimatedNumber extends StatelessWidget {
  final double? value;
  final double? prevValue;
  final bool isMetric;
  final TextStyle style;

  const _AnimatedNumber({
    required this.value,
    required this.prevValue,
    required this.isMetric,
    required this.style,
  });

  String _formatWeight(double? weight) {
    if (weight == null) return '--';
    final displayWeight = isMetric ? weight : weight * 2.20462;
    return displayWeight.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // If no previous value or same value, show static text
    if (prevValue == null || value == prevValue) {
      return Text(
        _formatWeight(value),
        style: style,
      );
    }

    // Animate from previous to new value
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(
        begin: prevValue,
        end: value ?? prevValue,
      ),
      builder: (context, animatedValue, child) {
        return Text(
          _formatWeight(animatedValue),
          style: style,
        );
      },
    );
  }
}

/// Animated progress bar that smoothly fills/empties when progress changes
class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final double prevProgress;
  final Color textColor;

  const _AnimatedProgressBar({
    required this.progress,
    required this.prevProgress,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: prevProgress,
        end: progress,
      ),
      builder: (context, animatedProgress, child) {
        return Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                textColor,
                textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
              ],
              stops: [animatedProgress, animatedProgress],
            ),
          ),
        );
      },
    );
  }
}
