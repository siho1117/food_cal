// lib/widgets/home/calorie_summary_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/accent_colors.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';

/// Widget-specific design constants (progress bar - unique to this widget)
class _CalorieSummaryDesign {
  static const double progressBarHeight = 6.0;
  static const double progressBarGap = 4.0;
  static const int progressBarSegments = 10;
  static const double mainCalorieFontSize = 84.0;

  // Single red with opacity gradient (simplified system)
  static const Color warningRed = AccentColors.vibrantRed; // #FF4757 - Base red color for all warning levels
}

/// Utility class for calorie-related calculations and formatting
/// Extracted for testability
class CalorieSummaryUtils {
  /// Formats a number with thousands separator or k-suffix
  /// Examples: 1500 → "1,500", 10000 → "10.0k", 10500 → "10.5k"
  static String formatNumber(int number) {
    if (number >= 10000) {
      final k = number / 1000;
      if (k % 1 == 0) {
        return '${k.toInt()}k';
      }
      return '${k.toStringAsFixed(1)}k';
    }

    final str = number.toString();
    if (str.length <= 3) return str;

    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  /// Calculates remaining calories (can be negative if over budget)
  static int calculateRemaining(int totalCalories, int calorieGoal) {
    return calorieGoal - totalCalories;
  }

  /// Calculates progress as a value between 0.0 and 1.0
  static double calculateProgress(int totalCalories, int calorieGoal) {
    return (totalCalories / calorieGoal).clamp(0.0, 1.0);
  }
}

class CalorieSummaryWidget extends StatefulWidget {
  const CalorieSummaryWidget({super.key});

