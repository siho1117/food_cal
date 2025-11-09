// lib/widgets/progress/weight_history_graph_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../data/models/weight_data.dart';
import '../../providers/theme_provider.dart';
import '../../providers/progress_data.dart';
import 'weight_edit_dialog.dart';

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
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get last 7 days of weight data (max 7 entries, one per day)
  List<WeightData> _getLast7Days(List<WeightData> weightHistory) {
    if (weightHistory.isEmpty) return [];

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    print('=== WEIGHT DATA DEBUG ===');
    print('Total entries: ${weightHistory.length}');
    print('Filtering from: ${DateFormat('yyyy-MM-dd HH:mm').format(sevenDaysAgo)} to ${DateFormat('yyyy-MM-dd HH:mm').format(now)}');

    // Filter to last 7 days and sort by date
    final last7Days = weightHistory
        .where((entry) => entry.timestamp.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    print('Entries in last 7 days: ${last7Days.length}');
    for (final entry in last7Days) {
      print('  - ${DateFormat('yyyy-MM-dd HH:mm').format(entry.timestamp)}: ${entry.weight} kg');
    }

    // Take only the last entry per day (max 7 days)
    final Map<String, WeightData> entriesPerDay = {};
    for (final entry in last7Days) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      // Keep only the latest entry for each day
      if (!entriesPerDay.containsKey(dateKey) ||
          entry.timestamp.isAfter(entriesPerDay[dateKey]!.timestamp)) {
        entriesPerDay[dateKey] = entry;
      }
    }

    print('Unique days: ${entriesPerDay.keys.length}');
    for (final dateKey in entriesPerDay.keys) {
      print('  - $dateKey: ${entriesPerDay[dateKey]!.weight} kg');
    }

    // Convert back to list and sort
    final result = entriesPerDay.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Limit to 7 entries max
    final finalResult = result.length > 7 ? result.sublist(result.length - 7) : result;
    print('Final result: ${finalResult.length} entries');
    print('========================');

    return finalResult;
  }

  Map<String, double> _calculateStats(List<WeightData> data) {
    if (data.isEmpty) {
      return {'totalChange': 0.0, 'average': 0.0, 'weeklyRate': 0.0};
    }

    final firstWeight = data.first.weight;
    final lastWeight = data.last.weight;
    final totalChange = lastWeight - firstWeight;

    final average = data.map((e) => e.weight).reduce((a, b) => a + b) / data.length;

    final daysDiff = data.last.timestamp.difference(data.first.timestamp).inDays;
    final weeklyRate = daysDiff > 0 ? (totalChange / daysDiff) * 7 : 0.0;

    return {
      'totalChange': totalChange,
      'average': average,
      'weeklyRate': weeklyRate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ProgressData>(
      builder: (context, themeProvider, progressData, child) {
        final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

        // Use weightHistory from ProgressData provider instead of widget prop
        final allWeightHistory = progressData.weightHistory;
        final last7DaysData = _getLast7Days(allWeightHistory);

        if (last7DaysData.isEmpty) {
          return _buildEmptyState(textColor);
        }

        final stats = _calculateStats(last7DaysData);

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppWidgetTheme.getBorderColor(
                        themeProvider.selectedGradient,
                        AppWidgetTheme.cardBorderOpacity,
                      ),
                      width: AppWidgetTheme.cardBorderWidth,
                    ),
                    borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                  ),
                  padding: AppWidgetTheme.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Weight History (7 Days)',
                        style: TextStyle(
                          fontSize: AppWidgetTheme.fontSizeLG,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: AppWidgetTheme.spaceXL),
                      _buildCompactChart(last7DaysData, textColor),
                      SizedBox(height: AppWidgetTheme.spaceMD),
                      _buildSimpleXAxisLabels(last7DaysData, textColor),
                      SizedBox(height: AppWidgetTheme.spaceLG),
                      _buildCompactStats(stats, textColor),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompactChart(List<WeightData> displayData, Color textColor) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(textColor, AppWidgetTheme.opacityVeryLight),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
        border: Border.all(
          color: textColor.withValues(alpha: AppWidgetTheme.opacityMediumHigh),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildYAxisLabels(displayData, textColor),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _handleChartTap(details, displayData, constraints.maxWidth),
                  child: CustomPaint(
                    painter: WeightChartPainter(
                      data: displayData,
                      isMetric: widget.isMetric,
                      targetWeight: widget.targetWeight,
                      animation: _animation.value,
                      touchedIndex: _touchedIndex,
                      textColor: textColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleChartTap(TapDownDetails details, List<WeightData> displayData, double chartWidth) {
    if (displayData.isEmpty) return;

    // Use localPosition directly - it's already relative to the GestureDetector
    final tapX = details.localPosition.dx;

    print('=== TAP DEBUG ===');
    print('Tap X: $tapX');
    print('Chart Width: $chartWidth');
    print('Display Data Length: ${displayData.length}');

    // Validate tap is within chart bounds
    if (tapX < 0 || tapX > chartWidth) {
      print('Tap outside chart bounds');
      print('================');
      return;
    }

    // Find closest data point using even spacing
    final pointSpacing = displayData.length > 1
        ? chartWidth / (displayData.length - 1)
        : chartWidth / 2;

    print('Point Spacing: $pointSpacing');

    int closestIndex = (tapX / pointSpacing).round();
    closestIndex = closestIndex.clamp(0, displayData.length - 1);

    // Check if tap is close enough to the point (within 40 pixels)
    final expectedX = closestIndex * pointSpacing;
    print('Closest Index: $closestIndex');
    print('Expected X: $expectedX');
    print('Distance: ${(tapX - expectedX).abs()}');

    if ((tapX - expectedX).abs() > 40) {
      print('Tap too far from dot (tolerance: 40px)');
      print('================');
      return;
    }

    print('Selected Date: ${displayData[closestIndex].timestamp}');
    print('Selected Weight: ${displayData[closestIndex].weight}');
    print('================');

    // Show edit dialog for the tapped entry
    _showEditDialog(displayData[closestIndex]);
  }

  void _showEditDialog(WeightData entry) {
    final progressData = Provider.of<ProgressData>(context, listen: false);

    showWeightEditDialog(
      context: context,
      entry: entry,
      isMetric: widget.isMetric,
      targetWeight: progressData.targetWeight,
      onSave: (entryId, weight, timestamp, note) async {
        await progressData.updateWeightEntry(entryId, weight, timestamp, note);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weight updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveTarget: (targetWeight) async {
        await progressData.updateTargetWeight(targetWeight);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Target weight updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Widget _buildYAxisLabels(List<WeightData> data, Color textColor) {
    if (data.isEmpty) return const SizedBox.shrink();

    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final middle = (minWeight + maxWeight) / 2;
    final unit = widget.isMetric ? 'kg' : 'lbs';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildYLabel(maxWeight, textColor, showUnit: true, unit: unit),
        _buildYLabel(middle, textColor),
        _buildYLabel(minWeight, textColor),
      ],
    );
  }

  Widget _buildYLabel(double value, Color textColor, {bool showUnit = false, String? unit}) {
    return Padding(
      padding: EdgeInsets.only(right: AppWidgetTheme.spaceXS),
      child: Text(
        showUnit && unit != null
            ? '${value.toStringAsFixed(0)} $unit'
            : value.toStringAsFixed(0),
        style: TextStyle(
          fontSize: AppWidgetTheme.fontSizeXS,
          color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          fontWeight: showUnit ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSimpleXAxisLabels(List<WeightData> data, Color textColor) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Show all dates for 7-day view (max 7 labels)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Match chart padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data.map((entry) {
          return Text(
            DateFormat('M/d').format(entry.timestamp),
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactStats(Map<String, double> stats, Color textColor) {
    final statsToShow = [
      {'label': 'Total Change', 'value': '${stats['totalChange']! >= 0 ? '+' : ''}${stats['totalChange']!.toStringAsFixed(1)}'},
      {'label': 'Average', 'value': stats['average']!.toStringAsFixed(1)},
      {'label': 'Weekly Rate', 'value': '${stats['weeklyRate']! >= 0 ? '+' : ''}${stats['weeklyRate']!.toStringAsFixed(1)}'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: AppWidgetTheme.spaceMD,
      ),
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(textColor, AppWidgetTheme.opacityLight),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: statsToShow.map((stat) => _buildCompactStatCard(stat['label']!, stat['value']!, textColor)).toList(),
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeXS,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          ),
        ),
        SizedBox(height: AppWidgetTheme.spaceXXS),
        Text(
          value,
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeMS,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
      decoration: BoxDecoration(
        border: Border.all(
          color: textColor.withValues(alpha: AppWidgetTheme.cardBorderOpacity),
          width: AppWidgetTheme.cardBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 60,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
          ),
          SizedBox(height: AppWidgetTheme.spaceLG),
          Text(
            'No Weight History',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeLG,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXS),
          Text(
            'Add weight entries to see beautiful charts',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
  final Color textColor;

  WeightChartPainter({
    required this.data,
    required this.isMetric,
    this.targetWeight,
    required this.animation,
    this.touchedIndex,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Add horizontal padding (8px on each side)
    const double horizontalPadding = 8.0;
    final chartWidth = size.width - (horizontalPadding * 2);

    final weights = data.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;
    final padding = range * 0.1;

    final linePaint = Paint()
      ..color = textColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
          textColor.withValues(alpha: AppWidgetTheme.opacityVeryLight),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final gradientPath = Path();
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      // Add horizontal padding to X calculation
      final x = horizontalPadding + (i / (data.length - 1)) * chartWidth;
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

    gradientPath.lineTo(size.width - horizontalPadding, size.height);
    gradientPath.lineTo(horizontalPadding, size.height);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(WeightChartPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.touchedIndex != touchedIndex ||
        oldDelegate.textColor != textColor;
  }
}
