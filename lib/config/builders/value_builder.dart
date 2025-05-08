import 'package:flutter/material.dart';
import '../text_styles.dart';
import '../theme.dart';

/// Utility class for building value displays throughout the app.
///
/// This class provides static methods for creating consistent
/// display of numeric values, stats, and formatted text.
class ValueBuilder {
  // Private constructor to prevent instantiation
  ValueBuilder._();
  
  /// Creates a standard numeric value display with large font
  static Widget buildNumericValue({
    required String value,
    String? unit,
    TextStyle? valueStyle,
    TextStyle? unitStyle,
    Color? color,
    TextAlign align = TextAlign.center,
    CrossAxisAlignment crossAlign = CrossAxisAlignment.baseline,
    TextBaseline textBaseline = TextBaseline.alphabetic,
  }) {
    // Default styles if not provided
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
      crossAxisAlignment: crossAlign,
      textBaseline: textBaseline,
      children: [
        // Main value
        Text(
          value,
          style: valueStyle ?? defaultValueStyle,
          textAlign: align,
        ),
        
        // Optional unit
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
        // Main value
        buildNumericValue(
          value: value,
          unit: unit,
          color: valueColor,
          align: align,
        ),
        
        // Subtitle
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
    TextAlign align = TextAlign.center,
  }) {
    // Ensure percentage is within 0-100 range
    final validPercentage = percentage.clamp(0.0, 1.0) * 100;
    
    // Build text with percentage symbol
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
      textAlign: align,
    );
  }
  
  /// Creates a stat row with label and value
  static Widget buildStatRow({
    required String label,
    required String value,
    IconData? icon,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label with optional icon
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: iconColor ?? Colors.grey[600],
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
        
        // Value
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
  
  /// Creates a trio of stats in a row (useful for macronutrients)
  static Widget buildStatTrio({
    required String label1,
    required String value1,
    required Color color1,
    required String label2, 
    required String value2,
    required Color color2,
    required String label3,
    required String value3, 
    required Color color3,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First stat
        _buildSingleStat(
          label: label1,
          value: value1,
          color: color1,
        ),
        
        // Second stat
        _buildSingleStat(
          label: label2,
          value: value2,
          color: color2,
        ),
        
        // Third stat
        _buildSingleStat(
          label: label3,
          value: value3,
          color: color3,
        ),
      ],
    );
  }
  
  // Helper for building a single stat in the trio
  static Widget _buildSingleStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        // Value
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
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
    double borderRadius = 12,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
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
  
  /// Creates a classification badge (e.g. "Normal", "High", etc.)
  static Widget buildClassificationBadge({
    required String classification,
    required Color color,
  }) {
    return buildBadge(
      text: classification,
      color: color,
    );
  }
  
  /// Creates a calorie display with value and optional label
  static Widget buildCalorieDisplay({
    required int calories,
    String? label,
    Color color = AppTheme.primaryBlue,
    bool showUnit = true,
    TextAlign align = TextAlign.center,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Calorie value
        buildNumericValue(
          value: calories.toString(),
          unit: showUnit ? ' cal' : null,
          color: color,
          align: align,
        ),
        
        // Optional label
        if (label != null)
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: align,
          ),
      ],
    );
  }
}