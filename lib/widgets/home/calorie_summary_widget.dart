// lib/widgets/home/calorie_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/typography.dart';
import '../../providers/home_provider.dart';

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

  // Track previous values for refresh detection
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
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
    
    // Create animations
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _countAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
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

  void _checkForRefresh(int totalCalories, int calorieGoal, int caloriesRemaining) {
    final currentHash = '$totalCalories-$calorieGoal-$caloriesRemaining';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show loading state if data is still loading
        if (homeProvider.isLoading) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            ),
          );
        }

        // Get data from provider
        final totalCalories = homeProvider.totalCalories;
        final calorieGoal = homeProvider.calorieGoal;
        final caloriesRemaining = homeProvider.caloriesRemaining;
        final isOverBudget = homeProvider.isOverBudget;
        final expectedPercentage = homeProvider.expectedDailyPercentage;
        
        // Check for data changes and restart animations if needed
        _checkForRefresh(totalCalories, calorieGoal, caloriesRemaining);
        
        // Calculate progress
        final calorieProgress = (totalCalories / calorieGoal).clamp(0.0, 1.0);
        final progressPercentage = (calorieProgress * 100).round();
        
        // Determine status and colors
        final statusData = _getStatusData(calorieProgress, expectedPercentage, isOverBudget);
        
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            'Calories Today',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (statusData['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$progressPercentage%',
                          style: AppTypography.dataSmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusData['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Main calorie display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Current calories (animated)
                      AnimatedBuilder(
                        animation: _countAnimation,
                        builder: (context, child) {
                          final animatedValue = (_countAnimation.value * totalCalories).round();
                          return Text(
                            animatedValue.toString(),
                            style: AppTypography.dataLarge.copyWith(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBlue,
                              height: 1,
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Goal indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '/ $calorieGoal cal',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: calorieProgress * _progressAnimation.value,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  (statusData['color'] as Color).withValues(alpha: 0.8),
                                  statusData['color'] as Color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Remaining calories info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOverBudget ? 'Over by:' : 'Remaining:',
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${caloriesRemaining.abs()} cal',
                        style: AppTypography.dataSmall.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red[600] : Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusData(double progress, double expectedPercentage, bool isOverBudget) {
    if (isOverBudget) {
      return {
        'status': 'Over budget',
        'color': Colors.red[600]!,
      };
    }
    
    if (progress >= 0.9) {
      return {
        'status': 'Almost there!',
        'color': Colors.orange[600]!,
      };
    }
    
    if (progress >= 0.7) {
      return {
        'status': 'Good progress',
        'color': Colors.blue[600]!,
      };
    }
    
    if (progress >= 0.5) {
      return {
        'status': 'On track',
        'color': Colors.green[600]!,
      };
    }
    
    return {
      'status': 'Just getting started',
      'color': Colors.grey[600]!,
    };
  }
}