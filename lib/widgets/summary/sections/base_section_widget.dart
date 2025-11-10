// lib/widgets/summary/sections/base_section_widget.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';

/// Base widget for all summary report sections
/// Provides consistent styling and structure
class BaseSectionWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const BaseSectionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SummaryTheme.sectionPadding),
      decoration: SummaryTheme.sectionDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(icon, size: 18, color: SummaryTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: SummaryTheme.sectionHeader),
            ],
          ),
          const Divider(height: SummaryTheme.dividerHeight),
          // Section Content
          child,
        ],
      ),
    );
  }
}

/// Helper widget for info rows (label: value pairs)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: SummaryTheme.infoLabel),
          Text(
            value,
            style: SummaryTheme.infoValue.copyWith(
              color: valueColor ?? SummaryTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for progress rows with bars
class ProgressRow extends StatelessWidget {
  final String label;
  final double progress;

  const ProgressRow({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: SummaryTheme.infoLabel),
              Text('$percentage%', style: SummaryTheme.infoValue),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(SummaryTheme.primary),
              minHeight: SummaryTheme.progressBarHeight,
            ),
          ),
        ],
      ),
    );
  }
}
