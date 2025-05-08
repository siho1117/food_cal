import 'package:flutter/material.dart';
import '../theme.dart';
import '../widget_ui_design_standards.dart';
import '../decorations/box_decorations.dart';

/// Standard card layout patterns used throughout the app.
///
/// This class provides static methods for building common card layouts
/// with consistent styling, reducing code duplication.
class CardLayout {
  // Private constructor to prevent instantiation
  CardLayout._();
  
  /// Creates a standard content card with consistent styling
  static Widget card({
    required Widget child,
    Widget? header,
    Widget? footer,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(20),
    EdgeInsetsGeometry? headerPadding,
    double? borderRadius,
    bool useGradientBackground = true,
    bool isLoading = false,
    bool hasError = false,
    String? errorMessage,
    VoidCallback? onRetry,
    Color? backgroundColor,
  }) {
    // Determine the final border radius
    final radius = borderRadius ?? WidgetUIStandards.containerBorderRadius;
    
    // Determine container decoration based on gradient preference
    final decoration = useGradientBackground
        ? BoxDecorations.cardGradient(borderRadius: radius)
        : BoxDecorations.card(
            borderRadius: radius,
            backgroundColor: backgroundColor ?? Colors.white,
          );
    
    // Calculate header padding if not specified
    final headerPaddingToUse = headerPadding ?? EdgeInsets.symmetric(
      vertical: WidgetUIStandards.headerVerticalPadding,
      horizontal: WidgetUIStandards.headerHorizontalPadding,
    );
    
    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional header
            if (header != null)
              Container(
                width: double.infinity,
                padding: headerPaddingToUse,
                decoration: BoxDecorations.header(borderRadius: radius),
                child: header,
              ),
            
            // Main content - loading, error or actual content
            if (isLoading)
              _buildLoadingState()
            else if (hasError)
              _buildErrorState(errorMessage, onRetry)
            else
              Padding(
                padding: contentPadding,
                child: child,
              ),
              
            // Optional footer
            if (footer != null)
              footer,
          ],
        ),
      ),
    );
  }
  
  /// Creates a card with header and value display (for metrics)
  static Widget valueCard({
    required String title,
    required IconData icon,
    required Widget valueWidget,
    Widget? subtitle,
    Widget? badge,
    Widget? trailing,
    Color? iconColor,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(20),
    bool useGradientBackground = true,
  }) {
    return card(
      useGradientBackground: useGradientBackground,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(WidgetUIStandards.headerIconSpacing),
                decoration: BoxDecorations.iconContainer(
                  color: iconColor ?? AppTheme.primaryBlue,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppTheme.primaryBlue,
                  size: WidgetUIStandards.headerIconSize,
                ),
              ),
              const SizedBox(width: WidgetUIStandards.headerIconSpacing),
              
              // Title text
              Text(
                title,
                style: TextStyle(
                  fontSize: WidgetUIStandards.headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              
              // Optional badge
              if (badge != null) ...[
                const SizedBox(width: 8),
                badge,
              ],
            ],
          ),
          
          // Optional trailing widget
          if (trailing != null) trailing,
        ],
      ),
      contentPadding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main value widget
          valueWidget,
          
          // Optional subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            subtitle,
          ],
        ],
      ),
    );
  }
  
  /// Creates a card with a progress indicator
  static Widget progressCard({
    required String title,
    required IconData icon,
    required double progress,
    required String progressText,
    Widget? description,
    Widget? trailing,
    Color progressColor = AppTheme.primaryBlue,
    bool useGradientBackground = true,
  }) {
    return card(
      useGradientBackground: useGradientBackground,
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(WidgetUIStandards.headerIconSpacing),
                decoration: BoxDecorations.iconContainer(color: progressColor),
                child: Icon(
                  icon,
                  color: progressColor,
                  size: WidgetUIStandards.headerIconSize,
                ),
              ),
              const SizedBox(width: WidgetUIStandards.headerIconSpacing),
              
              // Title text
              Text(
                title,
                style: TextStyle(
                  fontSize: WidgetUIStandards.headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          
          // Optional trailing widget
          if (trailing != null) trailing,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).round()}% complete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: progressColor,
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          
          // Optional description
          if (description != null) ...[
            const SizedBox(height: 16),
            description,
          ],
        ],
      ),
    );
  }
  
  /// Creates a card with a message (info, warning, error)
  static Widget messageCard({
    required String title,
    required String message,
    required IconData icon,
    Color color = AppTheme.primaryBlue,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return card(
      useGradientBackground: false,
      backgroundColor: color.withOpacity(0.05),
      borderRadius: 12,
      contentPadding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          
          const SizedBox(width: 16),
          
          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                
                // Optional action button
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