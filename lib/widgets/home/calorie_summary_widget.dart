// lib/widgets/home/calorie_summary_widget.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/repositories/user_repository.dart';

class CalorieSummaryWidget extends StatefulWidget {
  final DateTime date;

  const CalorieSummaryWidget({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  State<CalorieSummaryWidget> createState() => _CalorieSummaryWidgetState();
}

class _CalorieSummaryWidgetState extends State<CalorieSummaryWidget> with SingleTickerProviderStateMixin {
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  bool _isLoading = true;
  int _totalCalories = 0;
  int _calorieGoal = 2000; // Default value

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
  void didUpdateWidget(CalorieSummaryWidget oldWidget) {
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

      // Calculate total calories
      int calories = 0;

      // Process all meals
      for (var mealItems in entriesByMeal.values) {
        for (var item in mealItems) {
          calories += (item.calories * item.servingSize).round();
        }
      }

      if (mounted) {
        setState(() {
          _totalCalories = calories;
          _isLoading = false;
          
          // Reset animation controller and start animation
          _animationController.reset();
          _animationController.forward();
        });
      }
    } catch (e) {
      print('Error loading calorie summary: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
                'Calorie Summary',
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
}