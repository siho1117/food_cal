// lib/widgets/home/calorie_summary_widget.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/home_statistics_calculator.dart';

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
      final currentWeight = (await _userRepository.getLatestWeightEntry())?.weight;

      // Load food entries
      final entriesByMeal = await _foodRepository.getFoodEntriesByMeal(widget.date);

      // Use the HomeStatisticsCalculator for all calculations
      
      // Calculate calorie goal
      final calorieGoal = HomeStatisticsCalculator.calculateCalorieGoal(
        userProfile: userProfile,
        currentWeight: currentWeight,
      );
      
      // Calculate total calories consumed
      final totalCalories = HomeStatisticsCalculator.calculateTotalCalories(entriesByMeal);

      if (mounted) {
        setState(() {
          _totalCalories = totalCalories;
          _calorieGoal = calorieGoal;
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
      return Container(
        height: 160, // Reduced height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate calorie progress percentage
    final calorieProgress = (_totalCalories / _calorieGoal).clamp(0.0, 1.0);
    final caloriesRemaining = _calorieGoal - _totalCalories;
    final isOverBudget = caloriesRemaining < 0;
    final expectedPercentage = HomeStatisticsCalculator.calculateExpectedDailyPercentage();
    
    // Determine status color based on progress
    Color statusColor;
    if (isOverBudget) {
      statusColor = Colors.red[400]!;
    } else if (calorieProgress > expectedPercentage * 1.2) {
      statusColor = Colors.orange[400]!; // Ahead of expected pace
    } else if (calorieProgress < expectedPercentage * 0.7) {
      statusColor = Colors.green[400]!; // Well below expected pace
    } else {
      statusColor = AppTheme.primaryBlue; // On track
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          stops: const [0.7, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with very light background
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10), // Reduced padding
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.02), // Very light
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_rounded, // Pie chart icon
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Calories',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.primaryBlue.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: _loadData,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Calorie counts and progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main calorie display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Current calories
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$_totalCalories',
                            style: AppTextStyles.getNumericStyle().copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              height: 0.9,
                            ),
                          ),
                          TextSpan(
                            text: ' / $_calorieGoal',
                            style: AppTextStyles.getNumericStyle().copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Remaining calories
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOverBudget
                            ? Colors.red[50]
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOverBudget
                              ? Colors.red[200]!
                              : Colors.green[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isOverBudget
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: isOverBudget
                                ? Colors.red[400]
                                : Colors.green[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOverBudget
                                ? '${-caloriesRemaining} over'
                                : '$caloriesRemaining left',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isOverBudget
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Calorie goal description
                Row(
                  children: [
                    Text(
                      'of daily calorie goal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(calorieProgress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
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
                      expectedPercentage,
                      isOverBudget,
                      statusColor,
                    );
                  },
                ),
                
                const SizedBox(height: 6), // Reduced spacing
                
                // Meal markers
                _buildMealMarkers(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProgressBar(
    double progress, 
    double expectedProgress,
    bool isOverLimit, 
    Color statusColor
  ) {
    final barHeight = 12.0;
    final trackColor = Colors.grey[200]!;
    final maxWidth = MediaQuery.of(context).size.width - 40; // Adjust for padding
    
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
        
        // Expected progress marker
        Positioned(
          left: maxWidth * expectedProgress - 1,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        
        // Progress fill with gradient
        Container(
          height: barHeight,
          width: progress < 1.0 ? maxWidth * progress : maxWidth, // Ensure it doesn't exceed maxWidth
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.7),
                statusColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.3),
                blurRadius: 3,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        
        // Progress thumb - position adjusted to handle 100% case correctly
        Positioned(
          left: progress < 0.97 ? (maxWidth * progress) - 6 : maxWidth - 6, // Adjust position near 100%
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
                  color: statusColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMealMarkers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMealMarker('Breakfast', 0.0),
        _buildMealMarker('Lunch', 0.33),
        _buildMealMarker('Dinner', 0.67),
        _buildMealMarker('Snacks', 1.0),
      ],
    );
  }
  
  Widget _buildMealMarker(String label, double alignment) {
    return Container(
      width: 60,
      padding: const EdgeInsets.only(top: 2),
      alignment: alignment == 0.0 
          ? Alignment.centerLeft
          : alignment == 1.0 
              ? Alignment.centerRight 
              : Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}