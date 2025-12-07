// lib/widgets/summary/sections/report_footer_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../common/frosted_glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Report Footer Section - Disclaimer and branding
class ReportFooterSection extends StatelessWidget {
  const ReportFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FrostedGlassCard(
      child: Column(
        children: [
          Text(
            l10n.reportGeneratedBy,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppWidgetTheme.spaceSM),
          Text(
            l10n.disclaimerText,
            style: AppTypography.bodySmall.copyWith(
              fontSize: AppWidgetTheme.fontSizeXS,
              color: Colors.white.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
