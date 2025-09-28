// lib/widgets/progress/weight_history_graph_widget.dart
// Cleaner, more compact version
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/weight_data.dart';

enum TimePeriod { sevenDays, thirtyDays, threeMonths, sixMonths, oneYear }

class WeightHistoryGraphWidget extends StatefulWidget {
  final List<WeightData> weightHistory;
  final bool isMetric;
  final double? targetWeight;

  const WeightHistoryGraphWidget({
    super.key,
    required this.weightHistory,
    required this.isMetric,
    this.targetWeight,
  });

  @override
  State<WeightHistoryGraphWidget> createState() => _WeightHistoryGraphWidgetState();
}

class _WeightHistoryGraphWidgetState extends State<WeightHistoryGraphWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  TimePeriod _selectedPeriod = TimePeriod.thirtyDays;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    
    if (filteredData.isEmpty) {
      return _buildEmptyState();
    }

    // Reduce data points for cleaner visualization
    final simplifiedData = _simplifyData(filteredData);
    final stats = _calculateStats(filteredData);
    final trend = _calculateTrend(filteredData);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Card(
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppTheme.secondaryBeige.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompactHeader(),
                    const SizedBox(height: 12),
                    _buildTrendIndicator(trend),
                    const SizedBox(height: 16),
                    _buildCompactChart(simplifiedData),
                    const SizedBox(height: 12),
                    _buildCompactStats(stats),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Weight Progress',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        _buildCompactTimePeriodSelector(),
      ],
    );
  }

  Widget _buildCompactTimePeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: TimePeriod.values.take(4).map((period) {
          final isSelected = period == _selectedPeriod;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                _getPeriodLabel(period),
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendIndicator(Map<String, dynamic> trend) {
    final trendType = trend['type'] as String;
    final rate = trend['rate'] as double;
    
    Color bgColor;
    Color textColor;
    String emoji;
    String description;

    switch (trendType) {
      case 'losing':
        bgColor = AppTheme.coralAccent.withValues(alpha: 0.1);
        textColor = AppTheme.coralAccent;
        emoji = '📉';
        description = 'Losing ${rate.abs().toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'}/week';
        break;
      case 'gaining':
        bgColor = AppTheme.goldAccent.withValues(alpha: 0.1);
        textColor = AppTheme.goldAccent;
        emoji = '📈';
        description = 'Gaining ${rate.toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'}/week';
        break;
      default:
        bgColor = AppTheme.primaryBlue.withValues(alpha: 0.1);
        textColor = AppTheme.primaryBlue;
        emoji = '➡️';
        description = 'Maintaining within ${rate.toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'} range';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            description,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactChart(List<WeightData> data) {
    return Container(
      height: 180, // Reduced height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          // Chart area
          Positioned(
            left: 35, // Reduced margin
            right: 15,
            top: 15,
            bottom: 30,
            child: CustomPaint(
              painter: CompactWeightChartPainter(
                data: data,
                targetWeight: widget.targetWeight,
                animation: _animation,
                touchedIndex: _touchedIndex,
                isMetric: widget.isMetric,
              ),
              child: GestureDetector(
                onTapDown: (details) {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.globalPosition);
                  final chartWidth = renderBox.size.width - 50;
                  final xPosition = localPosition.dx - 35;
                  
                  if (xPosition >= 0 && xPosition <= chartWidth && data.isNotEmpty) {
                    final index = ((xPosition / chartWidth) * (data.length - 1)).round();
                    setState(() {
                      _touchedIndex = index.clamp(0, data.length - 1);
                    });
                    
                    _showTooltip(data[_touchedIndex!]);
                  }
                },
              ),
            ),
          ),
          
          // Simplified Y-axis labels (only 3 labels)
          Positioned(
            left: 0,
            top: 15,
            bottom: 30,
            width: 30,
            child: _buildSimpleYAxisLabels(data),
          ),
          
          // Simplified X-axis labels
          Positioned(
            left: 35,
            right: 15,
            bottom: 0,
            height: 25,
            child: _buildSimpleXAxisLabels(data),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleYAxisLabels(List<WeightData> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    
    // Only show 3 labels: min, middle, max
    final middle = (minWeight + maxWeight) / 2;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildYLabel(maxWeight),
        _buildYLabel(middle),
        _buildYLabel(minWeight),
      ],
    );
  }

  Widget _buildYLabel(double value) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(
        value.toStringAsFixed(0),
        style: AppTextStyles.getNumericStyle().copyWith(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSimpleXAxisLabels(List<WeightData> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    // Only show first, middle, and last dates
    final indices = data.length > 2 
        ? [0, data.length ~/ 2, data.length - 1]
        : [0, data.length - 1];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: indices.map((index) {
        final date = data[index].timestamp;
        final format = data.length > 30 ? 'MMM' : 'M/d';
        
        return Text(
          DateFormat(format).format(date),
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactStats(Map<String, double> stats) {
    final statsToShow = [
      {'label': 'Total Change', 'value': '${stats['totalChange']! >= 0 ? '+' : ''}${stats['totalChange']!.toStringAsFixed(1)}'},
      {'label': 'Average', 'value': stats['average']!.toStringAsFixed(1)},
      {'label': 'Weekly Rate', 'value': '${stats['weeklyRate']! >= 0 ? '+' : ''}${stats['weeklyRate']!.toStringAsFixed(1)}'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBeige.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: statsToShow.map((stat) => _buildCompactStatCard(stat['label']!, stat['value']!)).toList(),
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                size: 32,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start Tracking Your Progress',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add weight entries to see beautiful charts',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to add weight entry
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: Text(
                '+ Add Weight Entry',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTooltip(WeightData entry) {
    // Simple debug output - you could implement a proper tooltip overlay
    // Removed print statement for production
    // You could add a proper tooltip overlay here if needed
  }

  // Data simplification to reduce visual noise
  List<WeightData> _simplifyData(List<WeightData> data) {
    if (data.length <= 15) return data; // No need to simplify small datasets
    
    // Take every nth point to reduce visual clutter
    final step = (data.length / 15).ceil();
    final simplified = <WeightData>[];
    
    for (int i = 0; i < data.length; i += step) {
      simplified.add(data[i]);
    }
    
    // Always include the last point
    if (simplified.last != data.last) {
      simplified.add(data.last);
    }
    
    return simplified;
  }

  // Helper methods (same logic but optimized)
  List<WeightData> _getFilteredData() {
    final now = DateTime.now();
    final cutoffDate = switch (_selectedPeriod) {
      TimePeriod.sevenDays => now.subtract(const Duration(days: 7)),
      TimePeriod.thirtyDays => now.subtract(const Duration(days: 30)),
      TimePeriod.threeMonths => now.subtract(const Duration(days: 90)),
      TimePeriod.sixMonths => now.subtract(const Duration(days: 180)),
      TimePeriod.oneYear => now.subtract(const Duration(days: 365)),
    };

    return widget.weightHistory
        .where((entry) => entry.timestamp.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Map<String, double> _calculateStats(List<WeightData> data) {
    if (data.isEmpty) return {};

    final weights = data.map((e) => e.weight).toList();
    final totalChange = weights.last - weights.first;
    final average = weights.reduce((a, b) => a + b) / weights.length;
    
    final daysDiff = data.last.timestamp.difference(data.first.timestamp).inDays;
    final weeklyRate = daysDiff > 0 ? (totalChange / daysDiff) * 7 : 0.0;

    return {
      'totalChange': totalChange,
      'average': average,
      'weeklyRate': weeklyRate,
    };
  }

  Map<String, dynamic> _calculateTrend(List<WeightData> data) {
    if (data.length < 2) {
      return {'type': 'maintaining', 'rate': 0.0};
    }

    final firstHalf = data.take(data.length ~/ 2).toList();
    final secondHalf = data.skip(data.length ~/ 2).toList();
    
    final firstAvg = firstHalf.map((e) => e.weight).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((e) => e.weight).reduce((a, b) => a + b) / secondHalf.length;
    
    final change = secondAvg - firstAvg;
    final daysDiff = data.last.timestamp.difference(data.first.timestamp).inDays;
    final weeklyRate = daysDiff > 0 ? (change / daysDiff) * 7 : 0.0;

    if (change.abs() < 0.5) {
      return {'type': 'maintaining', 'rate': change.abs()};
    } else if (change < 0) {
      return {'type': 'losing', 'rate': weeklyRate};
    } else {
      return {'type': 'gaining', 'rate': weeklyRate};
    }
  }

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.sevenDays:
        return '7D';
      case TimePeriod.thirtyDays:
        return '30D';
      case TimePeriod.threeMonths:
        return '3M';
      case TimePeriod.sixMonths:
        return '6M';
      case TimePeriod.oneYear:
        return '1Y';
    }
  }
}

// Simplified CustomPainter with smoother curves and fewer elements
class CompactWeightChartPainter extends CustomPainter {
  final List<WeightData> data;
  final double? targetWeight;
  final Animation<double> animation;
  final int? touchedIndex;
  final bool isMetric;

  CompactWeightChartPainter({
    required this.data,
    required this.targetWeight,
    required this.animation,
    required this.touchedIndex,
    required this.isMetric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final padding = range > 0 ? range * 0.1 : 1.0;
    final adjustedMin = minWeight - padding;
    final adjustedMax = maxWeight + padding;

    // Smoother line paint
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppTheme.coralAccent,
          AppTheme.primaryBlue,
          AppTheme.goldAccent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Subtle gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withValues(alpha: 0.15 * animation.value),
          AppTheme.primaryBlue.withValues(alpha: 0.02 * animation.value),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Smaller, cleaner dots
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotStrokePaint = Paint()
      ..color = AppTheme.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final fillPath = Path();
    final points = <Offset>[];

    // Calculate points with smooth curve
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedY = (data[i].weight - adjustedMin) / (adjustedMax - adjustedMin);
      final y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Create smooth curves using quadratic bezier
        final prevPoint = points[i - 1];
        final controlPoint = Offset(
          (prevPoint.dx + x) / 2,
          (prevPoint.dy + y) / 2,
        );
        path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, x, y);
        fillPath.quadraticBezierTo(controlPoint.dx, controlPoint.dy, x, y);
      }
    }

    // Complete fill path
    if (points.isNotEmpty) {
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();
    }

    // Draw gradient fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw smooth line
    final animatedPath = _createAnimatedPath(path, animation.value);
    canvas.drawPath(animatedPath, linePaint);

    // Draw goal line if available (simplified)
    if (targetWeight != null) {
      final goalY = size.height - ((targetWeight! - adjustedMin) / (adjustedMax - adjustedMin) * size.height);
      final goalPaint = Paint()
        ..color = AppTheme.goldAccent.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      
      _drawSimpleDashedLine(canvas, Offset(0, goalY), Offset(size.width, goalY), goalPaint);
    }

    // Draw fewer, cleaner dots (every few points to reduce clutter)
    for (int i = 0; i < points.length; i++) {
      // Only show dots for every 3rd point or touched point
      if (i % 3 == 0 || i == touchedIndex || i == 0 || i == points.length - 1) {
        final point = points[i];
        final radius = (touchedIndex == i) ? 4.0 : 2.5;
        
        if (i / points.length <= animation.value) {
          canvas.drawCircle(point, radius, dotPaint);
          canvas.drawCircle(point, radius, dotStrokePaint);
        }
      }
    }
  }

  Path _createAnimatedPath(Path originalPath, double animationValue) {
    final metrics = originalPath.computeMetrics();
    final path = Path();
    
    for (final metric in metrics) {
      final length = metric.length * animationValue;
      final extractPath = metric.extractPath(0, length);
      path.addPath(extractPath, Offset.zero);
    }
    
    return path;
  }

  void _drawSimpleDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final startOffset = start + (end - start) * (i * (dashWidth + dashSpace) / distance);
      final endOffset = start + (end - start) * ((i * (dashWidth + dashSpace) + dashWidth) / distance);
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(CompactWeightChartPainter oldDelegate) {
    return data != oldDelegate.data ||
           targetWeight != oldDelegate.targetWeight ||
           animation.value != oldDelegate.animation.value ||
           touchedIndex != oldDelegate.touchedIndex;
  }
}