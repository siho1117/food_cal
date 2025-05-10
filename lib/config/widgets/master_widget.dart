import 'package:flutter/material.dart';
import '../design_system/theme.dart';
import '../design_system/text_styles.dart';
import '../components/state_builder.dart';
import '../components/value_builder.dart';
import '../components/box_decorations.dart';

/// A master widget template that serves as the foundation for content widgets.
/// Simplified to focus on structure and layout without animations.
class MasterWidget extends StatefulWidget {
  // Core properties
  final String title;
  final IconData icon;
  final Widget child;
  
  // Header customization
  final Widget? trailing;
  final VoidCallback? onHeaderTap;
  final Color? iconColor;
  final Color? textColor;
  final bool showInfoButton;
  final VoidCallback? onInfoTap;
  
  // Layout customization
  final EdgeInsetsGeometry contentPadding;
  final Widget? footer;
  final bool useGradient;
  final Color? accentColor;
  final double? borderRadius;

  // State handling
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final String? emptyMessage;
  final IconData emptyIcon;

  const MasterWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.onHeaderTap,
    this.iconColor = AppTheme.textDark,
    this.textColor = AppTheme.textDark,
    this.contentPadding = const EdgeInsets.all(20),
    this.footer,
    this.useGradient = true,
    this.accentColor,
    this.borderRadius,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyMessage,
    this.emptyIcon = Icons.inbox,
    this.showInfoButton = false,
    this.onInfoTap,
  }) : super(key: key);

  /// Creates a data-focused widget with appropriate styling
  static MasterWidget dataWidget({
    required String title,
    required IconData icon,
    required Widget child,
    bool isLoading = false,
    bool hasError = false,
    String? errorMessage,
    VoidCallback? onRetry,
    Widget? trailing,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark,
    bool showInfoButton = false,
    VoidCallback? onInfoTap,
  }) => MasterWidget(
    title: title,
    icon: icon,
    child: child,
    isLoading: isLoading,
    hasError: hasError,
    errorMessage: errorMessage,
    onRetry: onRetry,
    trailing: trailing,
    accentColor: accentColor,
    useGradient: true,
    textColor: textColor,
    iconColor: iconColor,
    showInfoButton: showInfoButton,
    onInfoTap: onInfoTap,
  );
  
  /// Creates a metric display widget with value emphasis
  static MasterWidget metricWidget({
    required String title,
    required IconData icon,
    required Widget valueWidget,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark,
    Widget? footer,
    bool showInfoButton = false,
    VoidCallback? onInfoTap,
  }) => MasterWidget(
    title: title,
    icon: icon,
    accentColor: accentColor ?? AppTheme.primaryBlue,
    footer: footer,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Center(child: valueWidget),
    textColor: textColor,
    iconColor: iconColor,
    showInfoButton: showInfoButton,
    onInfoTap: onInfoTap,
  );
  
  /// Creates a progress tracking widget with appropriate styling
  static MasterWidget progressWidget({
    required String title,
    required IconData icon,
    required double progress,
    required Widget child,
    String? progressText,
    Color? progressColor,
    Widget? trailing,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark,
    bool showInfoButton = false,
    VoidCallback? onInfoTap,
  }) {
    final Color color = progressColor ?? AppTheme.accentColor;
    
    return MasterWidget(
      title: title,
      icon: icon,
      accentColor: color,
      trailing: trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          const SizedBox(height: 20),
          ValueBuilder.buildProgressBar(
            progress: progress,
            valueLabel: progressText,
            color: color,
          ),
        ],
      ),
      textColor: textColor,
      iconColor: iconColor,
      showInfoButton: showInfoButton,
      onInfoTap: onInfoTap,
    );
  }
  
  /// Creates a comparison widget 
  static MasterWidget comparisonWidget({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark,
    bool showInfoButton = false,
    VoidCallback? onInfoTap,
  }) => MasterWidget(
    title: title,
    icon: icon,
    child: child,
    trailing: trailing,
    accentColor: accentColor,
    textColor: textColor,
    iconColor: iconColor,
    showInfoButton: showInfoButton,
    onInfoTap: onInfoTap,
  );
  
  /// Creates a highlight widget for important data
  static MasterWidget highlightWidget({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark,
    bool showInfoButton = false,
    VoidCallback? onInfoTap,
  }) => MasterWidget(
    title: title,
    icon: icon,
    child: child,
    accentColor: accentColor ?? AppTheme.goldAccent,
    textColor: textColor,
    iconColor: iconColor,
    showInfoButton: showInfoButton,
    onInfoTap: onInfoTap,
  );

  @override
  State<MasterWidget> createState() => _MasterWidgetState();
}

