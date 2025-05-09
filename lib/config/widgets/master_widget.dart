// lib/config/widgets/master_widget.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../text_styles.dart';
import '../widget_ui_design_standards.dart';
import '../dimensions.dart';
import '../decorations/box_decorations.dart';
import '../animations/animation_helpers.dart';

/// A master widget template that serves as the foundation for content widgets throughout the app.
/// 
/// This widget provides consistent styling, animation, and state handling for all content widgets.
/// It consolidates functionality from CardLayout, HeaderLayout, and other utilities into a single
/// comprehensive component.
/// 
/// Usage:
/// ```dart
/// MasterWidget(
///   title: 'My Widget',
///   icon: Icons.star,
///   child: Text('Content goes here'),
/// )
/// ```
class MasterWidget extends StatefulWidget {
  // Core properties
  final String title;
  final IconData icon;
  final Widget child;
  
  // Header customization
  final Widget? trailing;
  final String? subtitle;
  final Widget? badge;
  final VoidCallback? onHeaderTap;
  
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
  
  // Animation
  final bool animate;
  final Duration animationDuration;

  const MasterWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.subtitle,
    this.badge,
    this.onHeaderTap,
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
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
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
    String? subtitle,
  }) {
    return MasterWidget(
      title: title,
      icon: icon,
      child: child,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      onRetry: onRetry,
      trailing: trailing,
      subtitle: subtitle,
      useGradient: true,
    );
  }
  
  /// Creates a metric display widget with value emphasis
  static MasterWidget metricWidget({
    required String title,
    required IconData icon,
    required Widget valueWidget,
    Color accentColor = AppTheme.primaryBlue,
    String? subtitle,
    Widget? footer,
  }) {
    return MasterWidget(
      title: title,
      icon: icon,
      accentColor: accentColor,
      subtitle: subtitle,
      footer: footer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: Center(
        child: valueWidget,
      ),
    );
  }
  
  /// Creates a progress tracking widget
  static MasterWidget progressWidget({
    required String title,
    required IconData icon,
    required double progress,
    required Widget child,
    String? progressText,
    Color progressColor = AppTheme.accentColor,
    Widget? trailing,
  }) {
    return MasterWidget(
      title: title,
      icon: icon,
      accentColor: progressColor,
      trailing: trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child content first
          child,
          
          const SizedBox(height: 20),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              
              if (progressText != null) ...[
                const SizedBox(height: 8),
                Text(
                  progressText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500, 
                    color: progressColor,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  @override
  State<MasterWidget> createState() => _MasterWidgetState();
}

class _MasterWidgetState extends State<MasterWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Map<String, Animation<dynamic>> _animations;

  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    
    _animations = AnimationHelpers.createEntranceAnimations(
      controller: _animationController,
      initialScale: 0.95,
    );
    
    // Start animations if enabled
    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(MasterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset and restart animations if key properties change
    if (oldWidget.isLoading != widget.isLoading || 
        oldWidget.hasError != widget.hasError ||
        oldWidget.isEmpty != widget.isEmpty) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? WidgetUIStandards.containerBorderRadius;
    final accentColor = widget.accentColor ?? AppTheme.primaryBlue;
    
    return Container(
      decoration: widget.useGradient 
          ? BoxDecorations.cardGradient(borderRadius: radius)
          : BoxDecorations.card(borderRadius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          _buildHeader(accentColor),
          
          // Content section with states
          _buildContent(accentColor),
          
          // Optional footer
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }
  
  /// Builds the header section with title, icon, and optional elements
  Widget _buildHeader(Color accentColor) {
    return GestureDetector(
      onTap: widget.onHeaderTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          WidgetUIStandards.headerHorizontalPadding,
          WidgetUIStandards.headerVerticalPadding,
          WidgetUIStandards.headerHorizontalPadding,
          WidgetUIStandards.headerVerticalPadding,
        ),
        decoration: BoxDecorations.header(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title section with icon
            Expanded(
              child: Row(
                children: [
                  // Icon with background
                  Container(
                    padding: const EdgeInsets.all(WidgetUIStandards.headerIconSpacing),
                    decoration: BoxDecorations.iconContainer(color: accentColor),
                    child: Icon(
                      widget.icon,
                      color: accentColor,
                      size: WidgetUIStandards.headerIconSize,
                    ),
                  ),
                  
                  const SizedBox(width: WidgetUIStandards.headerIconSpacing),
                  
                  // Title and optional subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with optional badge
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                style: AppTextStyles.getSubHeadingStyle().copyWith(
                                  fontSize: WidgetUIStandards.headerFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.badge != null) ...[
                              const SizedBox(width: 8),
                              widget.badge!,
                            ],
                          ],
                        ),
                        
                        // Optional subtitle
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Optional trailing widget
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
  
  /// Builds the content section based on current state
  Widget _buildContent(Color accentColor) {
    // Handle different states
    if (widget.isLoading) {
      return _buildLoadingState();
    } else if (widget.hasError) {
      return _buildErrorState();
    } else if (widget.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildNormalContent();
    }
  }
  
  /// Builds the normal content with animations
  Widget _buildNormalContent() {
    if (widget.animate) {
      return AnimationHelpers.applyAnimations(
        animations: _animations,
        child: Padding(
          padding: widget.contentPadding,
          child: widget.child,
        ),
      );
    } else {
      return Padding(
        padding: widget.contentPadding,
        child: widget.child,
      );
    }
  }
  
  /// Builds the loading state
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// Builds the error state
  Widget _buildErrorState() {
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
            widget.errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRetry,
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
  
  /// Builds the empty state
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.emptyIcon,
            color: Colors.grey[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'No data available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}