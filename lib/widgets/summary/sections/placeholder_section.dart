// lib/widgets/summary/sections/placeholder_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
import 'base_section_widget.dart';

/// Placeholder Section for Weekly Summary and Achievements
/// These will be implemented when weekly data aggregation is ready
class PlaceholderSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final List<String> features;

  const PlaceholderSection({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

        return BaseSectionWidget(
          icon: icon,
          title: title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeSM,
                  color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: AppWidgetTheme.spaceSM),
              Text(
                'This section will show:',
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeSM,
                  color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                ),
              ),
              ...features.map((feature) => Text(
                    '  • $feature',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: AppWidgetTheme.fontSizeSM,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
