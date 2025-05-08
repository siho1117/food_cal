import 'package:flutter/material.dart';
import '../theme.dart';

/// Utility class for building consistent loading and error states.
///
/// This class provides standardized widgets for loading indicators,
/// error messages, and empty states to maintain consistency.
class LoadingErrorBuilder {
  // Private constructor to prevent instantiation
  LoadingErrorBuilder._();
  
  /// Standard loading indicator with optional message
  static Widget buildLoadingIndicator({
    String? message,
    double size = 36.0,
    Color? color,
    bool useCard = false,
    double height = 200.0,
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Spinner
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppTheme.primaryBlue,
            ),
            strokeWidth: size / 8,
          ),
        ),
        
        // Optional message
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
    
    // Wrap in card if requested
    if (useCard) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: content),
      );
    }
    
    // Otherwise just return the content
    return Center(
      child: content,
    );
  }
  
  /// Standard error display with icon, message and retry button
  static Widget buildErrorState({
    String? message,
    VoidCallback? onRetry,
    bool useCard = false,
    double height = 200.0,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.red,
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon
        Icon(
          icon,
          color: iconColor,
          size: 48,
        ),
        
        const SizedBox(height: 16),
        
        // Error message
        Text(
          message ?? 'An error occurred',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        // Optional retry button
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ],
      ],
    );
    
    // Wrap in card if requested
    if (useCard) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: content),
      );
    }
    
    // Otherwise just return the content
    return Center(
      child: content,
    );
  }
  
  /// Standard empty state display for when no data exists
  static Widget buildEmptyState({
    required String message,
    IconData icon = Icons.inbox,
    String? actionLabel,
    VoidCallback? onAction,
    bool useCard = false,
    double height = 200.0,
  }) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Icon(
          icon,
          color: Colors.grey[400],
          size: 48,
        ),
        
        const SizedBox(height: 16),
        
        // Message
        Text(
          message,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        
        // Optional action button
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ],
    );
    
    // Wrap in card if requested
    if (useCard) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: content),
      );
    }
    
    // Otherwise just return the content
    return Center(
      child: content,
    );
  }
  
  /// Standard placeholder for when data is not set
  static Widget buildNotSetPlaceholder({
    String message = 'Not set',
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            // Add icon if tappable
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Widget builder pattern for handling async data states
  static Widget buildAsyncState<T>({
    required AsyncSnapshot<T> snapshot,
    required Widget Function(T data) builder,
    String? loadingMessage,
    String? errorMessage,
    String? emptyMessage,
    VoidCallback? onRetry,
    bool useCard = false,
    double height = 200.0,
    bool Function(T data)? isEmpty,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return buildLoadingIndicator(
        message: loadingMessage,
        useCard: useCard,
        height: height,
      );
    } else if (snapshot.hasError) {
      return buildErrorState(
        message: errorMessage ?? 'Error: ${snapshot.error}',
        onRetry: onRetry,
        useCard: useCard,
        height: height,
      );
    } else if (!snapshot.hasData || 
               snapshot.data == null ||
               (isEmpty != null && isEmpty(snapshot.data as T))) {
      return buildEmptyState(
        message: emptyMessage ?? 'No data available',
        useCard: useCard,
        height: height,
      );
    } else {
      return builder(snapshot.data as T);
    }
  }
}