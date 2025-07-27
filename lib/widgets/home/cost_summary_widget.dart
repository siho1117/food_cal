// lib/widgets/home/cost_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class CostSummaryWidget extends StatefulWidget {
  const CostSummaryWidget({Key? key}) : super(key: key);

  @override
  State<CostSummaryWidget> createState() => _CostSummaryWidgetState();
}

class _CostSummaryWidgetState extends State<CostSummaryWidget> 
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
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Create animations
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _countAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOutQuart,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Start animations after everything is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAnimations();
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _countController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _slideController.forward();
  }

  // Restart animations when data refreshes
  void _restartAnimations() {
    if (mounted) {
      _progressController.reset();
      _countController.reset();
      _slideController.reset();
      _startAnimations();
    }
  }

  void _checkForRefresh(double totalCost, double budget, double remaining) {
    final currentHash = '$totalCost-$budget-$remaining';
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
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          );
        }

        // Get cost data from provider
        final totalCost = homeProvider.totalFoodCost;
        final dailyBudget = homeProvider.dailyFoodBudget;
        final remaining = homeProvider.remainingBudget;
        final isOverBudget = homeProvider.isOverBudget;
        
        // Check for data changes and restart animations if needed
        _checkForRefresh(totalCost, dailyBudget, remaining);
        
        // Calculate progress
        final budgetProgress = homeProvider.budgetProgress;
        final progressPercentage = (budgetProgress * 100).round();
        
        // Determine status and colors
        final statusData = _getStatusData(budgetProgress, isOverBudget);
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with money emoji and status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '💰',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Daily Food Budget',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStatusBadge(statusData, remaining, isOverBudget),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Split design: Amount (left) + Progress (right)
              Row(
                children: [
                  // Left side - Cost amount
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Animated cost display
                          AnimatedBuilder(
                            animation: _countAnimation,
                            builder: (context, child) {
                              final animatedCost = (totalCost * _countAnimation.value);
                              
                              return Text(
                                '\$${animatedCost.toStringAsFixed(2)}',
                                style: AppTextStyles.getNumericStyle().copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                  height: 1.0,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'spent today',
                            style: AppTextStyles.getBodyStyle().copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right side - Progress and budget info
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress bar
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Progress bar
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      widthFactor: budgetProgress * _progressAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: statusData['color'],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Percentage and budget info
                                  AnimatedBuilder(
                                    animation: _countAnimation,
                                    builder: (context, child) {
                                      final animatedPercentage = (progressPercentage * _countAnimation.value).round();
                                      final animatedBudget = (dailyBudget * _countAnimation.value);
                                      
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$animatedPercentage% of \$${animatedBudget.toStringAsFixed(0)} budget',
                                            style: AppTextStyles.getBodyStyle().copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status message with fade in
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  statusData['message'],
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusData['color'],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusData, double remaining, bool isOverBudget) {
    final badgeText = isOverBudget 
        ? '\$${(remaining * -1).toStringAsFixed(2)} over'
        : '\$${remaining.toStringAsFixed(2)} left';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusData['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverBudget ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: statusData['color'],
          ),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statusData['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData(double progress, bool isOverBudget) {
    if (isOverBudget) {
      return {
        'color': Colors.red[600]!,
        'message': '🚨 Over your daily budget!',
      };
    }
    
    if (progress >= 0.9) {
      return {
        'color': Colors.orange[600]!,
        'message': '⚠️ Approaching your budget limit!',
      };
    }
    
    if (progress >= 0.7) {
      return {
        'color': Colors.green[600]!,
        'message': '📊 On track with your budget!',
      };
    }
    
    if (progress >= 0.4) {
      return {
        'color': Colors.green[600]!,
        'message': '💡 Great spending discipline!',
      };
    }
    
    return {
      'color': Colors.green[600]!,
      'message': '🎯 Excellent budget management!',
    };
  }
}