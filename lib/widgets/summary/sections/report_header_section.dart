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
import '../../common/user_avatar_widget.dart';
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
    final locale = Localizations.localeOf(context).toString();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final now = DateTime.now();

        return FrostedGlassCard(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: AppWidgetTheme.spaceMD),

                // Top Row: OptiMate Report
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
                const SizedBox(height: AppWidgetTheme.spaceMD),

                // Centered Avatar
                UserAvatarWidget(
                  profile: profile,
                  size: 72.0, // Larger, prominent avatar
                  useAnimation: false, // Static for reports
                ),
                const SizedBox(height: AppWidgetTheme.spaceMD),

                // User Name
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
                const SizedBox(height: AppWidgetTheme.spaceSM),

                // Period Type with Icon + Generated Date (same row)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPeriodIcon(period),
                    const SizedBox(width: AppWidgetTheme.spaceXS),
                    Text(
                      _getPeriodTitle(period, l10n),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: AppWidgetTheme.spaceSM),
                    Text(
                      '•',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: AppWidgetTheme.spaceSM),
                    Text(
                      '${l10n.generated}${SummaryDataCalculator.formatDate(now, locale)}',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppWidgetTheme.spaceXS),

                // Date Range
                Text(
                  _getPeriodSubtitle(period, locale, l10n),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppWidgetTheme.spaceMD),
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

  String _getPeriodSubtitle(SummaryPeriod period, String locale, AppLocalizations l10n) {
    final now = DateTime.now();

    switch (period) {
      case SummaryPeriod.daily:
        return SummaryDataCalculator.formatDate(now, locale);
      case SummaryPeriod.weekly:
        // Last 7 days (rolling window)
        final startDate = now.subtract(const Duration(days: 6));
        return '${l10n.lastSevenDays}: ${SummaryDataCalculator.formatDate(startDate, locale)} - ${SummaryDataCalculator.formatDate(now, locale)}';
      case SummaryPeriod.monthly:
        return SummaryDataCalculator.formatMonth(now, locale);
    }
  }
}
