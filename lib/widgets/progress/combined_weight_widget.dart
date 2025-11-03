// lib/widgets/progress/combined_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/progress_data.dart';
import '../../providers/theme_provider.dart';

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
    final currentTarget = progressData.targetWeight;
    
    final TextEditingController weightController = TextEditingController();
    final TextEditingController targetController = TextEditingController(
      text: currentTarget?.toStringAsFixed(1) ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: const Text(
          'Update Weight',
          style: AppDialogTheme.titleStyle,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weight Section
              _buildSectionLabel('Current Weight'),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: AppDialogTheme.inputTextStyle,
                decoration: AppDialogTheme.inputDecoration(
                  hintText: widget.isMetric ? 'kg' : 'lbs',
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Target Weight Section
              _buildSectionLabel('Target Weight'),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppDialogTheme.inputTextStyle,
                decoration: AppDialogTheme.inputDecoration(
                  hintText: widget.isMetric ? 'kg' : 'lbs',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppDialogTheme.cancelButtonStyle,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppDialogTheme.buttonGap),
          FilledButton(
            onPressed: () async {
              bool hasUpdates = false;
              
              // Update current weight if entered
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                widget.onWeightEntered(weight, widget.isMetric);
                hasUpdates = true;
              }
              
              // Update target weight if entered
              final targetWeight = double.tryParse(targetController.text);
              if (targetWeight != null && targetWeight > 0) {
                // Convert to kg if user is using lbs
                final weightInKg = widget.isMetric 
                    ? targetWeight 
                    : targetWeight / 2.20462;
                
                await progressData.updateTargetWeight(weightInKg);
                hasUpdates = true;
              }
              
              if (context.mounted) {
                Navigator.of(context).pop();
                
                // Show success message only if something was updated
                if (hasUpdates) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weight updated successfully'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: AppDialogTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Helper method to build section labels matching Edit Food Item style
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF374151),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}