class _MasterWidgetState extends State<MasterWidget> {
  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? AppTheme.primaryBlue;
    
    // Create the header widget 
    final headerWidget = _buildHeaderWidget();
    
    // Determine the content based on the state
    Widget content;
    
    if (widget.isLoading) {
      content = _buildLoadingState();
    } else if (widget.hasError) {
      content = _buildErrorState();
    } else if (widget.isEmpty) {
      content = _buildEmptyState();
    } else {
      content = _buildContent();
    }
    
    // Create the container using BoxDecorations directly
    return Container(
      decoration: widget.useGradient 
          ? BoxDecorations.cardGradient(borderRadius: widget.borderRadius)
          : BoxDecorations.card(borderRadius: widget.borderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecorations.header(),
            child: headerWidget,
          ),
          
          // Content section
          content,
          
          // Optional footer
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }
  
  // Build header widget 
  Widget _buildHeaderWidget() {
    // Get final colors
    final textColor = widget.textColor ?? AppTheme.textDark;
    final iconColor = widget.iconColor ?? AppTheme.textDark;
    
    return InkWell(
      onTap: widget.onHeaderTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: widget.onHeaderTap != null ? Colors.grey.withAlpha((0.05 * 255).toInt()) : Colors.transparent,
      highlightColor: widget.onHeaderTap != null ? Colors.grey.withAlpha((0.05 * 255).toInt()) : Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side with icon and title
          Expanded(
            child: Row(
              children: [
                // Icon with simpler treatment - no background, just the icon
                Icon(
                  widget.icon,
                  color: iconColor,
                  size: 20,
                ),
                
                const SizedBox(width: 12),
                
                // Title - no subtitle anymore
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.getSubHeadingStyle().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Right side with info button and/or trailing widget
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info button (conditionally shown)
              if (widget.showInfoButton && widget.onInfoTap != null)
                GestureDetector(
                  onTap: widget.onInfoTap,
                  child: Container(
                    height: 28, // Fixed height to ensure consistent header height
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              
              // Optional trailing widget
              if (widget.trailing != null) 
                Padding(
                  padding: EdgeInsets.only(left: widget.showInfoButton ? 8.0 : 0),
                  child: widget.trailing!,
                ),
                
              // If no info button and no trailing widget, add an empty container 
              // to maintain consistent header height
              if (!widget.showInfoButton && widget.trailing == null)
                const SizedBox(height: 28, width: 28),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: widget.contentPadding,
      child: widget.child,
    );
  }
  
  // Using StateBuilder for loading state
  Widget _buildLoadingState() => StateBuilder.loading(
    height: 200,
    padding: const EdgeInsets.all(20),
  );
  
  // Using StateBuilder for error state
  Widget _buildErrorState() => StateBuilder.errorMessage(
    message: widget.errorMessage ?? 'An error occurred',
    actionLabel: widget.onRetry != null ? 'Try Again' : null,
    onAction: widget.onRetry,
  );
  
  // Using StateBuilder for empty state
  Widget _buildEmptyState() => StateBuilder.empty(
    message: widget.emptyMessage ?? 'No data available',
    icon: widget.emptyIcon,
  );
}