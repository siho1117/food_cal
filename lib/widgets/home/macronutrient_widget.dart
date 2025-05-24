// lib/widgets/home/macronutrient_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class MacronutrientWidget extends StatefulWidget {
  const MacronutrientWidget({Key? key}) : super(key: key);

  @override
  State<MacronutrientWidget> createState() => _MacronutrientWidgetState();
}

class _MacronutrientWidgetState extends State<MacronutrientWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller for progress animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Initialize the animation properly
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (homeProvider.isLoading) {
          return Container(
            height: 240,
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

        // Get data from provider
        final consumedMacros = homeProvider.consumedMacros;
        final targetMacros = homeProvider.targetMacros;
        final progressPercentages = homeProvider.macroProgressPercentages;
        final targetPercentages = homeProvider.macroTargetPercentages;

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
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.02),
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
                          Icons.donut_large_rounded,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Macronutrients',
                          style: AppTextStyles.getSubHeadingStyle().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                      onPressed: () => homeProvider.refreshData(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Main content area
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side: Circular chart
                    SizedBox(
                      width: 145,
                      height: 145,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return _buildMacroCircularChart(
                            progressPercentages: progressPercentages,
                            animationValue: _progressAnimation.value,
                          );
                        },
                      ),
                    ),
                    
                    // Spacing between chart and text
                    const SizedBox(width: 20),
                    
                    // Right side: Macro information
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMacroInfo(
                            'Protein',
                            consumedMacros['protein']!.round(),
                            targetMacros['protein']!,
                            targetPercentages['protein']!,
                            AppTheme.coralAccent,
                          ),
                          const SizedBox(height: 15),
                          _buildMacroInfo(
                            'Carbs',
                            consumedMacros['carbs']!.round(),
                            targetMacros['carbs']!,
                            targetPercentages['carbs']!,
                            AppTheme.goldAccent,
                          ),
                          const SizedBox(height: 15),
                          _buildMacroInfo(
                            'Fat',
                            consumedMacros['fat']!.round(),
                            targetMacros['fat']!,
                            targetPercentages['fat']!,
                            AppTheme.accentColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroCircularChart({
    required Map<String, double> progressPercentages,
    required double animationValue,
  }) {
    return CustomPaint(
      painter: MacroProgressChartPainter(
        proteinProgress: progressPercentages['protein']! * animationValue,
        carbsProgress: progressPercentages['carbs']! * animationValue,
        fatProgress: progressPercentages['fat']! * animationValue,
        proteinColor: AppTheme.coralAccent,
        carbsColor: AppTheme.goldAccent,
        fatColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildMacroInfo(
    String name,
    int consumed,
    int target,
    int percentage,
    Color color,
  ) {
    // Determine percentage color
    Color percentColor = percentage > 100 ? Colors.red[500]! : Colors.green[600]!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Macro name with indicator
        Row(
          children: [
            // Circle indicator
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            
            // Macro name
            Text(
              name,
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Values row with proper layout - aligned to the right side
        Container(
          width: 200, // Constraint to make the row shorter
          alignment: Alignment.centerRight, // Right align the entire row
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, // Changed to end alignment
            mainAxisSize: MainAxisSize.min, // Make row as small as possible
            children: [
              // Consumed and target grams
              RichText(
                text: TextSpan(
                  style: AppTextStyles.getNumericStyle().copyWith(
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: '$consumed',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'g / $target',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text: 'g',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12), // Fixed spacing between elements
              
              // Percentage with appropriate color
              Text(
                '$percentage%',
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: percentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MacroProgressChartPainter extends CustomPainter {
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;

  MacroProgressChartPainter({
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Ring widths with better proportion
    final outerRingWidth = radius * 0.18;
    final middleRingWidth = radius * 0.18;
    final innerRingWidth = radius * 0.18;
    
    // Ring radii with improved spacing
    final outerRingRadius = radius - outerRingWidth / 2;
    final middleRingRadius = radius - outerRingWidth * 1.4 - middleRingWidth / 2;
    final innerRingRadius = radius - outerRingWidth * 1.4 - middleRingWidth * 1.4 - innerRingWidth / 2;
    
    // Background rings (gray tracks)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: outerRingRadius,
      strokeWidth: outerRingWidth,
      percentage: 1.0,
      color: Colors.grey[200]!,
    );
    
    _drawRing(
      canvas: canvas,
      center: center,
      radius: middleRingRadius,
      strokeWidth: middleRingWidth,
      percentage: 1.0,
      color: Colors.grey[200]!,
    );
    
    _drawRing(
      canvas: canvas,
      center: center,
      radius: innerRingRadius,
      strokeWidth: innerRingWidth,
      percentage: 1.0,
      color: Colors.grey[200]!,
    );
    
    // Protein ring (outer)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: outerRingRadius,
      strokeWidth: outerRingWidth,
      percentage: proteinProgress,
      color: proteinColor,
    );
    
    // Carbs ring (middle)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: middleRingRadius,
      strokeWidth: middleRingWidth,
      percentage: carbsProgress,
      color: carbsColor,
    );
    
    // Fat ring (inner)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: innerRingRadius,
      strokeWidth: innerRingWidth,
      percentage: fatProgress,
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
      ..strokeCap = StrokeCap.round
      ..color = color;
      
    // Progress arc
    if (percentage > 0) {
      // Start at the top (270 degrees) and go clockwise
      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * percentage;
      
      // Draw the actual arc
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
  bool shouldRepaint(MacroProgressChartPainter oldDelegate) {
    return oldDelegate.proteinProgress != proteinProgress ||
        oldDelegate.carbsProgress != carbsProgress ||
        oldDelegate.fatProgress != fatProgress;
  }
}