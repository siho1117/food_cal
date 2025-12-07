// lib/widgets/summary/summary_controls_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../providers/theme_provider.dart';

/// Feature flag: Set to true to enable monthly view in Stage 2
const bool _enableMonthlyView = false;

enum SummaryPeriod { daily, weekly, monthly }

class SummaryControlsWidget extends StatelessWidget {
  final SummaryPeriod currentPeriod;
  final Function(SummaryPeriod) onPeriodChanged;
  final VoidCallback onExport;
  final bool isExporting;
  final VoidCallback? onSettingsTap;

  const SummaryControlsWidget({
    super.key,
    required this.currentPeriod,
    required this.onPeriodChanged,
    required this.onExport,
    this.isExporting = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );

        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceXL),
          child: Row(
            children: [
              // Main pill container with period switcher and customize icon
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.0),
                        borderRadius: BorderRadius.circular(34.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(AppWidgetTheme.spaceLG),
                      child: Row(
                        children: [
                          // Period Switcher
                          Expanded(
                            child: _buildPeriodSwitcher(textColor, borderColor),
                          ),

                          // Settings/Customize Icon (if callback provided)
                          if (onSettingsTap != null) ...[
                            SizedBox(width: AppWidgetTheme.spaceLG),
                            _buildSettingsButton(textColor),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Export Button (Outside the pill, to the right)
              SizedBox(width: AppWidgetTheme.spaceLG),
              _buildExportIconButton(textColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodSwitcher(Color textColor, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXL), // Pill shape
      ),
      padding: EdgeInsets.all(AppWidgetTheme.spaceXXS), // Small padding around tabs
      child: Row(
        children: SummaryPeriod.values
            .where((period) => _enableMonthlyView || period != SummaryPeriod.monthly)
            .map((period) {
          final isSelected = period == currentPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppWidgetTheme.spaceMD,
                  horizontal: AppWidgetTheme.spaceXS, // Horizontal padding to prevent overflow
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? textColor.withValues(alpha: 1.0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXL), // Pill shape tabs
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Minimize space usage
                  children: [
                    Icon(
                      _getPeriodIcon(period),
                      size: AppWidgetTheme.iconSizeSmall,
                      color: isSelected
                          ? (textColor == AppWidgetTheme.colorPrimaryDark
                              ? Colors.white
                              : AppWidgetTheme.colorPrimaryDark)
                          : textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    ),
                    SizedBox(width: AppWidgetTheme.spaceXXS), // Smaller gap
                    Flexible(
                      child: Text(
                        _getPeriodLabel(period),
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                        maxLines: 1,
                        style: AppTypography.displaySmall.copyWith(
                          fontSize: AppWidgetTheme.fontSizeXS, // Smaller font
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (textColor == AppWidgetTheme.colorPrimaryDark
                                  ? Colors.white
                                  : AppWidgetTheme.colorPrimaryDark)
                              : textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsButton(Color textColor) {
    final bgColor = textColor == AppWidgetTheme.colorPrimaryDark
        ? AppWidgetTheme.colorPrimaryDark
        : Colors.white;
    final iconColor = textColor == AppWidgetTheme.colorPrimaryDark
        ? Colors.white
        : AppWidgetTheme.colorPrimaryDark;

    return Container(
      width: AppWidgetTheme.iconContainerLarge,
      height: AppWidgetTheme.iconContainerLarge,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppWidgetTheme.iconContainerLarge / 2),
          onTap: onSettingsTap,
          child: Center(
            child: Icon(
              Icons.tune,
              size: AppWidgetTheme.iconSizeLarge,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportIconButton(Color textColor) {
    final bgColor = textColor == AppWidgetTheme.colorPrimaryDark
        ? AppWidgetTheme.colorPrimaryDark
        : Colors.white;
    final iconColor = textColor == AppWidgetTheme.colorPrimaryDark
        ? Colors.white
        : AppWidgetTheme.colorPrimaryDark;

    return Container(
      width: AppWidgetTheme.iconContainerLarge,
      height: AppWidgetTheme.iconContainerLarge,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle, // Perfect circle
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppWidgetTheme.iconContainerLarge / 2), // Circular ripple
          onTap: isExporting ? null : onExport,
          child: Center(
            child: isExporting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  )
                : Icon(
                    Icons.file_download_outlined,
                    size: AppWidgetTheme.iconSizeLarge,
                    color: iconColor,
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getPeriodIcon(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return Icons.today;
      case SummaryPeriod.weekly:
        return Icons.view_week;
      case SummaryPeriod.monthly:
        return Icons.calendar_month;
    }
  }

  String _getPeriodLabel(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'Daily';
      case SummaryPeriod.weekly:
        return 'Weekly';
      case SummaryPeriod.monthly:
        return 'Monthly';
    }
  }
}