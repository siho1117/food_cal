// lib/widgets/progress/weight_history_graph_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../config/design_system/widget_theme.dart';
import '../../data/models/weight_data.dart';
import '../../providers/theme_provider.dart';
import '../../providers/progress_data.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import 'weight_edit_dialog.dart';

enum TimeRange { sevenDays, twentyEightDays, threeMonths, sixMonths, oneYear }

extension TimeRangeExtension on TimeRange {
  String get label {
    switch (this) {
      case TimeRange.sevenDays:
        return '7D';
      case TimeRange.twentyEightDays:
        return '28D';
      case TimeRange.threeMonths:
        return '3M';
      case TimeRange.sixMonths:
        return '6M';
      case TimeRange.oneYear:
        return '1Y';
    }
  }

  String getTitle(AppLocalizations l10n) {
    switch (this) {
      case TimeRange.sevenDays:
        return l10n.weightHistory7Days;
      case TimeRange.twentyEightDays:
        return l10n.weightHistory28Days;
      case TimeRange.threeMonths:
        return l10n.weightHistory3Months;
      case TimeRange.sixMonths:
        return l10n.weightHistory6Months;
      case TimeRange.oneYear:
        return l10n.weightHistory1Year;
    }
  }

  int get days {
    switch (this) {
      case TimeRange.sevenDays:
        return 7;
      case TimeRange.twentyEightDays:
        return 28;
      case TimeRange.threeMonths:
        return 90;
      case TimeRange.sixMonths:
        return 180;
      case TimeRange.oneYear:
        return 365;
    }
  }

  int get maxDots {
    switch (this) {
      case TimeRange.sevenDays:
        return 7;
      case TimeRange.twentyEightDays:
        return 8;
      case TimeRange.threeMonths:
      case TimeRange.sixMonths:
      case TimeRange.oneYear:
        return 6;
    }
  }
}

class WeightDataPoint {
  final DateTime timestamp;
  final double weight;
  final bool isForwardFilled;
  final WeightData? originalData; // null for forward-filled points

  WeightDataPoint({
    required this.timestamp,
    required this.weight,
    this.isForwardFilled = false,
    this.originalData,
  });
}

class WeightHistoryGraphWidget extends StatefulWidget {
  /// Weight history entries (weight always stored in kg)
  final List<WeightData> weightHistory;

  /// Display preference: true = kg, false = lbs (data stored in kg regardless)
  final bool isMetric;

  /// Target/goal weight in kg (converted for display based on isMetric)
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

class _WeightHistoryGraphWidgetState extends State<WeightHistoryGraphWidget> {
  TimeRange _selectedRange = TimeRange.sevenDays;

  // Y-axis label spacing constants
  static const int _metricSpacing = 2;     // Show every 2 kg (odd numbers)
  static const int _imperialSpacing = 4;   // Show every 4 lbs

  /// Convert weight from kg to display unit (kg or lbs)
  double _toDisplayWeight(double weightInKg) {
    return widget.isMetric ? weightInKg : weightInKg * 2.20462;
  }

  /// Round value down to nearest multiple of spacing
  int _roundDownToMultiple(int value, int multiple) {
    return value - (value % multiple);
  }

  /// Round value up to nearest multiple of spacing
  int _roundUpToMultiple(int value, int multiple) {
    final remainder = value % multiple;
    return remainder == 0 ? value : value + (multiple - remainder);
  }

  /// Get data for selected time range
  List<WeightDataPoint> _getDataForRange(List<WeightData> weightHistory) {
    if (weightHistory.isEmpty) return [];

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedRange.days));

    // Filter to selected range
    final filteredData = weightHistory
        .where((entry) => entry.timestamp.isAfter(startDate))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (filteredData.isEmpty) return [];

    // Calculate interval to get desired max dots
    final totalDays = _selectedRange.days;
    final maxDots = _selectedRange.maxDots;
    final intervalDays = (totalDays / maxDots).ceil();

