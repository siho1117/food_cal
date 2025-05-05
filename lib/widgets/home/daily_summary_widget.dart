// lib/widgets/home/daily_summary_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/repositories/user_repository.dart';

class DailySummaryWidget extends StatefulWidget {
  final DateTime date;

  const DailySummaryWidget({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  State<DailySummaryWidget> createState() => _DailySummaryWidgetState();
}

class _DailySummaryWidgetState extends State<DailySummaryWidget> with SingleTickerProviderStateMixin {
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  bool _isLoading = true;
  int _totalCalories = 0;
  int _calorieGoal = 2000; // Default value
  Map<String, double> _macros = {
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };

  @override
  void initState() {
    super.initState();
    
    // Create animation controller for progress animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Initialize the animation properly
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DailySummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Load user profile to get calorie goal
      final userProfile = await _userRepository.getUserProfile();
      final currentWeight =
          (await _userRepository.getLatestWeightEntry())?.weight;

      // Calculate calorie goal if we have enough data
      if (userProfile != null &&
          currentWeight != null &&
          userProfile.height != null &&
          userProfile.age != null &&
          userProfile.gender != null &&
          userProfile.activityLevel != null) {
        // Calculate BMR
        double? bmr;
        if (userProfile.gender == 'Male') {
          bmr = (10 * currentWeight) +
              (6.25 * userProfile.height!) -
              (5 * userProfile.age!) +
              5;
        } else if (userProfile.gender == 'Female') {
          bmr = (10 * currentWeight) +
              (6.25 * userProfile.height!) -
              (5 * userProfile.age!) -
              161;
        } else {
          // Average of male and female formulas
          final maleBMR = (10 * currentWeight) +
              (6.25 * userProfile.height!) -
              (5 * userProfile.age!) +
              5;
          final femaleBMR = (10 * currentWeight) +
              (6.25 * userProfile.height!) -
              (5 * userProfile.age!) -
              161;
          bmr = (maleBMR + femaleBMR) / 2;
        }

        // Calculate TDEE based on activity level
        if (bmr != null) {
          final tdee = bmr * userProfile.activityLevel!;

          // Adjust for weight goal if available
          if (userProfile.monthlyWeightGoal != null) {
            // Calculate daily calorie adjustment
            final dailyWeightChangeKg = userProfile.monthlyWeightGoal! / 30;
            final calorieAdjustment =
                dailyWeightChangeKg * 7700; // ~7700 calories per kg

            // Set calorie goal with adjustment
            _calorieGoal = (tdee + calorieAdjustment).round();

            // Ensure minimum safe calories (90% of BMR)
            final minimumCalories = (bmr * 0.9).round();
            if (_calorieGoal < minimumCalories) {
              _calorieGoal = minimumCalories;
            }
          } else {
            // No weight goal, just use TDEE
            _calorieGoal = tdee.round();
          }
        }
      }

      // Load food entries
      final entriesByMeal =
          await _foodRepository.getFoodEntriesByMeal(widget.date);

      // Calculate totals
      int calories = 0;
      double protein = 0;
      double carbs = 0;
      double fat = 0;

      // Process all meals
      for (var mealItems in entriesByMeal.values) {
        for (var item in mealItems) {
          calories += (item.calories * item.servingSize).round();
          protein += item.proteins * item.servingSize;
          carbs += item.carbs * item.servingSize;
          fat += item.fats * item.servingSize;
        }
      }

      if (mounted) {
        setState(() {
          _totalCalories = calories;
          _macros = {
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
          };
          _isLoading = false;
          
          // Reset animation controller and start animation
          _animationController.reset();
          _animationController.forward();
        });
      }
    } catch (e) {
      print('Error loading daily summary: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Calculate macro percentages
  Map<String, int> _calculateMacroPercentages() {
    final total = _macros['protein']! + _macros['carbs']! + _macros['fat']!;

    if (total <= 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }

    return {
      'protein': ((_macros['protein']! / total) * 100).round(),
      'carbs': ((_macros['carbs']! / total) * 100).round(),
      'fat': ((_macros['fat']! / total) * 100).round(),
    };
  }

  // Calculate calorie macro breakdown in grams
  Map<String, String> _calculateMacroGrams() {
    // Updated to remove decimal places
    return {
      'protein': _macros['protein']!.round().toString(),
      'carbs': _macros['carbs']!.round().toString(),
      'fat': _macros['fat']!.round().toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Calculate percentages
    final macroPercentages = _calculateMacroPercentages();
    final macroGrams = _calculateMacroGrams();

    // Calculate calorie progress percentage
    final calorieProgress = (_totalCalories / _calorieGoal).clamp(0.0, 1.0);
    final caloriesRemaining = _calorieGoal - _totalCalories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
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
              Text(
                'Today\'s Summary',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                color: AppTheme.primaryBlue,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Calorie display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_totalCalories',
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ $_calorieGoal cal',
                  style: AppTextStyles.getNumericStyle().copyWith(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                caloriesRemaining > 0
                    ? '${caloriesRemaining} cal left'
                    : '${-caloriesRemaining} cal over',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontWeight: FontWeight.w500,
                  color: caloriesRemaining > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enhanced Calorie Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return _buildEnhancedProgressBar(
                calorieProgress * _progressAnimation.value,
                calorieProgress >= 1.0,
              );
            },
          ),

          const SizedBox(height: 24),

          // Macro breakdown
          Text(
            'Macronutrients',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          // Macro Circular Visualization
          AspectRatio(
            aspectRatio: 1.0,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return _buildMacroCircularChart(
                  macroPercentages: macroPercentages,
                  animationValue: _progressAnimation.value,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Macro legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroLegendItem(
                'Protein',
                macroGrams['protein']!,
                macroPercentages['protein']!,
                AppTheme.coralAccent,
              ),
              _buildMacroLegendItem(
                'Carbs',
                macroGrams['carbs']!,
                macroPercentages['carbs']!,
                AppTheme.goldAccent,
              ),
              _buildMacroLegendItem(
                'Fat',
                macroGrams['fat']!,
                macroPercentages['fat']!,
                AppTheme.accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProgressBar(double progress, bool isOverLimit) {
    final barHeight = 12.0;
    final trackColor = Colors.grey[200]!;
    
    // Determine progress color based on how close to the goal
    Color progressColor;
    if (isOverLimit) {
      progressColor = Colors.red;
    } else if (progress > 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppTheme.primaryBlue;
    }
    
    return Stack(
      children: [
        // Track (background)
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
        ),
        
        // Progress fill with gradient
        Container(
          height: barHeight,
          width: MediaQuery.of(context).size.width * progress * 0.8, // Adjust for padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                progressColor.withOpacity(0.7),
                progressColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: progressColor.withOpacity(0.3),
                blurRadius: 3,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        
        // Markers along the bar
        ...List.generate(5, (index) {
          final position = (index + 1) / 5;
          return Positioned(
            left: MediaQuery.of(context).size.width * position * 0.8 - 1.5,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 1,
                height: 6,
                color: trackColor.withOpacity(0.8),
              ),
            ),
          );
        }),
        
        // Current progress indicator
        Positioned(
          left: (MediaQuery.of(context).size.width * progress * 0.8) - 6,
          top: 0,
          bottom: 0,
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: progressColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withOpacity(0.3),
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCircularChart({
    required Map<String, int> macroPercentages,
    required double animationValue,
  }) {
    return CustomPaint(
      painter: MacroCircularChartPainter(
        proteinPercentage: macroPercentages['protein']! / 100 * animationValue,
        carbsPercentage: macroPercentages['carbs']! / 100 * animationValue,
        fatPercentage: macroPercentages['fat']! / 100 * animationValue,
        proteinColor: AppTheme.coralAccent,
        carbsColor: AppTheme.goldAccent,
        fatColor: AppTheme.accentColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${_totalCalories}',
              style: AppTextStyles.getNumericStyle().copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            Text(
              'calories',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLegendItem(
    String label,
    String grams,
    int percentage,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$grams g',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          '$percentage%',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class MacroCircularChartPainter extends CustomPainter {
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;

  MacroCircularChartPainter({
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Ring widths
    final outerRingWidth = radius * 0.18;
    final middleRingWidth = radius * 0.18;
    final innerRingWidth = radius * 0.18;
    
    // Ring radii
    final outerRingRadius = radius - outerRingWidth / 2;
    final middleRingRadius = radius - outerRingWidth - middleRingWidth / 2;
    final innerRingRadius = radius - outerRingWidth - middleRingWidth - innerRingWidth / 2;
    
    // Background rings (gray tracks)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: outerRingRadius,
      strokeWidth: outerRingWidth,
      percentage: 1.0,
      color: Colors.grey.withOpacity(0.1),
    );
    
    _drawRing(
      canvas: canvas,
      center: center,
      radius: middleRingRadius,
      strokeWidth: middleRingWidth,
      percentage: 1.0,
      color: Colors.grey.withOpacity(0.1),
    );
    
    _drawRing(
      canvas: canvas,
      center: center,
      radius: innerRingRadius,
      strokeWidth: innerRingWidth,
      percentage: 1.0,
      color: Colors.grey.withOpacity(0.1),
    );
    
    // Protein ring (outer)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: outerRingRadius,
      strokeWidth: outerRingWidth,
      percentage: proteinPercentage,
      color: proteinColor,
    );
    
    // Carbs ring (middle)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: middleRingRadius,
      strokeWidth: middleRingWidth,
      percentage: carbsPercentage,
      color: carbsColor,
    );
    
    // Fat ring (inner)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: innerRingRadius,
      strokeWidth: innerRingWidth,
      percentage: fatPercentage,
      color: fatColor,
    );
  }
  
  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required double percentage,
    required Color color,
  }) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    // Background track (already drawn separately)
    
    // Progress arc
    if (percentage > 0) {
      paint.color = color;
      
      // Start at the top (270 degrees) and go clockwise
      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * percentage;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MacroCircularChartPainter oldDelegate) {
    return oldDelegate.proteinPercentage != proteinPercentage ||
        oldDelegate.carbsPercentage != carbsPercentage ||
        oldDelegate.fatPercentage != fatPercentage;
  }
}