// lib/widgets/exercise/exercise_log_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import 'exercise_entry_dialog.dart';

class ExerciseLogWidget extends StatefulWidget {
  final bool showHeader;
  final VoidCallback? onExerciseAdded;

  const ExerciseLogWidget({
    super.key,
    this.showHeader = true,
    this.onExerciseAdded,
  });

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;
  List<Animation<double>>? _itemAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeOutCubic,
    ));
    
    // Create staggered animations for timeline items
    _itemAnimations = List.generate(5, (index) {
      final start = index * 0.15;
      final end = start + 0.6;
      
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _fadeController != null && _animationController != null) {
        _fadeController!.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && _animationController != null) {
            _animationController!.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        if (exerciseProvider.isLoading) {
          return _buildLoadingState();
        }

        if (exerciseProvider.errorMessage != null) {
          return _buildErrorState(exerciseProvider);
        }

        // Check if animations are initialized
        if (_fadeAnimation == null || _slideAnimation == null) {
          return _buildLoadingState();
        }

        return AnimatedBuilder(
          animation: _fadeAnimation!,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation!.value),
              child: Opacity(
                opacity: _fadeAnimation!.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (widget.showHeader) _buildHeader(exerciseProvider),
                      _buildProgressHeader(exerciseProvider),
                      _buildTimelineContent(exerciseProvider),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(ExerciseProvider exerciseProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF8FAFC),
            const Color(0xFFE2E8F0),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: const Color(0xFF667EEA),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Progress Timeline',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _buildAddButton(exerciseProvider),
        ],
      ),
    );
  }

  Widget _buildAddButton(ExerciseProvider exerciseProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showExerciseDialog(exerciseProvider),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '+ Track',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(ExerciseProvider exerciseProvider) {
    final totalBurned = exerciseProvider.totalCaloriesBurned;
    final burnGoal = exerciseProvider.dailyBurnGoal;
    final progress = burnGoal > 0 ? (totalBurned / burnGoal) : 0.0;
    final progressPercentage = (progress * 100).clamp(0, 999).round();

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Goal Progress',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatNumber(totalBurned),
                          style: AppTextStyles.getNumericStyle().copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${_formatNumber(burnGoal)} cal',
                          style: AppTextStyles.getNumericStyle().copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(60, 60),
              painter: CircularProgressPainter(
                progress: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                progressColor: Colors.white,
                strokeWidth: 3,
              ),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: Text(
                    '$progressPercentage%',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineContent(ExerciseProvider exerciseProvider) {
    final exercises = exerciseProvider.exerciseEntries;

    if (exercises.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Timeline line
          Positioned(
            left: 12,
            top: 0,
            bottom: 20,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF667EEA),
                    const Color(0xFF94A3B8),
                    const Color(0xFFE2E8F0),
                  ],
                ),
              ),
            ),
          ),
          // Timeline items
          Column(
            children: exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              
              // Check if animations are available
              if (_itemAnimations == null || _itemAnimations!.isEmpty) {
                return _buildTimelineItem(exercise, index);
              }
              
              return AnimatedBuilder(
                animation: _itemAnimations![math.min(index, _itemAnimations!.length - 1)],
                builder: (context, child) {
                  final animIndex = math.min(index, _itemAnimations!.length - 1);
                  return Transform.translate(
                    offset: Offset(
                      30 * (1 - _itemAnimations![animIndex].value),
                      0,
                    ),
                    child: Opacity(
                      opacity: _itemAnimations![animIndex].value,
                      child: _buildTimelineItem(exercise, index),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ExerciseEntry exercise, int index) {
    final accentColor = _getExerciseAccentColor(exercise, index);
    final statusInfo = _getExerciseStatus(exercise);

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Left accent border
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          // Timeline dot
          Positioned(
            left: -36,
            top: 20,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE2E8F0),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTime(exercise.timestamp),
                            style: AppTextStyles.getBodyStyle().copyWith(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (statusInfo['status'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              statusInfo['status']!,
                              style: AppTextStyles.getBodyStyle().copyWith(
                                fontSize: 10,
                                color: statusInfo['color'],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${exercise.caloriesBurned} cal',
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.name,
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.duration} min • ${exercise.intensity} • ${exercise.type}',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 32,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises today',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your workouts to track your progress',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showExerciseDialog(
                  Provider.of<ExerciseProvider>(context, listen: false),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Log Your First Exercise',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
        ),
      ),
    );
  }

  Widget _buildErrorState(ExerciseProvider exerciseProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Exercises',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exerciseProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: AppTextStyles.getBodyStyle().copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => exerciseProvider.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getExerciseAccentColor(ExerciseEntry exercise, int index) {
    // Rotate through accent colors based on exercise type and index
    switch (exercise.type.toLowerCase()) {
      case 'cardio':
        return const Color(0xFF667EEA); // Blue
      case 'strength':
        return const Color(0xFF10B981); // Green
      case 'flexibility':
        return const Color(0xFFF59E0B); // Amber
      default:
        // Fallback to index-based rotation
        final colors = [
          const Color(0xFF667EEA),
          const Color(0xFF10B981),
          const Color(0xFFF59E0B),
        ];
        return colors[index % colors.length];
    }
  }

  Map<String, dynamic> _getExerciseStatus(ExerciseEntry exercise) {
    // Determine status based on calories burned
    if (exercise.caloriesBurned >= 300) {
      return {
        'status': 'GOAL EXCEEDED',
        'color': const Color(0xFF10B981),
      };
    } else if (exercise.caloriesBurned >= 200) {
      return {
        'status': 'BONUS WORKOUT',
        'color': const Color(0xFF667EEA),
      };
    } else if (exercise.caloriesBurned >= 50) {
      return {
        'status': 'RECOVERY',
        'color': const Color(0xFFF59E0B),
      };
    }
    return {'status': null, 'color': const Color(0xFF64748B)};
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showExerciseDialog(ExerciseProvider exerciseProvider) {
    showDialog(
      context: context,
      builder: (context) => ExerciseEntryDialog(
        exerciseProvider: exerciseProvider,
        onExerciseSaved: widget.onExerciseAdded,
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CircularProgressPainter ||
        oldDelegate.progress != progress;
  }
}