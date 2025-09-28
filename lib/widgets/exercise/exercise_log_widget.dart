// lib/widgets/exercise/exercise_log_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE2E8F0),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFF667EEA),
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
    final progress = burnGoal > 0 ? (totalBurned / burnGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories Burned',
                      style: AppTextStyles.getBodyStyle().copyWith(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalBurned / $burnGoal',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: progress,
                    backgroundColor: const Color(0xFFE2E8F0),
                    progressColor: const Color(0xFF667EEA),
                    strokeWidth: 6,
                  ),
                  child: Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.getBodyStyle().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF667EEA),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineContent(ExerciseProvider exerciseProvider) {
    if (exerciseProvider.exerciseEntries.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildTimeline(exerciseProvider),
        // ADD EXERCISE BUTTON - This is the key addition!
        _buildAddExerciseButtonWhenExercisesExist(exerciseProvider),
      ],
    );
  }

  Widget _buildTimeline(ExerciseProvider exerciseProvider) {
    final exercises = exerciseProvider.exerciseEntries;
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final animation = _itemAnimations![math.min(index, _itemAnimations!.length - 1)];
        
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - animation.value) * 30),
              child: Opacity(
                opacity: animation.value,
                child: _buildTimelineItem(exercise, index == exercises.length - 1),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(ExerciseEntry exercise, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF667EEA),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: const Color(0xFFE2E8F0),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildExerciseCard(exercise),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseEntry exercise) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF667EEA),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  '${exercise.duration} min • ${exercise.intensity} • ${exercise.caloriesBurned} cal',
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

  // NEW METHOD: Add Exercise Button for when exercises exist
  Widget _buildAddExerciseButtonWhenExercisesExist(ExerciseProvider exerciseProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF667EEA), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showExerciseDialog(exerciseProvider),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add,
                    color: Color(0xFF667EEA),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Another Exercise',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667EEA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exerciseProvider.errorMessage ?? 'Something went wrong',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => exerciseProvider.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
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