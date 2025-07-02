// lib/widgets/progress/combined_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/progress_data.dart';
import './weight_input_dialog.dart';
import './target_weight_dialog.dart';

class CombinedWeightWidget extends StatefulWidget {
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightEntered;

  const CombinedWeightWidget({
    Key? key,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightEntered,
  }) : super(key: key);

  @override
  State<CombinedWeightWidget> createState() => _CombinedWeightWidgetState();
}

class _CombinedWeightWidgetState extends State<CombinedWeightWidget>
    with TickerProviderStateMixin {
  late AnimationController _timelineController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _timelineController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateRemainingPercentage(double? current, double? target) {
    if (current == null || target == null) return 0.0;
    return ((current - target).abs() / current * 100);
  }

  double _calculateProgressPercentage(double? current, double? target) {
    if (current == null || target == null) return 0.0;
    final remainingPercentage = _calculateRemainingPercentage(current, target);
    return (100 - remainingPercentage) / 100; // Convert to 0-1 scale
  }

  Color _getProgressColor(double remainingPercentage) {
    if (remainingPercentage <= 5) return Colors.green[600]!; // Very close
    if (remainingPercentage <= 10) return Colors.lightGreen[600]!; // Close
    if (remainingPercentage <= 15) return Colors.orange[500]!; // Moderate
    return AppTheme.primaryBlue; // Significant
  }

  String _formatWeight(double? weight) {
    if (weight == null) {
      return widget.isMetric ? '-- kg' : '-- lbs';
    }
    
    final displayWeight = widget.isMetric ? weight : weight * 2.20462;
    final unit = widget.isMetric ? 'kg' : 'lbs';
    
    return '${displayWeight.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressData>(
      builder: (context, progressData, child) {
        final targetWeight = progressData.userProfile?.goalWeight;
        final currentWeight = widget.currentWeight;
        
        // Calculate remaining percentage and progress
        final remainingPercentage = _calculateRemainingPercentage(currentWeight, targetWeight);
        final progressValue = _calculateProgressPercentage(currentWeight, targetWeight);
        final progressColor = _getProgressColor(remainingPercentage);
        
        String remainingText = 'Set a target weight';
        String weightToGoText = '--';
        
        if (targetWeight != null && currentWeight != null) {
          final weightDifference = (currentWeight - targetWeight).abs();
          final unit = widget.isMetric ? 'kg' : 'lbs';
          final displayDifference = widget.isMetric ? weightDifference : weightDifference * 2.20462;
          
          weightToGoText = '${displayDifference.toStringAsFixed(1)} $unit to go';
          remainingText = '${remainingPercentage.toStringAsFixed(1)}% of current weight';
        }

        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.05),
                        blurRadius: 40,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Weight Journey',
                              style: AppTextStyles.getSubHeadingStyle().copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            if (targetWeight != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: progressColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: progressColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Progress toward goal',
                                  style: AppTextStyles.getBodyStyle().copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: progressColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Timeline
                        targetWeight != null ? _buildTimeline(
                          currentWeight!,
                          targetWeight,
                          remainingPercentage,
                          progressValue,
                          progressColor,
                          weightToGoText,
                          remainingText,
                        ) : _buildEmptyState(),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildActionButton(
                                'Update Weight',
                                AppTheme.primaryBlue,
                                Icons.add_circle_outline,
                                () => _showWeightDialog(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                'Set Target',
                                Colors.green[600]!,
                                Icons.flag_outlined,
                                () => _showTargetDialog(progressData),
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
      },
    );
  }

  Widget _buildTimeline(
    double currentWeight,
    double targetWeight,
    double remainingPercentage,
    double progressValue,
    Color progressColor,
    String weightToGoText,
    String remainingText,
  ) {
    return Column(
      children: [
        // Timeline Track
        Container(
          height: 120,
          child: Stack(
            children: [
              // Background track
              Positioned(
                top: 60,
                left: 60,
                right: 60,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Progress track
              Positioned(
                top: 60,
                left: 60,
                right: 60,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: progressValue * _progressAnimation.value,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              progressColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Timeline Points
              Positioned(
                top: 0,
                left: 0,
                child: _buildTimelinePoint(
                  _formatWeight(currentWeight),
                  'Current Weight',
                  AppTheme.primaryBlue,
                  true,
                ),
              ),
              
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildTimelinePoint(
                    '${remainingPercentage.toStringAsFixed(1)}%',
                    'Remaining Goal',
                    progressColor,
                    false,
                  ),
                ),
              ),
              
              Positioned(
                top: 0,
                right: 0,
                child: _buildTimelinePoint(
                  _formatWeight(targetWeight),
                  'Target Weight',
                  Colors.green[600]!,
                  false,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Progress Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Progress',
                '${(progressValue * 100).round()}%',
                progressColor,
                Icons.trending_up,
              ),
              _buildStatItem(
                'To Goal',
                weightToGoText,
                Colors.grey[600]!,
                Icons.flag_outlined,
              ),
              _buildStatItem(
                'Remaining',
                remainingText,
                progressColor,
                Icons.percent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelinePoint(String value, String label, Color color, bool isCurrent) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isCurrent ? 1.0 : _progressAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: isCurrent ? Border.all(color: Colors.white, width: 4) : null,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color.withOpacity(0.7),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Colors.grey[500],
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set a target weight to see your journey',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeightDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WeightInputDialog(
        currentWeight: widget.currentWeight,
        isMetric: widget.isMetric,
        onWeightEntered: widget.onWeightEntered,
      ),
    );
  }

  void _showTargetDialog(ProgressData progressData) {
    if (widget.currentWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your current weight first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TargetWeightDialog(
        currentWeight: widget.currentWeight,
        currentTarget: progressData.userProfile?.goalWeight,
        isMetric: widget.isMetric,
        onTargetSet: (targetWeight) {
          // Here you would integrate with your progress data provider
          // progressData.setTargetWeight(targetWeight);
        },
      ),
    );
  }
}