// lib/config/widgets/master_widget.dart
import 'package:flutter/material.dart';
import '../theme.dart';
import '../text_styles.dart';
import '../widget_ui_design_standards.dart';
import '../dimensions.dart';
import '../decorations/box_decorations.dart';
import '../animations/animation_helpers.dart';

/// Defines different animation styles for different widget types
enum WidgetAnimationType {
  /// Standard fade + scale (default)
  standard,
  
  /// Slide up from bottom
  slideUp,
  
  /// Slide in from side
  slideHorizontal,
  
  /// Expand from center
  expand,
  
  /// Emphasize with bounce
  bounce,
  
  /// No animation
  none,
}

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
  final WidgetAnimationType animationType;

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
    this.animationType = WidgetAnimationType.standard,
  }) : super(key: key);

  /// Creates a data-focused widget with appropriate styling and animations
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
    Color? accentColor,
    bool animate = true,
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
      accentColor: accentColor,
      useGradient: true,
      animate: animate,
      // Data widgets use standard animation for clean presentation
      animationType: WidgetAnimationType.standard,
    );
  }
  
  /// Creates a metric display widget with value emphasis and appropriate animations
  static MasterWidget metricWidget({
    required String title,
    required IconData icon,
    required Widget valueWidget,
    Color? accentColor,
    String? subtitle,
    Widget? footer,
    bool animate = true,
  }) {
    return MasterWidget(
      title: title,
      icon: icon,
      accentColor: accentColor ?? AppTheme.primaryBlue,
      subtitle: subtitle,
      footer: footer,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      animate: animate,
      // Metric widgets use expand animation to emphasize the value
      animationType: WidgetAnimationType.expand,
      child: Center(
        child: valueWidget,
      ),
    );
  }
  
  /// Creates a progress tracking widget with appropriate animations
  static MasterWidget progressWidget({
    required String title,
    required IconData icon,
    required double progress,
    required Widget child,
    String? progressText,
    Color? progressColor,
    Widget? trailing,
    bool animate = true,
  }) {
    final Color color = progressColor ?? AppTheme.accentColor;
    
    return MasterWidget(
      title: title,
      icon: icon,
      accentColor: color,
      trailing: trailing,
      animate: animate,
      // Progress widgets slide up to suggest improvement
      animationType: WidgetAnimationType.slideUp,
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
                valueColor: AlwaysStoppedAnimation<Color>(color),
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
                    color: color,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
  
  /// Creates a comparison widget with horizontal slide animation
  static MasterWidget comparisonWidget({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
    String? subtitle,
    Color? accentColor,
    bool animate = true,
  }) {
    return MasterWidget(
      title: title,
      icon: icon,
      child: child,
      trailing: trailing,
      subtitle: subtitle,
      accentColor: accentColor,
      animate: animate,
      // Comparison widgets slide horizontally to emphasize side-by-side comparison
      animationType: WidgetAnimationType.slideHorizontal,
    );
  }
  
  /// Creates a highlight widget with bounce animation for attention
  static MasterWidget highlightWidget({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? badge,
    Color? accentColor,
    bool animate = true,
  }) {
    return MasterWidget(
      title: title,
      icon: icon,
      child: child,
      badge: badge,
      accentColor: accentColor ?? AppTheme.goldAccent,
      animate: animate,
      // Highlight widgets bounce to draw attention
      animationType: WidgetAnimationType.bounce,
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
    
    // Create appropriate animations based on type
    _setupAnimations();
    
    // Start animations if enabled
    if (widget.animate && widget.animationType != WidgetAnimationType.none) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }
  
  /// Sets up animations based on the selected animation type
  void _setupAnimations() {
    switch (widget.animationType) {
      case WidgetAnimationType.standard:
        _animations = AnimationHelpers.createEntranceAnimations(
          controller: _animationController,
          initialScale: 0.95,
        );
        break;
        
      case WidgetAnimationType.slideUp:
        _animations = {
          'slide': AnimationHelpers.createSlideAnimation(
            controller: _animationController,
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ),
          'fade': AnimationHelpers.createFadeAnimation(
            controller: _animationController,
          ),
        };
        break;
        
      case WidgetAnimationType.slideHorizontal:
        _animations = {
          'slide': AnimationHelpers.createSlideAnimation(
            controller: _animationController,
            begin: const Offset(-0.2, 0),
            end: Offset.zero,
          ),
          'fade': AnimationHelpers.createFadeAnimation(
            controller: _animationController,
          ),
        };
        break;
        
      case WidgetAnimationType.expand:
        _animations = {
          'scale': AnimationHelpers.createScaleAnimation(
            controller: _animationController,
            begin: 0.8,
            end: 1.0,
            curve: Curves.easeOutBack,
          ),
          'fade': AnimationHelpers.createFadeAnimation(
            controller: _animationController,
          ),
        };
        break;
        
      case WidgetAnimationType.bounce:
        _animations = {
          'scale': AnimationHelpers.createScaleAnimation(
            controller: _animationController,
            begin: 0.9,
            end: 1.0,
            curve: Curves.elasticOut,
          ),
          'fade': AnimationHelpers.createFadeAnimation(
            controller: _animationController,
          ),
        };
        break;
        
      case WidgetAnimationType.none:
        _animations = {}; // Empty animations map
        break;
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
        oldWidget.isEmpty != widget.isEmpty ||
        oldWidget.animationType != widget.animationType) {
      
      // If animation type changed, recreate animations
      if (oldWidget.animationType != widget.animationType) {
        _setupAnimations();
      }
      
      // Restart animations
      if (widget.animate && widget.animationType != WidgetAnimationType.none) {
        _animationController.reset();
        _animationController.forward();
      } else {
        _animationController.value = 1.0;
      }
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
    if (widget.animate && widget.animationType != WidgetAnimationType.none && _animations.isNotEmpty) {
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