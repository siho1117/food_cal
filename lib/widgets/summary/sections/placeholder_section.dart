// lib/widgets/summary/sections/placeholder_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';
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
    return BaseSectionWidget(
      icon: icon,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: SummaryTheme.helperText),
          SummaryTheme.smallSpacingWidget,
          Text(
            'This section will show:',
            style: SummaryTheme.bodySmall,
          ),
          ...features.map((feature) => Text(
                '  • $feature',
                style: SummaryTheme.bodySmall,
              )),
        ],
      ),
    );
  }
}
