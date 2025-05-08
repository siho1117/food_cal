import 'package:flutter/material.dart';
import '../theme.dart';
import '../widget_ui_design_standards.dart';
import '../decorations/box_decorations.dart';

/// Standard content layout patterns used throughout the app.
///
/// This class provides static methods for building common content layouts
/// with consistent styling, reducing code duplication.
class ContentLayout {
  // Private constructor to prevent instantiation
  ContentLayout._();
  
  /// Creates a standard info box for messages, tips, etc.
  static Widget infoBox({
    required String message,
    IconData icon = Icons.info_outline,
    Color color = AppTheme.primaryBlue,
    double opacity = 0.05,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecorations.infoBox(
          color: color,
          opacity: opacity,
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
  static Widget listItem({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    ),
    bool showDivider = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
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
  static Widget settingItem({
    required String title,
    required IconData icon,
    required String value,
    VoidCallback? onTap,
    Color iconBackgroundColor = AppTheme.primaryBlue,
    Color? iconColor,
    bool showChevron = true,
  }) {
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
              decoration: BoxDecorations.iconContainer(
                color: iconBackgroundColor,
              ),
              child: Icon(
                icon,
                color: iconColor ?? iconBackgroundColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title and value
            Column(
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
            
            const Spacer(),
            
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
  
  /// Creates a form section with title and input widgets
  static Widget formSection({
    required String title,
    required List<Widget> children,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? titleColor,
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Colors.grey[600],
              letterSpacing: 1.0,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Form fields
          ...children,
        ],
      ),
    );
  }
  
  /// Creates a standard progress bar with label and value
  static Widget progressBar({
    required double progress,
    String? label,
    String? valueLabel,
    Color color = AppTheme.primaryBlue,
    double height = 8.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional label and value
        if (label != null || valueLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label
                if (label != null)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                // Value
                if (valueLabel != null)
                  Text(
                    valueLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: height,
          ),
        ),
      ],
    );
  }
  
  /// Creates a tag pill
  static Widget tag({
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
  static Widget tagRow({
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
            child: tag(
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
  static Widget dividerWithLabel({
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