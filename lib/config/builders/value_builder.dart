// lib/config/builders/value_builder.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../text_styles.dart';
import '../widget_ui_design_standards.dart';
import '../decorations/box_decorations.dart';

/// Utility class for building value displays and card layouts throughout the app.
///
/// This class provides static methods for creating consistent
/// display of numeric values, stats, and formatted text,
/// as well as card layouts for content presentation.
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(12),
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
  
  //-----------------------------------------------------------------------------
  // CARD LAYOUT UTILITIES
  //-----------------------------------------------------------------------------
  
  /// Creates a standard content card with consistent styling
  static Widget buildCard({
    required Widget child,
    Widget? header,
    Widget? footer,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(20),
    bool useGradientBackground = true,
    bool isLoading = false,
    bool hasError = false,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    final radius = WidgetUIStandards.containerBorderRadius;
    final decoration = useGradientBackground
        ? BoxDecorations.cardGradient()
        : BoxDecorations.card();
    
    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                decoration: BoxDecorations.header(),
                child: header,
              ),
            if (isLoading)
              _buildLoadingState()
            else if (hasError)
              _buildErrorState(errorMessage, onRetry)
            else
              Padding(
                padding: contentPadding,
                child: child,
              ),
            if (footer != null)
              footer,
          ],
        ),
      ),
    );
  }
  
  /// Creates a value card for metric displays
  static Widget buildValueCard({
    required String title,
    required IconData icon,
    required Widget valueWidget,
    Widget? subtitle,
    Widget? badge,
    Widget? trailing,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppTheme.primaryBlue;
    
    return buildCard(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecorations.iconContainer(color: color),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.getSubHeadingStyle().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: badge,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          valueWidget,
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: subtitle,
            ),
        ],
      ),
    );
  }
  
  /// Creates a progress card with indicator
  static Widget buildProgressCard({
    required String title,
    required IconData icon,
    required double progress,
    String? progressText,
    Widget? content,
    Widget? trailing,
    Color progressColor = AppTheme.accentColor,
  }) {
    return buildCard(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecorations.iconContainer(color: progressColor),
                child: Icon(
                  icon,
                  color: progressColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content != null) ...[
            content,
            const SizedBox(height: 20),
          ],
          buildProgressBar(
            progress: progress,
            valueLabel: progressText,
            color: progressColor,
          ),
        ],
      ),
    );
  }
  
  /// Creates a message card for info, warning, or error messages
  static Widget buildMessageCard({
    required String title,
    required String message,
    required IconData icon,
    Color color = AppTheme.primaryBlue,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                if (onAction != null && actionText != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      foregroundColor: color,
                    ),
                    child: Text(actionText),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Standard loading state widget
  static Widget _buildLoadingState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// Standard error state widget
  static Widget _buildErrorState(String? message, VoidCallback? onRetry) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}