    return _getSampledData(filteredData, startDate, now, intervalDays);
  }

  /// Get sampled data with forward AND backward filling
  /// intervalDays: 1 for daily, 3-4 for 28D, ~15 for 3M, ~30 for 6M, ~60 for 1Y
  List<WeightDataPoint> _getSampledData(
    List<WeightData> data,
    DateTime startDate,
    DateTime endDate,
    int intervalDays,
  ) {
    final result = <WeightDataPoint>[];
    final totalDays = endDate.difference(startDate).inDays;
    final numPeriods = (totalDays / intervalDays).ceil();

    // Group data by period
    final Map<int, List<WeightData>> periodMap = {};
    for (final entry in data) {
      final daysSinceStart = entry.timestamp.difference(startDate).inDays;
      final periodIndex = (daysSinceStart / intervalDays).floor();
      if (periodIndex >= 0 && periodIndex < numPeriods) {
        periodMap.putIfAbsent(periodIndex, () => []).add(entry);
      }
    }

    // Find earliest entry for backward fill
    WeightData? earliestEntry;
    if (data.isNotEmpty) {
      earliestEntry = data.reduce((a, b) =>
        a.timestamp.isBefore(b.timestamp) ? a : b
      );
    }

    // Sample with forward AND backward filling
    WeightData? lastKnownEntry;
    for (var i = 0; i < numPeriods; i++) {
      final periodEnd = startDate.add(Duration(days: (i + 1) * intervalDays));

      if (periodMap.containsKey(i)) {
        // Get last weight in this period
        final periodData = periodMap[i]!;
        periodData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        lastKnownEntry = periodData.last;

        result.add(WeightDataPoint(
          timestamp: lastKnownEntry.timestamp,
          weight: lastKnownEntry.weight,
          isForwardFilled: false,
          originalData: lastKnownEntry,
        ));
      } else {
        // Use forward-fill if we have a last known entry
        // OR backward-fill if we haven't seen data yet but know earliest entry
        final fillWeight = lastKnownEntry ?? earliestEntry;

        if (fillWeight != null) {
          result.add(WeightDataPoint(
            timestamp: periodEnd,
            weight: fillWeight.weight,
            isForwardFilled: true,
          ));
        }
      }
    }

    return result;
  }

  /// Calculate statistics from weight data points
  /// Returns values in kg (caller must convert to display units)
  Map<String, double> _calculateStats(List<WeightDataPoint> data) {
    if (data.isEmpty) {
      return {'totalChange': 0.0, 'average': 0.0, 'weeklyRate': 0.0};
    }

    // All weights are in kg
    final firstWeight = data.first.weight;
    final lastWeight = data.last.weight;
    final totalChange = lastWeight - firstWeight;

    final average = data.map((e) => e.weight).reduce((a, b) => a + b) / data.length;

    final daysDiff = data.last.timestamp.difference(data.first.timestamp).inDays;
    final weeklyRate = daysDiff > 0 ? (totalChange / daysDiff) * 7 : 0.0;

    return {
      'totalChange': totalChange, // kg
      'average': average,          // kg
      'weeklyRate': weeklyRate,    // kg/week
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ProgressData>(
      builder: (context, themeProvider, progressData, child) {
        final l10n = AppLocalizations.of(context)!;
        final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

        final allWeightHistory = progressData.weightHistory;
        final displayData = _getDataForRange(allWeightHistory);

        if (displayData.isEmpty) {
          return _buildEmptyState(textColor);
        }

        final stats = _calculateStats(displayData);

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassCardStyle.blurSigma,
              sigmaY: GlassCardStyle.blurSigma,
            ),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                border: Border.all(
                  color: AppWidgetTheme.getBorderColor(
                    themeProvider.selectedGradient,
                    GlassCardStyle.borderOpacity,
                  ),
                  width: GlassCardStyle.borderWidth,
                ),
                borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
              ),
              padding: AppWidgetTheme.cardPadding,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  const AnimatedEmoji(
                    AnimatedEmojis.pencil,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedRange.getTitle(l10n),
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeLG,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppWidgetTheme.spaceMD),
              // Time range selector (simplified)
              _buildTimeRangeSelector(textColor),
              const SizedBox(height: AppWidgetTheme.spaceXL),
              _buildFlChart(context, displayData, textColor, progressData),
              const SizedBox(height: AppWidgetTheme.spaceLG),
              _buildCompactStats(stats, textColor),
            ],
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector(Color textColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TimeRange.values.map((range) {
        final isSelected = _selectedRange == range;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRange = range;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? textColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : textColor.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              range.label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: AppWidgetTheme.fontSizeSM,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlChart(BuildContext context, List<WeightDataPoint> displayData, Color textColor, ProgressData progressData) {
    if (displayData.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    final weights = displayData.map((e) => _toDisplayWeight(e.weight)).toList();

    // Include starting weight and target weight in range calculation
    if (progressData.startingWeight != null) {
      weights.add(_toDisplayWeight(progressData.startingWeight!));
    }
    if (widget.targetWeight != null) {
      weights.add(_toDisplayWeight(widget.targetWeight!));
    }

    // Safety check: should never happen due to displayData.isEmpty check above
    // but adding defensive programming for robustness
    if (weights.isEmpty) {
      return const SizedBox.shrink();
    }

    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    // Dynamic buffer: 5% of range, minimum 2 units for readability
    final range = maxWeight - minWeight;
    final buffer = range > 0 ? (range * 0.05).clamp(2.0, double.infinity) : 2.0;

    // Round boundaries based on unit system
    final spacing = widget.isMetric ? _metricSpacing : _imperialSpacing;
    final rawMinY = (minWeight - buffer).floor();
    final rawMaxY = (maxWeight + buffer).ceil();

    final minY = widget.isMetric
        ? (rawMinY % 2 == 1 ? rawMinY : rawMinY - 1).toDouble()  // Odd numbers for metric
        : _roundDownToMultiple(rawMinY, spacing).toDouble();     // Multiples of 4 for imperial

    final maxY = widget.isMetric
        ? (rawMaxY % 2 == 1 ? rawMaxY : rawMaxY + 1).toDouble()  // Odd numbers for metric
        : _roundUpToMultiple(rawMaxY, spacing).toDouble();       // Multiples of 4 for imperial

    // Weight data line
    final weightSpots = displayData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), _toDisplayWeight(entry.value.weight));
    }).toList();

    // Guideline from starting weight (left) to goal weight (right)
    final List<FlSpot> guidelineSpots = [];
    if (progressData.startingWeight != null && widget.targetWeight != null && displayData.isNotEmpty) {
      guidelineSpots.add(FlSpot(0, _toDisplayWeight(progressData.startingWeight!)));
      guidelineSpots.add(FlSpot((displayData.length - 1).toDouble(), _toDisplayWeight(widget.targetWeight!)));
    }

    // Calculate Y-axis interval for clean labels
    final yRange = maxY - minY;
    final yInterval = _calculateNiceInterval(yRange, 4);

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(textColor, AppWidgetTheme.opacityVeryLight),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
        border: Border.all(
          color: textColor.withValues(alpha: AppWidgetTheme.opacityMediumHigh),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            // Actual weight line
            LineChartBarData(
              spots: weightSpots,
              isCurved: true,
              color: textColor,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final point = displayData[index];

                  // Hollow dots for forward-filled values
                  if (point.isForwardFilled) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.transparent,
                      strokeWidth: 2,
                      strokeColor: textColor,
                    );
                  }

                  // Filled dots for actual values
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: textColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    textColor.withValues(alpha: 0.3),
                    textColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
            // Guideline from starting weight to goal weight (diagonal)
            if (guidelineSpots.isNotEmpty)
              LineChartBarData(
                spots: guidelineSpots,
                isCurved: false,
                color: textColor.withValues(alpha: 0.35),
                barWidth: 1.5,
                dashArray: [8, 4],
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    // Start point (left) - Green circle (30% smaller)
                    if (index == 0) {
                      return FlDotCirclePainter(
                        radius: 4.2,
                        color: Colors.green.withValues(alpha: 0.8),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    }
                    // Goal point (right) - Blue circle (30% smaller)
                    else {
                      return FlDotCirclePainter(
                        radius: 4.2,
                        color: Colors.blue.withValues(alpha: 0.8),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    }
                  },
                ),
                belowBarData: BarAreaData(show: false),
              ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  final intValue = value.toInt();

                  // Filter labels based on unit system
                  final shouldShow = widget.isMetric
                      ? intValue % 2 == 1  // Odd numbers only for metric
                      : intValue % _imperialSpacing == 0;  // Multiples of 4 for imperial

                  if (!shouldShow) {
                    return const SizedBox.shrink();
                  }

                  return Text(
                    intValue.toString(),
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeXS,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < displayData.length) {
                    final format = _selectedRange == TimeRange.oneYear
                        ? 'M/yy'
                        : 'M/d';
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat(format).format(displayData[index].timestamp),
                        style: TextStyle(
                          fontSize: AppWidgetTheme.fontSizeXS,
                          color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: textColor.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
              // Allow editing on ALL ranges, including hollow dots
              if (event is FlTapUpEvent &&
                  touchResponse != null &&
                  touchResponse.lineBarSpots != null) {
                final spot = touchResponse.lineBarSpots!.first;
                final index = spot.x.toInt();
                if (index >= 0 && index < displayData.length) {
                  final point = displayData[index];
                  if (point.isForwardFilled) {
                    // Tapping hollow dot: create new entry at this timestamp
                    _showAddDialog(context, point.timestamp, point.weight, progressData);
                  } else if (point.originalData != null) {
                    // Tapping filled dot: edit existing entry
                    _showEditDialog(context, point.originalData!, progressData);
                  }
                }
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < displayData.length) {
                    final point = displayData[index];
                    final unit = widget.isMetric ? l10n.kg : l10n.lbs;
                    String suffix = '';
                    if (point.isForwardFilled) {
                      suffix = ' ${l10n.tapToAdd}';
                    }
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} $unit$suffix\n${DateFormat('MMM d').format(displayData[index].timestamp)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppWidgetTheme.fontSizeSM,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate interval for Y-axis labels
  /// Returns 1.0 so fl_chart generates all integers, then we filter in getTitlesWidget:
  /// - Metric: Show odd numbers only (2 kg spacing)
  /// - Imperial: Show multiples of 4 only (4 lbs spacing)
  double _calculateNiceInterval(double range, int targetDivisions) {
    return 1.0; // Generate all integers, filter based on unit system
  }

  void _showEditDialog(BuildContext context, WeightData entry, ProgressData progressData) {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    showWeightEditDialog(
      context: context,
      entry: entry,
      isMetric: widget.isMetric,
      targetWeight: progressData.targetWeight,
      startingWeight: progressData.startingWeight,
      onSave: (entryId, weight, timestamp, note) async {
        await progressData.updateWeightEntry(entryId, weight, timestamp, note);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.weightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveTarget: (targetWeight) async {
        await progressData.updateTargetWeight(targetWeight);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.targetWeightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveStartingWeight: (startingWeight) async {
        await settingsProvider.updateStartingWeight(startingWeight);

        // Reload progress data to refresh the UI with new starting weight
        await progressData.refreshData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.startingWeightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showAddDialog(BuildContext context, DateTime timestamp, double carriedWeight, ProgressData progressData) {
    final settingsProvider = context.read<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    showWeightEditDialog(
      context: context,
      initialWeight: carriedWeight,
      isMetric: widget.isMetric,
      targetWeight: progressData.targetWeight,
      startingWeight: progressData.startingWeight,
      onAddWeight: (weight, isMetric) async {
        // Add new entry with the specific timestamp
        await progressData.addWeightEntryWithTimestamp(weight, timestamp, isMetric);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.weightEntryAddedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveTarget: (targetWeight) async {
        await progressData.updateTargetWeight(targetWeight);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.targetWeightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveStartingWeight: (startingWeight) async {
        await settingsProvider.updateStartingWeight(startingWeight);

        // Reload progress data to refresh the UI with new starting weight
        await progressData.refreshData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.startingWeightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Widget _buildCompactStats(Map<String, double> stats, Color textColor) {
    final l10n = AppLocalizations.of(context)!;

    final statsToShow = [
      {'label': l10n.totalChange, 'value': '${_toDisplayWeight(stats['totalChange']!) >= 0 ? '+' : ''}${_toDisplayWeight(stats['totalChange']!).toStringAsFixed(1)}'},
      {'label': l10n.average, 'value': _toDisplayWeight(stats['average']!).toStringAsFixed(1)},
      {'label': l10n.weeklyRate, 'value': '${_toDisplayWeight(stats['weeklyRate']!) >= 0 ? '+' : ''}${_toDisplayWeight(stats['weeklyRate']!).toStringAsFixed(1)}'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
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
        const SizedBox(height: AppWidgetTheme.spaceXXS),
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
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassCardStyle.blurSigma,
          sigmaY: GlassCardStyle.blurSigma,
        ),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
            border: Border.all(
              color: textColor.withValues(alpha: GlassCardStyle.borderOpacity),
              width: GlassCardStyle.borderWidth,
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
          const SizedBox(height: AppWidgetTheme.spaceLG),
          Text(
            l10n.noWeightHistory,
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeLG,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppWidgetTheme.spaceXS),
          Text(
            l10n.addWeightEntriesToSeeCharts,
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
        ),
      ),
    );
  }
}
