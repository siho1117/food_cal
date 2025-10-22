// lib/widgets/home/cost_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/typography.dart';
import '../../providers/home_provider.dart';
import '../dialogs/budget_edit_dialog.dart';

class CostSummaryWidget extends StatefulWidget {
  const CostSummaryWidget({super.key});

  @override
  State<CostSummaryWidget> createState() => _CostSummaryWidgetState();
}

class _CostSummaryWidgetState extends State<CostSummaryWidget> 
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _slideController;
  
  late Animation<double> _countAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Track previous values for refresh detection
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Create animations
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
    if (mounted) _slideController.forward();
  }

  // Restart animations when data refreshes
  void _restartAnimations() {
    if (mounted) {
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
    _countController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final totalCost = homeProvider.totalFoodCost;
        final dailyBudget = homeProvider.dailyFoodBudget;
        final remaining = dailyBudget - totalCost;
        final budgetProgress = totalCost / dailyBudget;
        final isOverBudget = homeProvider.isOverFoodBudget;

        // Check for data refresh
        _checkForRefresh(totalCost, dailyBudget, remaining);

        // Get dynamic status data
        final statusData = _getStatusData(budgetProgress, isOverBudget);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side: Cost info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(
                      children: [
                        const Text('💸', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Food Cost',
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Animated total cost
                    AnimatedBuilder(
                      animation: _countAnimation,
                      builder: (context, child) {
                        final animatedCost = totalCost * _countAnimation.value;
                        return Text(
                          '\$${animatedCost.toStringAsFixed(2)}',
                          style: AppTypography.dataLarge.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isOverBudget ? Colors.red[600] : Colors.green[700],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 2),

                    // Budget info (tappable)
                    GestureDetector(
                      onTap: () => _showBudgetEditDialog(context, homeProvider, dailyBudget),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.transparent,
                        ),
                        child: Text(
                          'of \$${dailyBudget.toStringAsFixed(2)} budget',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right side: Status badge and progress bar
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge
                      _buildStatusBadge(statusData, remaining, isOverBudget, budgetProgress),
                      
                      const SizedBox(width: 6),
                      
                      // Compact progress bar
                      _buildProgressBar(budgetProgress, isOverBudget),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusData, double remaining, bool isOverBudget, double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusData['color'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOverBudget 
          ? 'Over \$${(-remaining).toStringAsFixed(2)}'
          : '\$${remaining.toStringAsFixed(2)} left',
        style: AppTypography.dataSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, bool isOverBudget) {
    return Container(
      width: 80,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Colors.grey[200],
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (progress).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isOverBudget 
              ? Colors.red[600]
              : progress >= 0.9 
                ? Colors.orange[600]
                : Colors.green[600],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusData(double progress, bool isOverBudget) {
    if (isOverBudget) {
      return {
        'color': Colors.red[600]!,
        'message': '🚨 Over budget!',
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

  // Use the proper BudgetEditDialog
  void _showBudgetEditDialog(BuildContext context, HomeProvider homeProvider, double currentBudget) {
    showDialog(
      context: context,
      builder: (context) => BudgetEditDialog(
        currentBudget: currentBudget,
        homeProvider: homeProvider,
        title: 'Update Daily Budget',
        showAdvancedOptions: false,
      ),
    );
  }
}