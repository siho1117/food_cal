// lib/config/layouts/layout_builders.dart

import 'package:flutter/material.dart';
import '../theme.dart';
import '../text_styles.dart';
import '../widget_ui_design_standards.dart';
import '../decorations/box_decorations.dart';

/// A unified utility class for building standardized layout components throughout the app.
/// 
/// This class merges the functionality from header_layout.dart and content_layout.dart
/// to provide a comprehensive set of layout building utilities while reducing
/// code duplication and overlap.
class LayoutBuilders {
  // Private constructor to prevent instantiation
  LayoutBuilders._();
  
  //-----------------------------------------------------------------------------
  // HEADER LAYOUTS
  //-----------------------------------------------------------------------------
  
  /// Creates a standard widget header with icon and title
  static Widget buildHeader({
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
      borderRadius: BorderRadius.circular(WidgetUIStandards.containerBorderRadius),
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
                    padding: const EdgeInsets.all(WidgetUIStandards.headerIconSpacing),
                    decoration: BoxDecorations.iconContainer(color: finalIconColor),
                    child: Icon(
                      icon,
                      color: finalIconColor,
                      size: WidgetUIStandards.headerIconSize,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: finalIconColor,
                    size: WidgetUIStandards.headerIconSize,
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
                              title,
                              style: TextStyle(
                                fontSize: WidgetUIStandards.headerFontSize,
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
  static Widget buildHeaderWithInfo({
    required String title,
    required IconData icon,
    required VoidCallback onInfoTap,
    Color? iconColor,
    String? subtitle,
  }) {
    return buildHeader(
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
  static Widget buildHeaderWithRefresh({
    required String title,
    required IconData icon,
    required VoidCallback onRefresh,
    Color? iconColor,
    String? subtitle,
  }) {
    return buildHeader(
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
  static Widget buildScreenHeader({
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
  
  /// Creates a section header with title
  static Widget buildSectionHeader({
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
  
  //-----------------------------------------------------------------------------
  // CONTENT LAYOUTS
  //-----------------------------------------------------------------------------
  
  /// Creates a standard info box for messages, tips, etc.
  static Widget buildInfoBox({
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
  static Widget buildListItem({
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
  
  /// Creates a setting item with icon, label, and value
  static Widget buildSettingItem({
    required String title,
    required IconData icon,
    required String value,
    VoidCallback? onTap,
    Color? iconColor,
    bool showChevron = true,
  }) {
    final color = iconColor ?? AppTheme.primaryBlue;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            // Icon with container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecorations.iconContainer(color: color),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title label
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Value
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Chevron icon if tappable
            if (showChevron && onTap != null)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Creates a tag pill
  static Widget buildTag({
    required String text,
    Color? color,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    final tagColor = color ?? AppTheme.primaryBlue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected ? tagColor : tagColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tagColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : tagColor,
          ),
        ),
      ),
    );
  }
  
  /// Creates a row of tags with horizontal scrolling
  static Widget buildTagRow({
    required List<String> tags,
    List<Color>? colors,
    Function(int)? onTagTap,
    int? selectedIndex,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          tags.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == tags.length - 1 ? 0 : 0,
            ),
            child: buildTag(
              text: tags[index],
              color: colors != null && index < colors.length
                  ? colors[index]
                  : null,
              onTap: onTagTap != null ? () => onTagTap(index) : null,
              selected: selectedIndex == index,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Creates a divider with optional label
  static Widget buildDividerWithLabel({
    required String label,
    Color? color,
    double thickness = 1.0,
  }) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: color ?? Colors.grey[300],
            thickness: thickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: color ?? Colors.grey[300],
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}