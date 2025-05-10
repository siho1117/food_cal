// lib/config/components/value_builder.dart
import 'package:flutter/material.dart';
import '../design_system/theme.dart';
import '../design_system/text_styles.dart';
import '../components/box_decorations.dart';

/// Utility class for building value displays throughout the app.
///
/// This class provides static methods for creating consistent
/// presentation of numeric values, stats, and formatted text.
/// It focuses solely on value presentation rather than layout.
class ValueBuilder {
  // Private constructor to prevent instantiation
  ValueBuilder._();
  
  //-----------------------------------------------------------------------------
  // VALUE DISPLAY UTILITIES
  //-----------------------------------------------------------------------------
  
  /// Creates a standard numeric value display with large font
  static Widget buildNumericValue({
    required String value,
    String? unit,
    TextStyle? valueStyle,
    TextStyle? unitStyle,
    Color? color,
    TextAlign align = TextAlign.center,
  }) {
    final defaultValueStyle = AppTextStyles.getNumericStyle().copyWith(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: color ?? AppTheme.primaryBlue,
    );
    
    final defaultUnitStyle = AppTextStyles.getNumericStyle().copyWith(
      fontSize: 16,
      color: (color ?? AppTheme.primaryBlue).withOpacity(0.8),
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: valueStyle ?? defaultValueStyle,
          textAlign: align,
        ),
        if (unit != null)
          Text(
            unit,
            style: unitStyle ?? defaultUnitStyle,
            textAlign: align,
          ),
      ],
    );
  }
  
  /// Creates a numeric value with subtitle below it
  static Widget buildValueWithSubtitle({
    required String value,
    required String subtitle,
    String? unit,
    Color? valueColor,
    TextAlign align = TextAlign.center,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildNumericValue(
          value: value,
          unit: unit,
          color: valueColor,
          align: align,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: align,
        ),
      ],
    );
  }
  
  /// Creates a percentage display (e.g. "75%")
  static Widget buildPercentage({
    required double percentage,
    Color? color,
    TextStyle? style,
    bool showSymbol = true,
  }) {
    final validPercentage = percentage.clamp(0.0, 1.0) * 100;
    final text = showSymbol
        ? '${validPercentage.round()}%'
        : '${validPercentage.round()}';
    
    return Text(
      text,
      style: style ?? TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: color ?? AppTheme.primaryBlue,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  /// Creates a stat row with label and value
  static Widget buildStatRow({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }
  
  /// Creates a badge with text and background color
  static Widget buildBadge({
    required String text,
    required Color color,
    double opacity = 0.1,
    TextStyle? textStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecorations.badge(
        color: color,
        opacity: opacity,
      ),
      child: Text(
        text,
        style: textStyle ?? TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  /// Creates a progress bar with label and value
  static Widget buildProgressBar({
    required double progress,
    String? label,
    String? valueLabel,
    Color color = AppTheme.primaryBlue,
    double height = 8.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || valueLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                if (valueLabel != null)
                  Text(
                    valueLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: height,
          ),
        ),
      ],
    );
  }
  
  /// Creates a color indicator with label
  static Widget buildColorIndicator({
    required String label, 
    required Color color,
    double size = 10.0,
    double spacing = 6.0,
    TextStyle? labelStyle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: spacing),
        Text(
          label,
          style: labelStyle ?? TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  /// Creates a legend with multiple color indicators
  static Widget buildLegend({
    required List<String> labels,
    required List<Color> colors,
    Axis direction = Axis.horizontal,
    double spacing = 12.0,
    double indicatorSize = 10.0,
    TextStyle? labelStyle,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  }) {
    final indicators = List.generate(
      labels.length,
      (index) => buildColorIndicator(
        label: labels[index],
        color: colors[index],
        size: indicatorSize,
        labelStyle: labelStyle,
      ),
    );
    
    // Build horizontal or vertical layout with manual spacing
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        children: _addSpacers(indicators, SizedBox(width: spacing)),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _addSpacers(indicators, SizedBox(height: spacing)),
      );
    }
  }
  
  /// Helper method to add spacers between widgets
  static List<Widget> _addSpacers(List<Widget> widgets, Widget spacer) {
    if (widgets.isEmpty) return [];
    if (widgets.length == 1) return [widgets[0]];
    
    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }
  
  /// Creates a data row with label and value
  static Widget buildDataRow({
    required String label,
    required String value,
    bool bold = false,
    Color? valueColor,
    double fontSize = 14.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Creates a calorie display with optional unit
  static Widget buildCalorieDisplay({
    required int calories,
    Color? color,
    bool showUnit = true,
    TextStyle? valueStyle,
    TextStyle? unitStyle,
  }) {
    return buildNumericValue(
      value: calories.toString(),
      unit: showUnit ? 'cal' : null,
      color: color,
      valueStyle: valueStyle,
      unitStyle: unitStyle,
    );
  }
}