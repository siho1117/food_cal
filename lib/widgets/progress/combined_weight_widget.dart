// lib/widgets/progress/combined_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme_design.dart';
import '../../providers/progress_data.dart';
import '../../providers/theme_provider.dart';
import 'weight_edit_dialog.dart';

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

class _CombinedWeightWidgetState extends State<CombinedWeightWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _progressController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateProgress(double? current, double? target) {
    if (current == null || target == null || target <= 0) return 0.0;
    
    final difference = (current - target).abs();
    final maxWeight = math.max(current, target);
    final progress = (1 - difference / maxWeight) * 100;
    
    return progress.clamp(0.0, 100.0);
  }

  String _formatWeight(double? weight) {
    if (weight == null) {
      return widget.isMetric ? '-- kg' : '-- lbs';
    }
    
    final displayWeight = widget.isMetric ? weight : weight * 2.20462;
    final unit = widget.isMetric ? 'kg' : 'lbs';
    
    return '${displayWeight.toStringAsFixed(1)} $unit';
  }

  String _getRemainingText(double? current, double? target, double progressPercentage) {
    if (current == null || target == null) return 'Set target';
    
    final difference = (current - target).abs();
    final unit = widget.isMetric ? 'kg' : 'lbs';
    final displayDifference = widget.isMetric ? difference : difference * 2.20462;
    
    if (progressPercentage >= 99.5) {
      return 'Goal reached!';
    } else if (difference <= 0.1) {
      return 'At target!';
    } else {
      return '${displayDifference.toStringAsFixed(1)} $unit left';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProgressData, ThemeProvider>(
      builder: (context, progressData, themeProvider, child) {
        final currentWeight = widget.currentWeight;
        // ✅ UPDATED: Read target weight from ProgressData provider
        final targetWeight = progressData.targetWeight;
        final progressPercentage = _calculateProgress(currentWeight, targetWeight);
        final remainingText = _getRemainingText(currentWeight, targetWeight, progressPercentage);
        
        // Get theme-adaptive colors
        final borderColor = AppColors.getBorderColorForTheme(
          themeProvider.selectedGradient,
          AppEffects.borderOpacity,
        );
        final textColor = AppColors.getTextColorForTheme(
          themeProvider.selectedGradient,
        );
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _showWeightDialog,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                  width: 4,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight',
                          style: TextStyle(
                            fontSize: 17,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            shadows: AppEffects.textShadows,
                          ),
                        ),
                        // Edit button
                        GestureDetector(
                          onTap: _showWeightDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 18),
                    
                    // Weight Display
                    Center(
                      child: Column(
                        children: [
                          Text(
                            currentWeight?.toStringAsFixed(1) ?? '--',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              height: 1.0,
                              shadows: AppEffects.textShadows,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (targetWeight != null)
                            Text(
                              '/ ${_formatWeight(targetWeight)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(alpha: 0.7),
                                shadows: AppEffects.textShadows,
                              ),
                            )
                          else
                            Text(
                              widget.isMetric ? 'kg' : 'lbs',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(alpha: 0.7),
                                shadows: AppEffects.textShadows,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress Bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_progressAnimation.value * progressPercentage / 100).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Progress Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${progressPercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                            shadows: AppEffects.textShadows,
                          ),
                        ),
                        Text(
                          remainingText,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                            shadows: AppEffects.textShadows,
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
      },
    );
  }

  void _showWeightDialog() {
    final progressData = Provider.of<ProgressData>(context, listen: false);

    showWeightEditDialog(
      context: context,
      initialWeight: widget.currentWeight ?? 70.0,
      isMetric: widget.isMetric,
      targetWeight: progressData.targetWeight,
      onAddWeight: (weight, isMetric) async {
        // Add new weight entry
        widget.onWeightEntered(weight, isMetric);

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
        // Save target weight
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