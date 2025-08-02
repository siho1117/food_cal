// lib/widgets/home/macronutrient_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class MacronutrientWidget extends StatefulWidget {
  const MacronutrientWidget({super.key});

  @override
  State<MacronutrientWidget> createState() => _MacronutrientWidgetState();
}

class _MacronutrientWidgetState extends State<MacronutrientWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Track previous values for refresh detection
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller first
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Then create animation
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    // Start animation after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkForRefresh(Map<String, double> consumed, Map<String, int> target) {
    final currentHash = '${consumed.values.join(',')}_${target.values.join(',')}';
    if (_previousDataHash != null && _previousDataHash != currentHash && mounted) {
      _controller.reset();
      _controller.forward();
    }
    _previousDataHash = currentHash;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final consumed = homeProvider.consumedMacros;
        final target = homeProvider.targetMacros;
        final progress = homeProvider.macroProgressPercentages;

        _checkForRefresh(consumed, target);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Opacity(
                  opacity: _animation.value,
                  child: Row(
                    children: [
                      const Text('💪', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Text(
                        'Macronutrients',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Hybrid compact macro rows (Option 2 style with mini dots)
                ..._buildCompactMacroRows(consumed, target, progress),

                const SizedBox(height: 12),

                // Option 1 style balance summary
                _buildCompactBalanceSummary(consumed),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCompactMacroRows(Map<String, double> consumed, Map<String, int> target, Map<String, double> progress) {
    final macros = [
      {'key': 'protein', 'symbol': '🥩', 'name': 'Protein', 'color': Colors.red[500]!},
      {'key': 'carbs', 'symbol': '🍞', 'name': 'Carbs', 'color': Colors.blue[500]!},
      {'key': 'fat', 'symbol': '🧀', 'name': 'Fat', 'color': Colors.orange[500]!},
    ];

    return macros.asMap().entries.map((entry) {
      final index = entry.key;
      final macro = entry.value;
      final key = macro['key'] as String;
      final delay = index * 0.15; // Stagger animation

      return Padding(
        padding: EdgeInsets.only(bottom: index < 2 ? 8 : 0), // Reduced spacing
        child: Opacity(
          opacity: (_animation.value - delay).clamp(0.0, 1.0),
          child: _buildCompactMacroRow(
            symbol: macro['symbol'] as String,
            name: macro['name'] as String,
            consumed: consumed[key]! * _animation.value,
            target: target[key]!.toDouble() * _animation.value,
            progress: progress[key]! * _animation.value,
            color: macro['color'] as Color,
          ),
        ),
      );
    }).toList();
  }

  // Hybrid compact row: single line with mini dots (Option 2 style)
  Widget _buildCompactMacroRow({
    required String symbol,
    required String name,
    required double consumed,
    required double target,
    required double progress,
    required Color color,
  }) {
    return Row(
      children: [
        // Left side: Icon + Name + Values
        Expanded(
          child: Row(
            children: [
              Text(symbol, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  name,
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${consumed.round()}g / ${target.round()}g',
                style: AppTextStyles.getNumericStyle().copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Right side: Percentage + Mini Dots
        Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                '${progress.round()}%',
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            _buildMiniDotProgress(progress / 100, color),
          ],
        ),
      ],
    );
  }

  // Mini dot progress (Option 2 style with 10 dots, 4px size)
  Widget _buildMiniDotProgress(double progress, Color color) {
    const dots = 10; // More dots for better precision
    final filled = (progress * dots).round().clamp(0, dots);
    
    return Row(
      children: List.generate(dots, (i) => Padding(
        padding: const EdgeInsets.only(right: 2), // Reduced spacing
        child: Container(
          width: 4, // Smaller dots
          height: 4,
          decoration: BoxDecoration(
            color: i < filled ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
      )),
    );
  }

  // Compact balance summary (Option 1 style)
  Widget _buildCompactBalanceSummary(Map<String, double> consumed) {
    final totalCals = consumed['protein']! * 4 + consumed['carbs']! * 4 + consumed['fat']! * 9;
    if (totalCals == 0) return const SizedBox.shrink();

    final percentages = {
      'protein': ((consumed['protein']! * 4) / totalCals * 100).round(),
      'carbs': ((consumed['carbs']! * 4) / totalCals * 100).round(),
      'fat': ((consumed['fat']! * 9) / totalCals * 100).round(),
    };

    return Opacity(
      opacity: _animation.value,
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            // Balance items on the left
            Expanded(
              child:               Row(
                children: [
                  _buildBalanceItem('🥩', '${percentages['protein']}%', Colors.red[500]!),
                  const SizedBox(width: 12),
                  _buildBalanceItem('🍞', '${percentages['carbs']}%', Colors.blue[500]!),
                  const SizedBox(width: 12),
                  _buildBalanceItem('🧀', '${percentages['fat']}%', Colors.orange[500]!),
                ],
              ),
            ),
            
            // Label on the right
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  'Macro Balance',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String emoji, String percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 2),
        Text(
          percentage,
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}