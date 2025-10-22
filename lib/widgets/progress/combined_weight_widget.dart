// lib/widgets/progress/combined_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/typography.dart';
import '../../providers/progress_data.dart';

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
  late AnimationController _segmentController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _segmentAnimations;

  static const int totalSegments = 10;

  @override
  void initState() {
    super.initState();
    
    _segmentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Create staggered animations for each segment
    _segmentAnimations = List.generate(totalSegments, (index) {
      final start = (index / totalSegments) * 0.6;
      final end = start + 0.4;
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _segmentController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
    
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
            _segmentController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _segmentController.dispose();
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

  int _getFilledSegments(double progressPercentage) {
    return (progressPercentage / 100 * totalSegments).round();
  }

  Color _getProgressColor(double progressPercentage) {
    if (progressPercentage >= 95) return const Color(0xFF10B981);
    if (progressPercentage >= 85) return const Color(0xFF22C55E);
    if (progressPercentage >= 70) return const Color(0xFF84CC16);
    if (progressPercentage >= 50) return const Color(0xFFF59E0B);
    if (progressPercentage >= 30) return const Color(0xFF3B82F6);
    return const Color(0xFF6366F1);
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
      return 'Goal reached! 🏆';
    } else if (difference <= 0.1) {
      return 'At target!';
    } else {
      return '${displayDifference.toStringAsFixed(1)} $unit to go';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressData>(
      builder: (context, progressData, child) {
        final currentWeight = widget.currentWeight;
        const targetWeight = null;
        final progressPercentage = _calculateProgress(currentWeight, targetWeight);
        final filledSegments = _getFilledSegments(progressPercentage);
        final progressColor = _getProgressColor(progressPercentage);
        final remainingText = _getRemainingText(currentWeight, targetWeight, progressPercentage);

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight Progress',
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          targetWeight != null ? 'Tracking to goal' : 'Set your target',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildMinimalButton(
                          icon: Icons.add,
                          color: AppTheme.primaryBlue,
                          isColored: true,
                          onPressed: _showWeightInputDialog,
                        ),
                        const SizedBox(width: 8),
                        _buildMinimalButton(
                          icon: Icons.flag_outlined,
                          color: AppTheme.accentColor,
                          isColored: targetWeight != null,
                          onPressed: _showTargetWeightDialog,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AnimatedBuilder(
                    animation: _segmentController,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(totalSegments, (index) {
                          final isFilled = index < filledSegments;
                          final segmentColor = isFilled 
                              ? progressColor.withValues(alpha: _segmentAnimations[index].value)
                              : Colors.grey[200];
                          
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: index == 0 || index == totalSegments - 1 ? 0 : 0.5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: segmentColor,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Weight Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weight Display
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _formatWeight(currentWeight),
                            style: AppTypography.labelLarge.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (targetWeight != null) ...[
                            TextSpan(
                              text: ' → ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: _formatWeight(targetWeight),
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Progress Info
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${progressPercentage.toInt()}%',
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: progressColor,
                            ),
                          ),
                          TextSpan(
                            text: ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          TextSpan(
                            text: remainingText,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalButton({
    required IconData icon,
    required Color color,
    required bool isColored,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isColored ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: isColored ? null : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isColored ? Colors.white : color,
        ),
      ),
    );
  }

  void _showWeightInputDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Weight (${widget.isMetric ? 'kg' : 'lbs'})',
                border: const OutlineInputBorder(),
                suffixText: widget.isMetric ? 'kg' : 'lbs',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final weight = double.tryParse(text);
                if (weight != null && weight > 0) {
                  widget.onWeightEntered(weight, widget.isMetric);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Weight logged: ${weight.toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTargetWeightDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Target Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Target Weight (${widget.isMetric ? 'kg' : 'lbs'})',
                border: const OutlineInputBorder(),
                suffixText: widget.isMetric ? 'kg' : 'lbs',
                helperText: 'Set your goal weight to track progress',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final weight = double.tryParse(text);
                if (weight != null && weight > 0) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Target weight set: ${weight.toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Set Target'),
          ),
        ],
      ),
    );
  }
}