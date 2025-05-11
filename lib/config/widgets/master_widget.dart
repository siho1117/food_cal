import 'package:flutter/material.dart';
import '../design_system/theme.dart';
import '../design_system/text_styles.dart';
import '../components/state_builder.dart';
import '../components/value_builder.dart';
import '../components/box_decorations.dart';

/// A master widget template that serves as the foundation for content widgets.
/// Standardized with fixed header height, consistent button placement.
class MasterWidget extends StatefulWidget {
  // Core properties
  final String title;
  final IconData icon; // Keep for backwards compatibility but not used
  final Widget child;
  
  // Header customization
  final Widget? trailing; // Optional trailing widget for the header (button)
  final VoidCallback? onHeaderTap;
  final Color? iconColor; // Keep for backwards compatibility but not used
  final Color? textColor;
  
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
  
  // Animation controller
  final AnimationController? animationController;

  // Standard header dimensions
  static const double _headerTitleFontSize = 18.0; // Increased from 16.0
  static const double _headerButtonSize = 20.0;
  static const double _headerHeight = 56.0;

  const MasterWidget({
    Key? key,
    required this.title,
    required this.icon, // Keep for backwards compatibility but not used
    required this.child,
    this.trailing,
    this.onHeaderTap,
    this.iconColor = AppTheme.textDark, // Keep for backwards compatibility but not used
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
    this.animationController,
  }) : super(key: key);

  /// Creates a data-focused widget with appropriate styling
  static MasterWidget dataWidget({
    required String title,
    required IconData icon, // Keep for backwards compatibility but not used
    required Widget child,
    bool isLoading = false,
    bool hasError = false,
    String? errorMessage,
    VoidCallback? onRetry,
    Widget? trailing,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark, // Keep for backwards compatibility but not used
    AnimationController? animationController,
  }) => MasterWidget(
    title: title,
    icon: icon, // Keep for backwards compatibility but not used
    child: child,
    isLoading: isLoading,
    hasError: hasError,
    errorMessage: errorMessage,
    onRetry: onRetry,
    trailing: trailing,
    accentColor: accentColor,
    useGradient: true,
    textColor: textColor,
    iconColor: iconColor, // Keep for backwards compatibility but not used
    animationController: animationController,
  );
  
  /// Creates a metric display widget with value emphasis
  static MasterWidget metricWidget({
    required String title,
    required IconData icon, // Keep for backwards compatibility but not used
    required Widget valueWidget,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark, // Keep for backwards compatibility but not used
    Widget? trailing,
    Widget? footer,
    AnimationController? animationController,
  }) => MasterWidget(
    title: title,
    icon: icon, // Keep for backwards compatibility but not used
    accentColor: accentColor ?? AppTheme.primaryBlue,
    footer: footer,
    trailing: trailing,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Center(child: valueWidget),
    textColor: textColor,
    iconColor: iconColor, // Keep for backwards compatibility but not used
    animationController: animationController,
  );
  
  /// Creates a progress tracking widget with appropriate styling
  static MasterWidget progressWidget({
    required String title,
    required IconData icon, // Keep for backwards compatibility but not used
    required double progress,
    required Widget child,
    String? progressText,
    Color? progressColor,
    Widget? trailing,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark, // Keep for backwards compatibility but not used
    AnimationController? animationController,
  }) {
    final Color color = progressColor ?? AppTheme.accentColor;
    
    return MasterWidget(
      title: title,
      icon: icon, // Keep for backwards compatibility but not used
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
      iconColor: iconColor, // Keep for backwards compatibility but not used
      animationController: animationController,
    );
  }
  
  /// Creates a comparison widget 
  static MasterWidget comparisonWidget({
    required String title,
    required IconData icon, // Keep for backwards compatibility but not used
    required Widget child,
    Widget? trailing,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark, // Keep for backwards compatibility but not used
    AnimationController? animationController,
  }) => MasterWidget(
    title: title,
    icon: icon, // Keep for backwards compatibility but not used
    child: child,
    trailing: trailing,
    accentColor: accentColor,
    textColor: textColor,
    iconColor: iconColor, // Keep for backwards compatibility but not used
    animationController: animationController,
  );
  
  /// Creates a highlight widget for important data
  static MasterWidget highlightWidget({
    required String title,
    required IconData icon, // Keep for backwards compatibility but not used
    required Widget child,
    Widget? trailing,
    Color? accentColor,
    Color? textColor = AppTheme.textDark,
    Color? iconColor = AppTheme.textDark, // Keep for backwards compatibility but not used
    AnimationController? animationController,
  }) => MasterWidget(
    title: title,
    icon: icon, // Keep for backwards compatibility but not used
    child: child,
    trailing: trailing,
    accentColor: accentColor ?? AppTheme.goldAccent,
    textColor: textColor,
    iconColor: iconColor, // Keep for backwards compatibility but not used
    animationController: animationController,
  );
  
  /// Helper method to create a standard edit button for the header
  /// Usage: trailing: MasterWidget.createEditButton(onPressed: _showDialog, color: textColor)
  static Widget createEditButton({
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.edit,
            size: _headerButtonSize,
            color: color,
          ),
        ),
      ),
    );
  }
  
  /// Helper method to create a standard info button for the header
  /// Usage: trailing: MasterWidget.createInfoButton(onPressed: _showInfoDialog, color: textColor)
  static Widget createInfoButton({
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.info_outline,
            size: _headerButtonSize,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  State<MasterWidget> createState() => _MasterWidgetState();
}

class _MasterWidgetState extends State<MasterWidget> with SingleTickerProviderStateMixin {
  // Animation controller for coordinating animations
  late AnimationController _animationController;
  bool _usingExternalController = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller - use provided one or create our own
    if (widget.animationController != null) {
      _animationController = widget.animationController!;
      _usingExternalController = true;
    } else {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      
      // Auto-start if we're creating our own controller
      _animationController.forward();
    }
  }
  
  @override
  void didUpdateWidget(MasterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle changes in controller provider
    if (widget.animationController != oldWidget.animationController) {
      if (!_usingExternalController) {
        // Dispose old controller if we created it
        _animationController.dispose();
      }
      
      if (widget.animationController != null) {
        _animationController = widget.animationController!;
        _usingExternalController = true;
      } else {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        );
        _usingExternalController = false;
        _animationController.forward();
      }
    }
  }
  
  @override
  void dispose() {
    // Only dispose if we created the controller
    if (!_usingExternalController) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? AppTheme.primaryBlue;
    
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
    
    // Create the base widget structure
    return Container(
      decoration: widget.useGradient 
          ? BoxDecorations.cardGradient(borderRadius: widget.borderRadius)
          : BoxDecorations.card(borderRadius: widget.borderRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section with fixed height and proper vertical alignment
          Container(
            width: double.infinity,
            height: MasterWidget._headerHeight,
            decoration: BoxDecorations.header(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHeaderWidget(),
          ),
          
          // Content section
          content,
          
          // Optional footer
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }
  
  // Build header widget with vertically centered elements but left-aligned title
  // Icon is completely removed from the header
  Widget _buildHeaderWidget() {
    // Get final color
    final textColor = widget.textColor ?? AppTheme.textDark;
    
    return InkWell(
      onTap: widget.onHeaderTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // This ensures vertical centering
        children: [
          // Left-aligned title (icon removed completely)
          Expanded(
            child: Text(
              widget.title,
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: MasterWidget._headerTitleFontSize, // Increased font size
                fontWeight: FontWeight.bold,
                color: textColor,
                height: 2, // Add some line height for better text appearance
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Right-aligned button
          if (widget.trailing != null)
            widget.trailing!,
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