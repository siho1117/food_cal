// lib/widgets/common/week_navigation_widget.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';

class WeekNavigationWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final int daysToShow;
  final EdgeInsets? padding;
  final double? dayItemWidth;
  final double? dayItemHeight;

  const WeekNavigationWidget({
    super.key,  // ✅ FIXED: Using super parameter instead of Key? key
    required this.selectedDate,
    required this.onDateChanged,
    this.daysToShow = 8, // Default: 7 days back + today
    this.padding,
    this.dayItemWidth = 42,
    this.dayItemHeight = 65,
  });  // ✅ FIXED: Removed ': super(key: key)' as it's no longer needed

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // Generate the specified number of days ending with today
    final startDate = now.subtract(Duration(days: daysToShow - 1));
    final weekDays = List.generate(daysToShow, (index) {
      return startDate.add(Duration(days: index));
    });

    // Filter to ensure we don't show future dates
    final validDays = weekDays.where((date) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final normalizedNow = DateTime(now.year, now.month, now.day);
      
      // Include dates that are today or before today (not future dates)
      return normalizedDate.isBefore(normalizedNow) || 
             normalizedDate.isAtSameMomentAs(normalizedNow);
    }).toList();

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Week days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: validDays.map((date) {
              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isSameDay(date, now);
              
              return _buildDayItem(
                date: date,
                isSelected: isSelected,
                isToday: isToday,
                onTap: () => onDateChanged(date),
              );
            }).toList(),
          ),
          
          // Selected date display
          const SizedBox(height: 12),
          _buildSelectedDateDisplay(now),
        ],
      ),
    );
  }

  Widget _buildDayItem({
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: dayItemWidth,
        height: dayItemHeight,
        decoration: BoxDecoration(
          // Visual hierarchy for today vs selected
          color: isSelected 
              ? AppTheme.primaryBlue 
              : Colors.transparent,
          borderRadius: BorderRadius.circular((dayItemWidth ?? 42) / 2),
          border: isToday && !isSelected
              ? Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.5), 
                  width: 2
                )
              : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day letter (M, T, W, T, F, S, S)
            Text(
              _getDayLetter(date),
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white 
                    : (isToday ? AppTheme.primaryBlue : Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 4),
            // Day number
            Text(
              date.day.toString(),
              style: AppTextStyles.getNumericStyle().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white 
                    : (isToday ? AppTheme.primaryBlue : Colors.grey[800]),
              ),
            ),
            // Today indicator when it's today and not selected
            if (isToday && !isSelected) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDisplay(DateTime now) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        key: ValueKey(selectedDate), // Key for proper animation
        _isSameDay(selectedDate, now) 
            ? 'Today' // Show "Today" when today is selected
            : _formatSelectedDate(selectedDate),
        style: AppTextStyles.getBodyStyle().copyWith(
          fontSize: 14,
          color: _isSameDay(selectedDate, now) 
              ? AppTheme.primaryBlue 
              : Colors.grey[600],
          fontWeight: _isSameDay(selectedDate, now) 
              ? FontWeight.w600 
              : FontWeight.w500,
        ),
      ),
    );
  }

  // Helper method to get day letter
  String _getDayLetter(DateTime date) {
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // weekday returns 1-7 where 1 is Monday, so subtract 1 for 0-indexed array
    return dayLetters[date.weekday - 1];
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Helper method to format selected date
  String _formatSelectedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // Check for relative dates
    if (_isSameDay(date, today)) {
      return 'Today';
    } else if (_isSameDay(date, yesterday)) {
      return 'Yesterday';
    } else {
      // Show full date for older dates
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}