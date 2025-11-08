// lib/widgets/progress/health_metrics_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/user_profile.dart';

/// Combined health metrics display widget showing BMI, Body Fat, BMR, and TDEE
///
/// This widget is purely for display - all calculations are handled by
/// HealthMetrics utility class and passed in via props.
class HealthMetricsWidget extends StatelessWidget {
  final double? currentWeight;
  final double? targetWeight;
  final UserProfile? userProfile;
  final double? bmi;
  final String? bmiCategory;
  final double? bodyFat;
  final String? bodyFatCategory;
  final double? bmr;
  final double? tdee;

  // Progress tracking values (calculated in provider)
  final double? targetBMI;
  final double? bmiProgress;
  final double? targetBodyFat;
  final double? bodyFatProgress;

  const HealthMetricsWidget({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.userProfile,
    required this.bmi,
    required this.bmiCategory,
    required this.bodyFat,
    required this.bodyFatCategory,
    required this.bmr,
    required this.tdee,
    this.targetBMI,
    this.bmiProgress,
    this.targetBodyFat,
    this.bodyFatProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return Container(
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
              Row(
                children: [
                  Text(
                    '🎯',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: AppWidgetTheme.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Metrics',
                          style: TextStyle(
                            fontSize: AppWidgetTheme.fontSizeLG,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: textColor,
                            shadows: AppWidgetTheme.textShadows,
                          ),
                        ),
                        Text(
                          'Body composition & energy',
                          style: TextStyle(
                            fontSize: AppWidgetTheme.fontSizeXS,
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                            shadows: AppWidgetTheme.textShadows,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                      size: AppWidgetTheme.iconSizeSmall,
                    ),
                    onPressed: () {
                      _showInfoDialog(context);
                    },
                  ),
                ],
              ),

              SizedBox(height: AppWidgetTheme.spaceLG),

              // BMI and Body Fat cards in row
              Row(
                children: [
                  Expanded(
                    child: _buildBMICard(textColor),
                  ),
                  SizedBox(width: AppWidgetTheme.spaceML),
                  Expanded(
                    child: _buildBodyFatCard(textColor),
                  ),
                ],
              ),

              SizedBox(height: AppWidgetTheme.spaceML),

              // BMR and TDEE cards in row
              Row(
                children: [
                  Expanded(
                    child: _buildBMRCard(textColor),
                  ),
                  SizedBox(width: AppWidgetTheme.spaceML),
                  Expanded(
                    child: _buildTDEECard(textColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBMICard(Color textColor) {
    final currentBMI = bmi;
    final targetBMIValue = targetBMI;
    final progressPercentage = bmiProgress;

    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(
          textColor,
          AppWidgetTheme.opacityLight,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
      ),
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(80, 80),
                  painter: _ProgressRingPainter(
                    progress: progressPercentage ?? 0.0,
                    backgroundColor: textColor.withValues(alpha: 0.1),
                    progressColor: Color(0xFF4CAF50),
                  ),
                ),
                Text(
                  progressPercentage != null
                      ? '${(progressPercentage * 100).round()}%'
                      : '--',
                  style: TextStyle(
                    fontSize: AppWidgetTheme.fontSizeML,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    shadows: AppWidgetTheme.textShadows,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Current → Target
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeSM,
                color: textColor,
                shadows: AppWidgetTheme.textShadows,
              ),
              children: [
                TextSpan(
                  text: currentBMI?.toStringAsFixed(1) ?? '--',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' → ',
                  style: TextStyle(
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                  ),
                ),
                TextSpan(
                  text: targetBMIValue?.toStringAsFixed(1) ?? '--',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Horizontal scale
          _buildHorizontalScale(
            currentValue: currentBMI,
            targetValue: targetBMIValue,
            maxValue: 40.0,
            zones: [
              _ScaleZone('Underweight', 0, 18.5, Color(0xFF64B5F6)),
              _ScaleZone('Normal', 18.5, 25, Color(0xFF4CAF50)),
              _ScaleZone('Overweight', 25, 30, Color(0xFFFFA726)),
              _ScaleZone('Obese', 30, 40, Color(0xFFEF5350)),
            ],
            textColor: textColor,
          ),

          SizedBox(height: AppWidgetTheme.spaceXS),

          Text(
            'BMI',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatCard(Color textColor) {
    final currentBodyFat = bodyFat;
    final targetBodyFatValue = targetBodyFat;
    final progressPercentage = bodyFatProgress;

    // Gender-specific zones
    final zones = userProfile?.gender == 'Male'
        ? [
            _ScaleZone('Athletic', 0, 14, Color(0xFF4CAF50)),
            _ScaleZone('Fitness', 14, 18, Color(0xFF8BC34A)),
            _ScaleZone('Average', 18, 25, Color(0xFFFFA726)),
            _ScaleZone('Obese', 25, 40, Color(0xFFEF5350)),
          ]
        : [
            _ScaleZone('Athletic', 0, 21, Color(0xFF4CAF50)),
            _ScaleZone('Fitness', 21, 25, Color(0xFF8BC34A)),
            _ScaleZone('Average', 25, 32, Color(0xFFFFA726)),
            _ScaleZone('Obese', 32, 45, Color(0xFFEF5350)),
          ];

    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(
          textColor,
          AppWidgetTheme.opacityLight,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
      ),
      child: Column(
        children: [
          // Progress Ring
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(80, 80),
                  painter: _ProgressRingPainter(
                    progress: progressPercentage ?? 0.0,
                    backgroundColor: textColor.withValues(alpha: 0.1),
                    progressColor: Color(0xFF2196F3),
                  ),
                ),
                Text(
                  progressPercentage != null
                      ? '${(progressPercentage * 100).round()}%'
                      : '--',
                  style: TextStyle(
                    fontSize: AppWidgetTheme.fontSizeML,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    shadows: AppWidgetTheme.textShadows,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Current → Target
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeSM,
                color: textColor,
                shadows: AppWidgetTheme.textShadows,
              ),
              children: [
                TextSpan(
                  text: currentBodyFat != null ? '${currentBodyFat.toStringAsFixed(1)}%' : '--',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: ' → ',
                  style: TextStyle(
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                  ),
                ),
                TextSpan(
                  text: targetBodyFatValue != null ? '${targetBodyFatValue.toStringAsFixed(1)}%' : '--',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Horizontal scale
          _buildHorizontalScale(
            currentValue: currentBodyFat,
            targetValue: targetBodyFatValue,
            maxValue: zones.last.end,
            zones: zones,
            textColor: textColor,
          ),

          SizedBox(height: AppWidgetTheme.spaceXS),

          Text(
            'Body Fat %',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMRCard(Color textColor) {
    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB74D),
            Color(0xFFFF9800),
          ],
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
      ),
      child: Column(
        children: [
          Text(
            'BMR',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.9),
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXXS),
          Text(
            bmr?.round().toString() ?? '--',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXXL,
              fontWeight: FontWeight.w700,
              height: 1.0,
              color: Colors.white,
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXXS),
          Text(
            'kcal/day',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTDEECard(Color textColor) {
    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEF5350),
            Color(0xFFE53935),
          ],
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
      ),
      child: Column(
        children: [
          Text(
            'TDEE',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.9),
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXXS),
          Text(
            tdee?.round().toString() ?? '--',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXXL,
              fontWeight: FontWeight.w700,
              height: 1.0,
              color: Colors.white,
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXXS),
          Text(
            'kcal/day',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScale({
    required double? currentValue,
    required double? targetValue,
    required double maxValue,
    required List<_ScaleZone> zones,
    required Color textColor,
  }) {
    return Column(
      children: [
        // Scale bar with zones
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: zones.map((zone) {
                final width = (zone.end - zone.start) / maxValue;
                return Expanded(
                  flex: (width * 100).round(),
                  child: Container(
                    color: zone.color.withValues(alpha: 0.6),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Indicators
        SizedBox(
          height: 16,
          child: Stack(
            children: [
              // Current value indicator (dark arrow from top)
              if (currentValue != null && currentValue <= maxValue)
                Positioned(
                  left: (currentValue / maxValue * 100).clamp(0, 100),
                  top: 0,
                  child: FractionalTranslation(
                    translation: Offset(-0.5, 0),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: textColor,
                      size: 16,
                    ),
                  ),
                ),

              // Target value indicator (gray arrow from bottom)
              if (targetValue != null && targetValue <= maxValue)
                Positioned(
                  left: (targetValue / maxValue * 100).clamp(0, 100),
                  bottom: 0,
                  child: FractionalTranslation(
                    translation: Offset(-0.5, 0),
                    child: Icon(
                      Icons.arrow_drop_up,
                      color: textColor.withValues(alpha: 0.4),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: AppDialogTheme.shape,
        backgroundColor: AppDialogTheme.backgroundColor,
        title: Text(
          'Health Metrics Info',
          style: AppDialogTheme.titleStyle,
        ),
        contentPadding: AppDialogTheme.contentPadding,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // BMI Section
              Text(
                'BMI (Body Mass Index)',
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                'Measures weight relative to height. Range: Underweight (<18.5), Normal (18.5-25), Overweight (25-30), Obese (>30)',
                style: AppDialogTheme.bodyStyle,
              ),
              SizedBox(height: AppDialogTheme.spaceMD),

              // Body Fat Section
              Text(
                'Body Fat %',
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                'Estimated body fat percentage based on BMI, age, and gender. Lower percentages indicate more lean muscle mass.',
                style: AppDialogTheme.bodyStyle,
              ),
              SizedBox(height: AppDialogTheme.spaceMD),

              // BMR Section
              Text(
                'BMR (Basal Metabolic Rate)',
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                'Calories burned at rest. This is your baseline energy expenditure.',
                style: AppDialogTheme.bodyStyle,
              ),
              SizedBox(height: AppDialogTheme.spaceMD),

              // TDEE Section
              Text(
                'TDEE (Total Daily Energy Expenditure)',
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                'Total calories burned including activity. This is your BMR multiplied by your activity level.',
                style: AppDialogTheme.bodyStyle,
              ),
            ],
          ),
        ),
        actionsPadding: AppDialogTheme.actionsPadding,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppDialogTheme.cancelButtonStyle,
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ScaleZone {
  final String label;
  final double start;
  final double end;
  final Color color;

  _ScaleZone(this.label, this.start, this.end, this.color);
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final strokeWidth = 6.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2; // Start at top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