  @override
  State<CalorieSummaryWidget> createState() => _CalorieSummaryWidgetState();
}

class _CalorieSummaryWidgetState extends State<CalorieSummaryWidget> 
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _countController;
  late AnimationController _slideController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _countAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    _countAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    
    _startAnimations();
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
        _countController.forward();
      }
    });
  }

  void _restartAnimations() {
    _progressController.reset();
    _countController.reset();
    _slideController.reset();
    _startAnimations();
  }

  void _checkForRefresh(int totalCalories, int calorieGoal) {
    final currentHash = '$totalCalories-$calorieGoal';
    if (_previousDataHash != null && _previousDataHash != currentHash && mounted) {
      _restartAnimations();
    }
    _previousDataHash = currentHash;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _countController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _buildSemanticLabel(int totalCalories, int calorieGoal, int remaining, bool isOverBudget) {
    final currentText = AppLocalizations.of(context)!.caloriesToday;
    final remainingText = AppLocalizations.of(context)!.remainingCalories;

    if (isOverBudget) {
      final overAmount = remaining.abs();
      return '$currentText: $totalCalories of $calorieGoal calories. Over budget by $overAmount calories.';
    } else if (remaining == 0) {
      return '$currentText: $totalCalories of $calorieGoal calories. Goal reached.';
    } else {
      return '$currentText: $totalCalories of $calorieGoal calories. $remaining $remainingText.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NEW: Now consuming both HomeProvider AND ThemeProvider
    return Consumer2<HomeProvider, ThemeProvider>(
      builder: (context, homeProvider, themeProvider, child) {
        if (homeProvider.isLoading) {
          return _buildLoadingState(themeProvider);
        }

        final totalCalories = homeProvider.totalCalories;
        final calorieGoal = homeProvider.calorieGoal;
        final effectiveGoal = homeProvider.effectiveCalorieGoal;
        final bonusCalories = homeProvider.exerciseBonusCalories;
        final bonusEnabled = homeProvider.exerciseBonusEnabled;

        final remaining = CalorieSummaryUtils.calculateRemaining(totalCalories, effectiveGoal);
        final isOverBudget = remaining < 0;

        _checkForRefresh(totalCalories, effectiveGoal);

        final calorieProgress = CalorieSummaryUtils.calculateProgress(totalCalories, effectiveGoal);

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Semantics(
              label: _buildSemanticLabel(totalCalories, effectiveGoal, remaining, isOverBudget),
              child: _buildTransparentCard(
                themeProvider: themeProvider,
                homeProvider: homeProvider,
                totalCalories: totalCalories,
                calorieGoal: calorieGoal,
                effectiveGoal: effectiveGoal,
                bonusCalories: bonusCalories,
                bonusEnabled: bonusEnabled,
                remaining: remaining,
                isOverBudget: isOverBudget,
                calorieProgress: calorieProgress,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeProvider themeProvider) {
    final borderColor = AppWidgetTheme.getBorderColor(
      themeProvider.selectedGradient,
      GlassCardStyle.borderOpacity,
    );
    final textColor = AppWidgetTheme.getTextColor(
      themeProvider.selectedGradient,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassCardStyle.blurSigma,
          sigmaY: GlassCardStyle.blurSigma,
        ),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
            borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
            border: Border.all(
              color: borderColor,
              width: GlassCardStyle.borderWidth,
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHighest),
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentCard({
    required ThemeProvider themeProvider,
    required HomeProvider homeProvider,
    required int totalCalories,
    required int calorieGoal,
    required int effectiveGoal,
    required int bonusCalories,
    required bool bonusEnabled,
    required int remaining,
    required bool isOverBudget,
    required double calorieProgress,
  }) {
    final borderColor = AppWidgetTheme.getBorderColor(
      themeProvider.selectedGradient,
      GlassCardStyle.borderOpacity,
    );
    final textColor = AppWidgetTheme.getTextColor(
      themeProvider.selectedGradient,
    );

    return ClipRRect(
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
          child: Padding(
            padding: AppWidgetTheme.cardPadding,
            child: Column(
          children: [
            // Title with toggle button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Title with flame icon
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 22,
                      color: textColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.caloriesToday,
                      style: TextStyle(
                        fontSize: 22,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        shadows: AppWidgetTheme.textShadows,
                      ),
                    ),
                  ],
                ),
                // Right: Exercise bonus toggle
                _buildExerciseBonusToggle(homeProvider, textColor),
              ],
            ),

            const SizedBox(height: AppWidgetTheme.spaceXL),

            // Main calorie number
            _buildMainDisplay(
              totalCalories,
              calorieGoal,
              bonusCalories,
              bonusEnabled,
              textColor,
            ),

            const SizedBox(height: AppWidgetTheme.spaceXXL),

            // Progress bar (red when over budget)
            _buildSegmentedProgress(calorieProgress, isOverBudget, textColor),

            const SizedBox(height: AppWidgetTheme.spaceML),

            // Remaining calories
            _buildRemainingInfo(remaining, textColor),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildMainDisplay(
    int totalCalories,
    int calorieGoal,
    int bonusCalories,
    bool bonusEnabled,
    Color textColor,
  ) {
    // Cache the TextStyle to avoid recreating it on every animation frame
    final numberStyle = TextStyle(
      fontSize: _CalorieSummaryDesign.mainCalorieFontSize,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.0,
      letterSpacing: -2,
      shadows: AppWidgetTheme.textShadows,
    );

    return Center(
      child: Column(
        children: [
          // Animated calorie number
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              final animatedValue = (_countAnimation.value * totalCalories).round();

              return Text(
                CalorieSummaryUtils.formatNumber(animatedValue),
                style: numberStyle,
              );
            },
          ),

          const SizedBox(height: AppWidgetTheme.spaceSM),

          // Goal line with bonus
          _buildGoalLine(calorieGoal, bonusCalories, bonusEnabled, textColor),
        ],
      ),
    );
  }

  /// Build the goal line with optional bonus display
  Widget _buildGoalLine(
    int calorieGoal,
    int bonusCalories,
    bool bonusEnabled,
    Color textColor,
  ) {
    final baseStyle = TextStyle(
      fontSize: AppWidgetTheme.fontSizeLG,
      fontWeight: FontWeight.w500,
      color: textColor,
      letterSpacing: 0.3,
      shadows: AppWidgetTheme.textShadows,
    );

    // If bonus is enabled, show it (even if 0 to indicate feature is active)
    final showBonus = bonusEnabled;

    if (showBonus) {
      // Format: / 2,000 + 200 🏋️ cal (using fitness_center icon)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '/ ${CalorieSummaryUtils.formatNumber(calorieGoal)} ',
            style: baseStyle,
          ),
          Text(
            '+ ${CalorieSummaryUtils.formatNumber(bonusCalories)} ',
            style: baseStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.fitness_center,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.cal,
            style: baseStyle,
          ),
        ],
      );
    } else {
      // Standard format: / 2,000 cal
      return Text(
        '/ ${CalorieSummaryUtils.formatNumber(calorieGoal)} ${AppLocalizations.of(context)!.cal}',
        style: baseStyle,
      );
    }
  }

  /// Build the exercise bonus toggle button
  Widget _buildExerciseBonusToggle(HomeProvider homeProvider, Color textColor) {
    final isEnabled = homeProvider.exerciseBonusEnabled;

    return Semantics(
      button: true,
      label: 'Exercise calorie bonus toggle',
      value: isEnabled ? 'On' : 'Off',
      hint: 'Double tap to toggle exercise calorie bonus',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await homeProvider.toggleExerciseBonus();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled
                  ? textColor.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Center(
              child: Icon(
                Icons.fitness_center,
                size: 18,
                color: textColor.withValues(
                  alpha: isEnabled ? 1.0 : 0.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedProgress(double progress, bool isOverBudget, Color textColor) {
    const segmentCount = _CalorieSummaryDesign.progressBarSegments;
    final filledSegments = (progress * segmentCount).round();

    // Simple binary: red at 100%+, theme color below
    final isOverBudgetColor = progress >= 1.0;
    final filledColor = isOverBudgetColor
        ? _CalorieSummaryDesign.warningRed
        : textColor;

    // Unfilled segments: white with transparency
    final unfilledColor = Colors.white.withValues(alpha: 0.25);

    // Shadow color
    final shadowColor = filledColor.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedFilledSegments = (_progressAnimation.value * filledSegments).round();

        return Row(
          children: List.generate(segmentCount, (index) {
            final isFilled = index < animatedFilledSegments;

            return Expanded(
              child: Container(
                height: _CalorieSummaryDesign.progressBarHeight,
                margin: EdgeInsets.only(
                  right: index < segmentCount - 1 ? _CalorieSummaryDesign.progressBarGap : 0,
                ),
                decoration: BoxDecoration(
                  color: isFilled ? filledColor : unfilledColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isFilled ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 6,
                      offset: const Offset(0, 0),
                    ),
                  ] : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRemainingInfo(int remaining, Color textColor) {
    String displayValue;
    String labelText;

    if (remaining > 0) {
      displayValue = CalorieSummaryUtils.formatNumber(remaining);
      labelText = AppLocalizations.of(context)!.remainingCalories;
    } else if (remaining < 0) {
      final overAmount = remaining.abs();
      displayValue = '+${CalorieSummaryUtils.formatNumber(overAmount)}';
      labelText = AppLocalizations.of(context)!.caloriesOver;
    } else {
      displayValue = '0';
      labelText = AppLocalizations.of(context)!.remainingCalories;
    }

    return Center(
      child: Text(
        '$labelText $displayValue',
        style: TextStyle(
          fontSize: AppWidgetTheme.fontSizeML,
          fontWeight: FontWeight.w500,
          color: textColor,
          shadows: AppWidgetTheme.textShadows,
        ),
      ),
    );
  }
}