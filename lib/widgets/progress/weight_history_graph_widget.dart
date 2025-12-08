// lib/widgets/progress/weight_history_graph_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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

class _WeightHistoryGraphWidgetState extends State<WeightHistoryGraphWidget> {
  TimeRange _selectedRange = TimeRange.sevenDays;

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

  Map<String, double> _calculateStats(List<WeightDataPoint> data) {
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
              // Title
              Text(
                _selectedRange.getTitle(l10n),
                style: TextStyle(
                  fontSize: AppWidgetTheme.fontSizeLG,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textColor,
                ),
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
    final weights = displayData.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    // Add ±2kg buffer with whole numbers
    final minY = (minWeight - 2).floorToDouble();
    final maxY = (maxWeight + 2).ceilToDouble();

    // Weight data line
    final weightSpots = displayData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    // Target weight line (horizontal)
    final List<FlSpot> targetSpots = [];
    if (widget.targetWeight != null && displayData.isNotEmpty) {
      targetSpots.add(FlSpot(0, widget.targetWeight!));
      targetSpots.add(FlSpot((displayData.length - 1).toDouble(), widget.targetWeight!));
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
            // Target weight reference line (horizontal)
            if (targetSpots.isNotEmpty)
              LineChartBarData(
                spots: targetSpots,
                isCurved: false,
                color: textColor.withValues(alpha: 0.5),
                barWidth: 2,
                dashArray: [5, 5],
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: yInterval,
                getTitlesWidget: (value, meta) {
                  final unit = widget.isMetric ? l10n.kg : l10n.lbs;
                  return Text(
                    '${value.toStringAsFixed(0)} $unit',
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

  /// Calculate a nice interval for Y-axis labels based on range
  /// Small range (< 10kg): Every 2kg
  /// Medium range (10-20kg): Every 5kg
  /// Large range (> 20kg): Every 10kg
  double _calculateNiceInterval(double range, int targetDivisions) {
    if (range < 10) {
      return 2.0;
    } else if (range < 20) {
      return 5.0;
    } else {
      return 10.0;
    }
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
      {'label': l10n.totalChange, 'value': '${stats['totalChange']! >= 0 ? '+' : ''}${stats['totalChange']!.toStringAsFixed(1)}'},
      {'label': l10n.average, 'value': stats['average']!.toStringAsFixed(1)},
      {'label': l10n.weeklyRate, 'value': '${stats['weeklyRate']! >= 0 ? '+' : ''}${stats['weeklyRate']!.toStringAsFixed(1)}'},
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
