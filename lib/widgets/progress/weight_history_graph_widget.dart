// lib/widgets/progress/weight_history_graph_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';
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

  List<WeightData> _getFilteredData() {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedPeriod) {
      case TimePeriod.sevenDays:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case TimePeriod.thirtyDays:
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
      case TimePeriod.threeMonths:
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case TimePeriod.sixMonths:
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      case TimePeriod.oneYear:
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
    }

    return widget.weightHistory
        .where((entry) => entry.timestamp.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<WeightData> _simplifyData(List<WeightData> data) {
    if (data.length <= 30) return data;
    
    final step = (data.length / 30).ceil();
    final simplified = <WeightData>[];
    
    for (var i = 0; i < data.length; i += step) {
      simplified.add(data[i]);
    }
    
    if (simplified.last != data.last) {
      simplified.add(data.last);
    }
    
    return simplified;
  }

  Map<String, double> _calculateStats(List<WeightData> data) {
    if (data.isEmpty) {
      return {'totalChange': 0.0, 'average': 0.0, 'weeklyRate': 0.0};
    }

    final weights = data.map((e) => e.weight).toList();
    final totalChange = (weights.last - weights.first).toDouble();
    final average = (weights.reduce((a, b) => a + b) / weights.length).toDouble();
    
    final days = data.last.timestamp.difference(data.first.timestamp).inDays;
    final weeklyRate = days > 0 ? ((totalChange / days) * 7).toDouble() : 0.0;

    return {
      'totalChange': totalChange,
      'average': average,
      'weeklyRate': weeklyRate,
    };
  }

  Map<String, dynamic> _calculateTrend(List<WeightData> data) {
    if (data.length < 2) {
      return {'type': 'stable', 'rate': 0.0};
    }

    final recentData = data.length > 7 ? data.sublist(data.length - 7) : data;
    final weights = recentData.map((e) => e.weight).toList();
    final change = (weights.last - weights.first).toDouble();
    final days = recentData.last.timestamp.difference(recentData.first.timestamp).inDays;
    final weeklyRate = days > 0 ? ((change / days) * 7).toDouble() : 0.0;

    if (weeklyRate.abs() < 0.2) {
      return {'type': 'stable', 'rate': weeklyRate.abs()};
    } else if (weeklyRate < 0) {
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

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    
    if (filteredData.isEmpty) {
      return _buildEmptyState();
    }

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
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weight History',
                              style: AppTypography.displaySmall.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppLegacyColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildTrendIndicator(trend),
                          ],
                        ),
                        _buildPeriodSelector(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCompactChart(simplifiedData),
                    const SizedBox(height: 12),
                    _buildSimpleXAxisLabels(simplifiedData),
                    const SizedBox(height: 16),
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TimePeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
                _animationController.reset();
                _animationController.forward();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppLegacyColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                _getPeriodLabel(period),
                style: AppTypography.bodyMedium.copyWith(
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
        bgColor = AppLegacyColors.coralAccent.withValues(alpha: 0.1);
        textColor = AppLegacyColors.coralAccent;
        emoji = '📉';
        description = 'Losing ${rate.abs().toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'}/week';
        break;
      case 'gaining':
        bgColor = AppLegacyColors.goldAccent.withValues(alpha: 0.1);
        textColor = AppLegacyColors.goldAccent;
        emoji = '📈';
        description = 'Gaining ${rate.toStringAsFixed(1)} ${widget.isMetric ? 'kg' : 'lbs'}/week';
        break;
      default:
        bgColor = AppLegacyColors.primaryBlue.withValues(alpha: 0.1);
        textColor = AppLegacyColors.primaryBlue;
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
            style: AppTypography.bodyMedium.copyWith(
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
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildYAxisLabels(data),
          Expanded(
            child: CustomPaint(
              painter: WeightChartPainter(
                data: data,
                isMetric: widget.isMetric,
                targetWeight: widget.targetWeight,
                animation: _animation.value,
                touchedIndex: _touchedIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels(List<WeightData> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
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
        style: AppTypography.labelLarge.copyWith(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSimpleXAxisLabels(List<WeightData> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
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
          style: AppTypography.bodyMedium.copyWith(
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
        color: AppLegacyColors.secondaryBeige.withValues(alpha: 0.2),
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
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppLegacyColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Weight History',
              style: AppTypography.displaySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppLegacyColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add weight entries to see beautiful charts',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppLegacyColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: Text(
                '+ Add Weight Entry',
                style: AppTypography.bodyMedium.copyWith(
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
}

class WeightChartPainter extends CustomPainter {
  final List<WeightData> data;
  final bool isMetric;
  final double? targetWeight;
  final double animation;
  final int? touchedIndex;

  WeightChartPainter({
    required this.data,
    required this.isMetric,
    this.targetWeight,
    required this.animation,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final padding = range * 0.1;

    final linePaint = Paint()
      ..color = AppLegacyColors.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppLegacyColors.primaryBlue.withValues(alpha: 0.2),
          AppLegacyColors.primaryBlue.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final gradientPath = Path();
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedWeight = (data[i].weight - (minWeight - padding)) / (range + 2 * padding);
      final y = size.height * (1 - normalizedWeight * animation);

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = AppLegacyColors.primaryBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(WeightChartPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.touchedIndex != touchedIndex;
  }
}