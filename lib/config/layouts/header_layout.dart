import 'package:flutter/material.dart';
import '../theme.dart';
import '../widget_ui_design_standards.dart';
import '../decorations/box_decorations.dart';

/// Standard header layouts used throughout the app.
///
/// This class provides static methods for building header components
/// with consistent styling, reducing code duplication.
class HeaderLayout {
  // Private constructor to prevent instantiation
  HeaderLayout._();
  
  /// Creates a standard widget header with icon and title
  static Widget standard({
    required String title,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    Widget? badge,
    String? subtitle,
    bool useIconBackground = true,
    bool allowTitleWrap = false,
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
                              overflow: allowTitleWrap ? TextOverflow.visible : TextOverflow.ellipsis,
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
  static Widget withInfo({
    required String title,
    required IconData icon,
    required VoidCallback onInfoTap,
    Color? iconColor,
    Color? textColor,
    String? subtitle,
    bool useIconBackground = true,
  }) {
    return standard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      textColor: textColor,
      subtitle: subtitle,
      useIconBackground: useIconBackground,
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
  static Widget withRefresh({
    required String title,
    required IconData icon,
    required VoidCallback onRefresh,
    Color? iconColor,
    Color? textColor,
    String? subtitle,
    bool useIconBackground = true,
  }) {
    return standard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      textColor: textColor,
      subtitle: subtitle,
      useIconBackground: useIconBackground,
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
  
  /// Creates a header with a classification badge
  static Widget withClassification({
    required String title,
    required IconData icon,
    required String classification,
    required Color classificationColor,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    String? subtitle,
    bool useIconBackground = true,
  }) {
    return standard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      textColor: textColor,
      subtitle: subtitle,
      useIconBackground: useIconBackground,
      trailing: trailing,
      badge: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8, 
          vertical: 4,
        ),
        decoration: BoxDecorations.badge(color: classificationColor),
        child: Text(
          classification,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: classificationColor,
          ),
        ),
      ),
    );
  }
  
  /// Creates a screen header with title and optional action button
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
  
  /// Creates a section header with title
  static Widget sectionHeader({
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
}