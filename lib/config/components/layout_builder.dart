// lib/config/components/layout_builder.dart

import 'package:flutter/material.dart';
import '../design_system/theme.dart';
import '../design_system/text_styles.dart';
import '../design_system/dimensions.dart';
import '../utils/decorations/box_decorations.dart';

/// A unified utility class for building standardized layout components throughout the app.
///
/// This class consolidates functionality from previous layout utilities
/// (layout_builders, card_layout, header_layout, content_layout) into a single
/// source, eliminating overlapping functionality while preserving all needed
/// layout patterns.
class LayoutBuilder {
  // Private constructor to prevent instantiation
  LayoutBuilder._();
  
  //-----------------------------------------------------------------------------
  // CONTAINER LAYOUTS 
  //-----------------------------------------------------------------------------
  
  /// Creates a standard card container with consistent styling
  ///
  /// Replaces: CardLayout.card(), ContentLayout.cardContainer()
  static Widget card({
    required Widget child,
    Widget? header,
    Widget? footer,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(20),
    bool useGradientBackground = true,
    Color backgroundColor = Colors.white,
    double? borderRadius,
    double? elevation,
    bool isLoading = false,
    bool hasError = false,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    // Get appropriate decoration
    final decoration = useGradientBackground
        ? BoxDecorations.cardGradient(
            borderRadius: borderRadius,
            elevation: elevation,
          )
        : BoxDecorations.card(
            borderRadius: borderRadius,
            elevation: elevation,
            backgroundColor: backgroundColor,
          );
    
    return Container(
      decoration: decoration,
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
    );
  }
  
  /// Creates a simple container with standard styling
  ///
  /// Replaces: ContentLayout.container()
  static Widget container({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? backgroundColor,
    double? borderRadius,
    BoxBorder? border,
    BoxShadow? shadow,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: border,
        boxShadow: shadow != null ? [shadow] : null,
      ),
      child: child,
    );
  }
  
