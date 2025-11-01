// lib/widgets/common/week_navigation_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';
import '../../providers/theme_provider.dart';  // ✅ NEW: Import ThemeProvider

/// Widget-specific design constants
class _WeekNavigationDesign {
  static const double dayItemWidth = 42.0;
  static const double dayItemHeight = 65.0;
  static const double selectedGlowBlur = 12.0;
  static const double selectedGlowSpread = 2.0;
}

class WeekNavigationWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final int daysToShow;
  final EdgeInsets? padding;
  final double? dayItemWidth;
  final double? dayItemHeight;

  const WeekNavigationWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.daysToShow = 8, // Default: 7 days back + today
    this.padding,
    this.dayItemWidth,
    this.dayItemHeight,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final localizations = AppLocalizations.of(context)!;
    
    // Generate the specified number of days ending with today
    final startDate = now.subtract(Duration(days: daysToShow - 1));
    final weekDays = List.generate(daysToShow, (index) {
      return startDate.add(Duration(days: index));
    });

    // Filter to ensure we don't show future dates
    final validDays = weekDays.where((date) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final normalizedNow = DateTime(now.year, now.month, now.day);
      
      return normalizedDate.isBefore(normalizedNow) || 
             normalizedDate.isAtSameMomentAs(normalizedNow);
    }).toList();

    // ✅ NEW: Wrap with Consumer to get theme-adaptive colors
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // ✅ NEW: Get theme-adaptive text color
        final textColor = AppColors.getTextColorForTheme(
          themeProvider.selectedGradient,
        );
        
        return Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // Selected date display (bigger text, no shadow) - NOW ON TOP
              _buildSelectedDateDisplay(context, now, localizations, textColor),
              
              const SizedBox(height: 16),
              
              // Week days row (no container border - Option B)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: validDays.map((date) {
                  final isSelected = _isSameDay(date, selectedDate);
                  final isToday = _isSameDay(date, now);
                  
                  return _buildDayItem(
                    context: context,
                    date: date,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () => onDateChanged(date),
                    textColor: textColor,  // ✅ NEW: Pass textColor
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayItem({
    required BuildContext context,
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required VoidCallback onTap,
    required Color textColor,  // ✅ NEW: Add textColor parameter
  }) {
    final effectiveWidth = dayItemWidth ?? _WeekNavigationDesign.dayItemWidth;
    final effectiveHeight = dayItemHeight ?? _WeekNavigationDesign.dayItemHeight;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: BoxDecoration(
          // Always transparent, no background fill
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(effectiveWidth / 2),
          // Border for selected day (iOS-style) - Option B
          border: isSelected
              ? Border.all(
                  color: textColor.withValues(  // ✅ CHANGED: Use textColor
                    alpha: AppWidgetDesign.cardBorderOpacity,
                  ),
                  width: AppWidgetDesign.cardBorderWidth,
                )
              : (isToday && !isSelected
                  ? Border.all(
                      color: textColor.withValues(alpha: 0.3),  // ✅ CHANGED: Use textColor
                      width: 1.5,
                    )
                  : null),
          // No glow effect - clean border only
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day letter (localized: M, T, W... or 一, 二, 三...)
            Text(
              _getLocalizedDayLetter(context, date),
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? textColor  // ✅ CHANGED: Use textColor
                    : textColor.withValues(alpha: 0.7),  // ✅ CHANGED: Use textColor
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Day number
            Text(
              date.day.toString(),
              style: AppTypography.labelLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? textColor  // ✅ CHANGED: Use textColor
                    : textColor.withValues(alpha: 0.85),  // ✅ CHANGED: Use textColor
              ),
            ),
            // Small dot indicator for today when not selected
            if (isToday && !isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.7),  // ✅ CHANGED: Use textColor
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDisplay(
    BuildContext context,
    DateTime now,
    AppLocalizations localizations,
    Color textColor,  // ✅ NEW: Add textColor parameter
  ) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          key: ValueKey(selectedDate),
          _formatSelectedDate(now, localizations),
          style: TextStyle(  // ✅ CHANGED: Use TextStyle directly with textColor
            fontSize: 22, // Bigger text (was 18)
            fontWeight: FontWeight.w600,
            color: textColor,  // ✅ CHANGED: Use textColor
            letterSpacing: 0.3,
            // No shadow
          ),
        ),
      ),
    );
  }

  /// Get localized day letter (M/T/W... or 一/二/三... or 月/火/水... depending on locale)
  String _getLocalizedDayLetter(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    
    // For Chinese locales, use Chinese characters
    if (locale.languageCode == 'zh') {
      const chineseDays = ['一', '二', '三', '四', '五', '六', '日'];
      return chineseDays[date.weekday - 1];
    }
    
    // For Japanese locale, use kanji
    if (locale.languageCode == 'ja') {
      const japaneseDays = ['月', '火', '水', '木', '金', '土', '日'];
      return japaneseDays[date.weekday - 1];
    }
    
    // For English and other locales, use single letter
    const englishDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return englishDays[date.weekday - 1];
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Format selected date - keep today/yesterday translated, show dates as dd/mm/yyyy
  String _formatSelectedDate(
    DateTime now,
    AppLocalizations localizations,
  ) {
    final yesterday = now.subtract(const Duration(days: 1));
    
    // Check for relative dates (using translation keys)
    if (_isSameDay(selectedDate, now)) {
      return localizations.today;
    } else if (_isSameDay(selectedDate, yesterday)) {
      return localizations.yesterday;
    } else {
      // For all other dates, use dd/mm/yyyy format (no translation)
      final day = selectedDate.day.toString().padLeft(2, '0');
      final month = selectedDate.month.toString().padLeft(2, '0');
      final year = selectedDate.year.toString();
      return '$day/$month/$year';
    }
  }
}