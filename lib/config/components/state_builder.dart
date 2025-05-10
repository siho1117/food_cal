// lib/config/components/state_builder.dart

import 'package:flutter/material.dart';
import '../design_system/theme.dart';

/// A utility class for building consistent state representations throughout the app.
///
/// This class provides standardized widgets for common states such as loading,
/// error, and empty states to ensure visual consistency across the application.
class StateBuilder {
  // Private constructor to prevent instantiation
  StateBuilder._();
  
  /// Creates a standard loading state with a circular progress indicator
  static Widget loading({
    double height = 200.0,
    Widget? indicator,
    String? message,
    TextStyle? messageStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20.0),
  }) {
    return Container(
      height: height,
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator ?? const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: messageStyle ?? 
                  TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Creates a standard error state with icon, message and optional retry button
  static Widget error({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.red,
    double iconSize = 48.0,
    TextStyle? messageStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20.0),
    Color actionButtonColor = AppTheme.primaryBlue,
  }) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: messageStyle ?? 
              const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: actionButtonColor,
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Creates a standard empty state with icon, message and optional action button
  static Widget empty({
    required String message,
    IconData icon = Icons.inbox,
    String? actionLabel,
    VoidCallback? onAction,
    Color? iconColor,
    double iconSize = 64.0,
    TextStyle? messageStyle,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 32.0),
    Color actionButtonColor = AppTheme.primaryBlue,
  }) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: messageStyle ?? 
                TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionButtonColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Creates an info message box for notifications, warnings, etc.
  static Widget infoMessage({
    required String message,
    String? title,
    IconData icon = Icons.info_outline,
    Color color = AppTheme.primaryBlue,
    String? actionLabel,
    VoidCallback? onAction,
    double opacity = 0.05,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(opacity * 4),
          width: 1,
        ),
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
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      foregroundColor: color,
                    ),
                    child: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Creates a warning message with appropriate styling
  static Widget warning({
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return infoMessage(
      message: message,
      title: title ?? 'Warning',
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  /// Creates an error message with appropriate styling
  static Widget errorMessage({
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return infoMessage(
      message: message,
      title: title ?? 'Error',
      icon: Icons.error_outline,
      color: Colors.red,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  /// Creates a success message with appropriate styling
  static Widget success({
    required String message,
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return infoMessage(
      message: message,
      title: title ?? 'Success',
      icon: Icons.check_circle_outline,
      color: Colors.green,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}