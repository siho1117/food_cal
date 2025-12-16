// lib/widgets/summary/sections/report_header_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/constants/app_constants.dart';
import '../../../data/models/user_profile.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import '../summary_controls_widget.dart';
import '../../common/frosted_glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Combined Report Header + Client Info Section
/// Glassmorphism design with frosted glass effect
class ReportHeaderSection extends StatelessWidget {
  final SummaryPeriod period;
  final UserProfile? profile;

  const ReportHeaderSection({
    super.key,
    required this.period,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final now = DateTime.now();

        return FrostedGlassCard(
          child: Center(
            child: Column(
              children: [
                // First Row: User Name
                Text(
                  (profile?.name ?? 'User').toUpperCase(),
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: AppWidgetTheme.fontSizeXL,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppWidgetTheme.spaceXS),

                // Second Row: OptiMate Report
                Text(
                  '${AppConstants.appDisplayName} ${l10n.report}',
                  style: AppTypography.displayLarge.copyWith(
                    fontSize: AppWidgetTheme.fontSizeXL,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppWidgetTheme.spaceSM),

                // Period Type with Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPeriodIcon(period),
                    const SizedBox(width: AppWidgetTheme.spaceXS),
                    Text(
                      _getPeriodTitle(period, l10n),
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: AppWidgetTheme.fontSizeMS,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppWidgetTheme.spaceXS),

                // Date Range
                Text(
                  SummaryDataCalculator.getPeriodSubtitle(period),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppWidgetTheme.spaceXS),

                // Generated Date
                Text(
                  '${l10n.generated}${SummaryDataCalculator.formatDate(now)}',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodIcon(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return Image.asset(
          'assets/emojis/icon/calendar_3d.png',
          width: AppWidgetTheme.iconSizeSmall,
          height: AppWidgetTheme.iconSizeSmall,
        );
      case SummaryPeriod.weekly:
        return Image.asset(
          'assets/emojis/icon/spiral_calendar_3d.png',
          width: AppWidgetTheme.iconSizeSmall,
          height: AppWidgetTheme.iconSizeSmall,
        );
      case SummaryPeriod.monthly:
        return Icon(
          Icons.calendar_month,
          size: AppWidgetTheme.iconSizeSmall,
          color: Colors.white.withValues(alpha: 0.7),
        );
    }
  }

  String _getPeriodTitle(SummaryPeriod period, AppLocalizations l10n) {
    switch (period) {
      case SummaryPeriod.daily:
        return l10n.dailySummary;
      case SummaryPeriod.weekly:
        return l10n.weeklySummary;
      case SummaryPeriod.monthly:
        return l10n.monthlySummary;
    }
  }
}
