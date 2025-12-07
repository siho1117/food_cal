// lib/widgets/home/cost_summary_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/accent_colors.dart';
import '../../config/constants/app_constants.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';

class CostSummaryWidget extends StatefulWidget {
  const CostSummaryWidget({super.key});

  @override
  State<CostSummaryWidget> createState() => _CostSummaryWidgetState();
}

class _CostSummaryWidgetState extends State<CostSummaryWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _checkForRefresh(double totalCost, double budget) {
    final currentHash = '$totalCost-$budget';
    if (_previousDataHash != null && _previousDataHash != currentHash && mounted) {
      _controller.reset();
      _controller.forward();
    }
    _previousDataHash = currentHash;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, ThemeProvider>(
      builder: (context, homeProvider, themeProvider, child) {
        final totalCost = homeProvider.totalFoodCost;
        final dailyBudget = homeProvider.dailyFoodBudget;

        _checkForRefresh(totalCost, dailyBudget);

        // Get theme-adaptive colors
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          GlassCardStyle.borderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        // Calculate if over budget for visual feedback
        final isOverBudget = dailyBudget > 0 && totalCost > dailyBudget;

        return Semantics(
          label: 'Food cost ${totalCost.toStringAsFixed(2)} of ${dailyBudget.toStringAsFixed(2)} budget. ${isOverBudget ? 'Over budget.' : ''} Tap to edit.',
          button: true,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showBudgetEditDialog(context, homeProvider, dailyBudget);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: GlassCardStyle.blurSigma,
                  sigmaY: GlassCardStyle.blurSigma,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                    borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                    border: Border.all(
                      color: borderColor,
                      width: GlassCardStyle.borderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    // Left: Cost display
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title with icon
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: AppWidgetTheme.fontSizeLG,
                                color: textColor,
                                shadows: AppWidgetTheme.textShadows,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Daily Spend',
                                style: TextStyle(
                                  fontSize: AppWidgetTheme.fontSizeLG,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  shadows: AppWidgetTheme.textShadows,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        // Animated cost amount with inline budget
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                final animatedCost = totalCost * _animation.value;
                                return Text(
                                  '\$${animatedCost.toStringAsFixed(2)}',
                                  style: AppTypography.dataMedium.copyWith(
                                    color: textColor,
                                    shadows: AppWidgetTheme.textShadows,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ \$${dailyBudget.toStringAsFixed(2)}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                                shadows: AppWidgetTheme.textShadows,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right: Circular progress indicator with animation
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildCircularProgress(
                        totalCost,
                        dailyBudget,
                        textColor,
                        isOverBudget,
                      );
                    },
                  ),
                ],
              ),
            ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(double totalCost, double dailyBudget, Color textColor, bool isOverBudget) {
    // Calculate actual percentage (can go beyond 100%)
    final actualPercentage = dailyBudget > 0
        ? (totalCost / dailyBudget)
        : 0.0;
    final animatedPercentage = actualPercentage * _animation.value;
    final displayPercentage = (animatedPercentage * 100).round();

    // For ring display, cap at 100%
    final ringProgress = animatedPercentage.clamp(0.0, 1.0);

    // Use vibrantRed for over-budget state
    final progressColor = isOverBudget ? AccentColors.vibrantRed : textColor;

    return CustomPaint(
      size: const Size(64, 64),
      painter: _CircularProgressPainter(
        progress: ringProgress,
        baseColor: progressColor,
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Text(
            '$displayPercentage%',
            style: AppTypography.labelMedium.copyWith(
              color: progressColor,
              fontWeight: FontWeight.bold,
              shadows: AppWidgetTheme.textShadows,
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetEditDialog(BuildContext context, HomeProvider homeProvider, double currentBudget) {
    showDialog(
      context: context,
      builder: (context) => _BudgetEditDialog(
        currentBudget: currentBudget,
        homeProvider: homeProvider,
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  _CircularProgressPainter({
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    // Background circle
    final bgPaint = Paint()
      ..color = baseColor.withValues(alpha: AppWidgetTheme.opacityMediumHigh)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4  // Thinner line
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = baseColor.withValues(alpha: AppWidgetTheme.opacityHighest)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4  // Thinner line
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

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.baseColor != baseColor;
  }
}

/// Simplified budget edit dialog
class _BudgetEditDialog extends StatefulWidget {
  final double currentBudget;
  final HomeProvider homeProvider;

  const _BudgetEditDialog({
    required this.currentBudget,
    required this.homeProvider,
  });

  @override
  State<_BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<_BudgetEditDialog> {
  late final TextEditingController _budgetController;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.currentBudget.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,

      title: const Text(
        'Budget',
        style: AppDialogTheme.titleStyle,
      ),

      content: TextField(
        controller: _budgetController,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
        ],
        style: AppDialogTheme.inputTextStyle,
        decoration: AppDialogTheme.inputDecoration(
          hintText: '0.00',
        ).copyWith(
          errorText: _errorText,
        ),
        onChanged: (_) {
          // Clear error when user types
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
      ),
      
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: AppDialogTheme.cancelButtonStyle,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppDialogTheme.buttonGap),
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          style: AppDialogTheme.primaryButtonStyle,
          child: Text(_isLoading ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final budgetText = _budgetController.text.trim();
    final budget = double.tryParse(budgetText);

    if (budget == null || budget <= 0) {
      setState(() => _errorText = 'Enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.homeProvider.updateFoodBudget(budget);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error saving budget: $e');
      if (mounted) {
        setState(() {
          _errorText = 'Save failed';
          _isLoading = false;
        });
      }
    }
  }
}