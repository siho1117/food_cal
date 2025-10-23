// lib/widgets/home/calorie_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
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
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    _countAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    
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

  void _checkForRefresh(int totalCalories, int calorieGoal) {
    final currentHash = '$totalCalories-$calorieGoal';
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
        if (homeProvider.isLoading) {
          return _buildLoadingState();
        }

        final totalCalories = homeProvider.totalCalories;
        final calorieGoal = homeProvider.calorieGoal;
        
        // Calculate remaining calories directly here
        final remaining = calorieGoal - totalCalories;
        final isOverBudget = remaining < 0;
        
        _checkForRefresh(totalCalories, calorieGoal);
        
        final calorieProgress = (totalCalories / calorieGoal).clamp(0.0, 1.0);
        
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildTransparentCard(
              totalCalories: totalCalories,
              calorieGoal: calorieGoal,
              remaining: remaining,
              isOverBudget: isOverBudget,
              calorieProgress: calorieProgress,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 4.0, // ✅ Doubled thickness
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white.withOpacity(0.9),
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildTransparentCard({
    required int totalCalories,
    required int calorieGoal,
    required int remaining,
    required bool isOverBudget,
    required double calorieProgress,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 4.0, // ✅ Doubled from 2.0 to 4.0
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          children: [
            // Title
            const Text(
              'Calories Today',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main calorie number
            _buildMainDisplay(totalCalories, calorieGoal),
            
            const SizedBox(height: 24),
            
            // Progress bar (red when over budget)
            _buildSegmentedProgress(calorieProgress, isOverBudget),
            
            const SizedBox(height: 14),
            
            // Remaining calories
            _buildRemainingInfo(remaining),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDisplay(int totalCalories, int calorieGoal) {
    return Center(
      child: Column(
        children: [
          // Animated calorie number
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              final animatedValue = (_countAnimation.value * totalCalories).round();
              
              return Text(
                _formatNumber(animatedValue),
                style: const TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Goal line
          Text(
            '/ ${_formatNumber(calorieGoal)} cal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgress(double progress, bool isOverBudget) {
    const segmentCount = 10;
    final filledSegments = (progress * segmentCount).round();
    
    // ✅ Soft red when over budget, white when normal
    final progressColor = isOverBudget 
        ? const Color(0xFFFF6B6B) // Soft red
        : Colors.white;
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedFilledSegments = (_progressAnimation.value * filledSegments).round();
        
        return Row(
          children: List.generate(segmentCount, (index) {
            final isFilled = index < animatedFilledSegments;
            
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(
                  right: index < segmentCount - 1 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: isFilled 
                      ? progressColor.withOpacity(0.9) // ✅ Use red or white
                      : Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isFilled ? [
                    BoxShadow(
                      color: progressColor.withOpacity(0.3), // ✅ Glow matches color
                      blurRadius: 6,
                      offset: const Offset(0, 0),
                    ),
                  ] : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRemainingInfo(int remaining) {
    // Simple logic:
    // remaining = goal - consumed
    // If remaining > 0: still have calories left (e.g., "Remaining calories 968")
    // If remaining < 0: over budget (e.g., "Remaining calories +172")
    // If remaining = 0: exactly at goal (e.g., "Remaining calories 0")
    
    String displayText;
    
    if (remaining > 0) {
      // Still have calories remaining
      displayText = 'Remaining calories ${_formatNumber(remaining)}';
    } else if (remaining < 0) {
      // Over budget - show positive number with +
      final overAmount = remaining.abs();
      displayText = 'Remaining calories +${_formatNumber(overAmount)}';
    } else {
      // Exactly at goal
      displayText = 'Remaining calories 0';
    }
    
    return Center(
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      final k = number / 1000;
      if (k % 1 == 0) {
        return '${k.toInt()}k';
      }
      return '${k.toStringAsFixed(1)}k';
    }
    
    final str = number.toString();
    if (str.length <= 3) return str;
    
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}