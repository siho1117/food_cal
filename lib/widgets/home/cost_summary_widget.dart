// lib/widgets/home/cost_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

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
        // Show loading state if data is still loading
        if (homeProvider.isLoading) {
          return Container(
            height: 100, // Reduced from 180px to 100px
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
        
        // Determine status and colors
        final statusData = _getStatusData(budgetProgress, isOverBudget);
        
        return Container(
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
              // Header with money emoji and title
              Row(
                children: [
                  const Text(
                    '💰',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Daily Food Budget',
                    style: AppTextStyles.getSubHeadingStyle().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Single row layout: Amount + Budget info on left, Status + Progress on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Cost amount and budget info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated cost display
                        AnimatedBuilder(
                          animation: _countAnimation,
                          builder: (context, child) {
                            final animatedCost = (totalCost * _countAnimation.value);
                            
                            return Text(
                              '\$${animatedCost.toStringAsFixed(2)}',
                              style: AppTextStyles.getNumericStyle().copyWith(
                                fontSize: 24, // Reduced from 32 to 24
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                height: 1.0,
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
                              'of \${dailyBudget.toStringAsFixed(2)} budget',
                              style: AppTextStyles.getBodyStyle().copyWith(
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
                          
                          const SizedBox(height: 6),
                          
                          // Compact progress bar
                          SizedBox(
                            width: 80, // Fixed width for consistent alignment
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Progress bar
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _countAnimation,
                                    builder: (context, child) {
                                      return FractionallySizedBox(
                                        widthFactor: budgetProgress * _countAnimation.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: statusData['color'],
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Build status badge with updated styling for compact design
  Widget _buildStatusBadge(Map<String, dynamic> statusData, double remaining, bool isOverBudget, double budgetProgress) {
    final badgeText = isOverBudget 
        ? '${((budgetProgress - 1) * 100).round()}% over'
        : '${((1 - budgetProgress) * 100).round()}% left';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
      decoration: BoxDecoration(
        color: statusData['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12), // Reduced border radius
        border: Border.all(
          color: statusData['color'].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        badgeText,
        style: AppTextStyles.getBodyStyle().copyWith(
          fontSize: 11, // Reduced from 13 to 11
          fontWeight: FontWeight.w600,
          color: statusData['color'],
        ),
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

  // Show budget edit dialog
  void _showBudgetEditDialog(BuildContext context, HomeProvider homeProvider, double currentBudget) {
    final TextEditingController budgetController = TextEditingController(
      text: currentBudget.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Text('💰', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Set Daily Budget',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much do you want to spend on food per day?',
              style: AppTextStyles.getBodyStyle().copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Daily Budget',
                prefixText: '\
},
                hintText: '20.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
              ),
              onSubmitted: (_) => _saveBudget(context, homeProvider, budgetController),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Consider your food goals and spending habits',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => _saveBudget(context, homeProvider, budgetController),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );
  }

  // Save budget and update provider
  void _saveBudget(BuildContext context, HomeProvider homeProvider, TextEditingController controller) async {
    final budgetText = controller.text.trim();
    final budget = double.tryParse(budgetText);

    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid budget amount'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (budget > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Budget seems high. Please check the amount.'),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await homeProvider.setDailyFoodBudget(budget);
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily budget set to \${budget.toStringAsFixed(2)}'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save budget. Please try again.'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}