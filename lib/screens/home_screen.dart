// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../config/design_system/text_styles.dart';
import '../providers/home_provider.dart';
import '../widgets/home/calorie_summary_widget.dart';
import '../widgets/home/macronutrient_widget.dart';
import '../widgets/home/food_log_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Provide the HomeProvider to the widget tree
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadData(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        body: SafeArea(
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              // Show loading state
              if (homeProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                  ),
                );
              }
              
              // Show main content with RefreshIndicator for pull-to-refresh
              return RefreshIndicator(
                onRefresh: () => homeProvider.refreshData(),
                color: AppTheme.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Week Calendar Navigation
                      _buildWeekNavigation(homeProvider),

                      const SizedBox(height: 20),

                      // Calorie Summary Widget
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: CalorieSummaryWidget(),
                      ),

                      const SizedBox(height: 20),

                      // Macronutrient Widget
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: MacronutrientWidget(),
                      ),

                      const SizedBox(height: 20),

                      // Food Log Widget (without header)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: FoodLogWidget(
                          showHeader: false, // Remove the header
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigation(HomeProvider homeProvider) {
    final now = DateTime.now();
    final selectedDate = homeProvider.selectedDate;
    
    // Generate the last 8 days (7 days back + today)
    // Start from 7 days ago and go forward to today
    final startDate = now.subtract(const Duration(days: 7));
    final weekDays = List.generate(8, (index) {
      return startDate.add(Duration(days: index));
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 👈 ADJUST THIS LINE
      child: Column(
        children: [
          // Week days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays.where((date) {
              // Only show dates that are not in the future
              final now = DateTime.now();
              return !date.isAfter(DateTime(now.year, now.month, now.day));
            }).map((date) {
              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isSameDay(date, now);
              
              return GestureDetector(
                onTap: () => homeProvider.changeDate(date),
                child: Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryBlue 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isToday && !isSelected
                        ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day letter (T, W, T, F, S, S, M)
                      Text(
                        _getDayLetter(date),
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? Colors.white 
                              : Colors.grey[600],
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
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Selected date display
          if (!_isSameDay(selectedDate, now)) ...[
            const SizedBox(height: 12),
            Text(
              _formatSelectedDate(selectedDate),
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDayLetter(DateTime date) {
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dayLetters[date.weekday - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}