  /// Creates a section container with title
  ///
  /// Replaces: ContentLayout.sectionContainer()
  static Widget section({
    required String title,
    required Widget child,
    Widget? trailing,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16),
    Color? backgroundColor,
    Color? titleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: title,
          trailing: trailing,
          color: titleColor,
        ),
        const SizedBox(height: 8),
        container(
          padding: contentPadding,
          backgroundColor: backgroundColor,
          child: child,
        ),
      ],
    );
  }
  
  //-----------------------------------------------------------------------------
  // HEADER LAYOUTS
  //-----------------------------------------------------------------------------
  
  /// Creates a standard widget header with icon and title
  ///
  /// Replaces: HeaderLayout.standard(), LayoutBuilders.buildHeader()
  static Widget header({
    required String title,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    Widget? badge,
    String? subtitle,
    bool useIconBackground = true,
    VoidCallback? onTap,
  }) {
    // Final colors with defaults
    final Color finalIconColor = iconColor ?? AppTheme.primaryBlue;
    final Color finalTextColor = textColor ?? AppTheme.primaryBlue;
    
    // Create the base row structure
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: onTap != null ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.transparent,
      highlightColor: onTap != null ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side with icon and title
          Expanded(
            child: Row(
              children: [
                // Icon with optional background
                if (useIconBackground)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecorations.iconContainer(color: finalIconColor),
                    child: Icon(
                      icon,
                      color: finalIconColor,
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: finalIconColor,
                    size: 20,
                  ),
                
                const SizedBox(width: 8),
                
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
                              title,
                              style: AppTextStyles.getSubHeadingStyle().copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: finalTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            badge,
                          ],
                        ],
                      ),
                      
                      // Optional subtitle
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle,
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }
  
  /// Creates a header with a trailing info button
  ///
  /// Replaces: HeaderLayout.withInfo()
  static Widget headerWithInfo({
    required String title,
    required IconData icon,
    required VoidCallback onInfoTap,
    Color? iconColor,
    String? subtitle,
  }) {
    return header(
      title: title,
      icon: icon,
      iconColor: iconColor,
      subtitle: subtitle,
      trailing: GestureDetector(
        onTap: onInfoTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecorations.circleIcon(color: AppTheme.primaryBlue),
          child: const Icon(
            Icons.info_outline,
            color: AppTheme.primaryBlue,
            size: 18,
          ),
        ),
      ),
    );
  }
  
  /// Creates a header with a trailing refresh button
  ///
  /// Replaces: HeaderLayout.withRefresh()
  static Widget headerWithRefresh({
    required String title,
    required IconData icon,
    required VoidCallback onRefresh,
    Color? iconColor,
    String? subtitle,
  }) {
    return header(
      title: title,
      icon: icon,
      iconColor: iconColor,
      subtitle: subtitle,
      trailing: IconButton(
        icon: Icon(
          Icons.refresh_rounded,
          color: AppTheme.primaryBlue.withOpacity(0.7),
          size: 20,
        ),
        onPressed: onRefresh,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
  
  /// Creates a screen header with title and optional action button
  ///
  /// Replaces: LayoutBuilders.buildScreenHeader()
  static Widget screenHeader({
    required String title,
    String? subtitle,
    Widget? action,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
    double titleSize = 22,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Title row with optional action
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            if (action != null) action,
          ],
        ),
        
        // Optional subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
  
  //-----------------------------------------------------------------------------
  // CONTENT LAYOUTS
  //-----------------------------------------------------------------------------
  
  /// Creates a standard info box for messages, tips, etc.
  ///
  /// Replaces: ContentLayout.infoBox(), LayoutBuilders.buildInfoBox()
  static Widget infoBox({
    required String message,
    IconData icon = Icons.info_outline,
    Color color = AppTheme.primaryBlue,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecorations.infoBox(
          color: color,
          opacity: 0.05,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Creates a list item with title, subtitle, and optional leading/trailing widgets
  ///
  /// Replaces: LayoutBuilders.buildListItem(), ContentLayout.listItem()
  static Widget listItem({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            child: Row(
              children: [
                // Optional leading widget
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: 16),
                ],
                
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      
                      // Optional subtitle
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Optional trailing widget
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing,
                ],
              ],
            ),
          ),
        ),
        
        // Optional divider
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200],
          ),
      ],
    );
  }
  
  /// Creates an error message display
  ///
  /// Replaces: ContentLayout.errorMessage()
  static Widget errorMessage({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red[700],
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Creates an empty state placeholder
  ///
  /// Replaces: ContentLayout.emptyState()
  static Widget emptyState({
    required String message,
    IconData icon = Icons.inbox,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
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
                  backgroundColor: AppTheme.primaryBlue,
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
  
  /// Creates a grid layout with responsive sizing
  ///
  /// Replaces: ContentLayout.responsiveGrid()
  static Widget responsiveGrid({
    required List<Widget> children,
    required BuildContext context,
    int phoneCrossAxisCount = 1,
    int tabletCrossAxisCount = 2,
    int desktopCrossAxisCount = 3,
    double spacing = 16,
    double childAspectRatio = 1.0,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    // Determine columns based on screen width
    final crossAxisCount = width < Dimensions.phoneWidth
        ? phoneCrossAxisCount
        : width < Dimensions.desktopWidth
            ? tabletCrossAxisCount
            : desktopCrossAxisCount;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
  
  //-----------------------------------------------------------------------------
  // HELPER METHODS
  //-----------------------------------------------------------------------------
  
  /// Creates a section header with title
  ///
  /// Replaces: LayoutBuilders.buildSectionHeader(), HeaderLayout.sectionHeader()
  static Widget _buildSectionHeader({
    required String title,
    Widget? trailing,
    Color? color,
    double fontSize = 18,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
  
  /// Standard loading state widget
  ///
  /// Used internally for card loading states
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
  ///
  /// Used internally for card error states
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