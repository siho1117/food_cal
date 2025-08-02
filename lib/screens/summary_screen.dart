// lib/screens/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../config/design_system/text_styles.dart';
import '../providers/home_provider.dart';
import '../widgets/summary/daily_summary_widget.dart';
import '../widgets/summary/weekly_summary_widget.dart';
import '../widgets/summary/summary_stats_widget.dart';
import '../widgets/summary/spending_trend_widget.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<HomeProvider>(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        body: SafeArea(
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (homeProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                  ),
                );
              }
              
              return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: Column(
                  children: [
                    // Page Header
                    _buildHeader(),
                    
                    // Tab Bar
                    _buildTabBar(),
                    
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDailyTab(homeProvider),
                          _buildWeeklyTab(homeProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            'Summary',
            style: AppTextStyles.getHeadingStyle().copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // Optional: Add date indicator or export button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _getCurrentPeriodText(),
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 12,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppTheme.primaryBlue,
        ),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: AppTextStyles.getSubHeadingStyle().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.getSubHeadingStyle().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.today, size: 16),
                SizedBox(width: 6),
                Text('Daily'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.view_week, size: 16),
                SizedBox(width: 6),
                Text('Weekly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab(HomeProvider homeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Daily Overview Cards
          _buildSectionHeader('Today\'s Overview'),
          const SizedBox(height: 12),
          const DailySummaryWidget(),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          _buildSectionHeader('Quick Stats'),
          const SizedBox(height: 12),
          const SummaryStatsWidget(),
          
          const SizedBox(height: 24),
          
          // Daily Achievements
          _buildSectionHeader('Daily Progress'),
          const SizedBox(height: 12),
          _buildDailyAchievements(homeProvider),
          
          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildWeeklyTab(HomeProvider homeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Weekly Overview
          _buildSectionHeader('This Week\'s Summary'),
          const SizedBox(height: 12),
          const WeeklySummaryWidget(),
          
          const SizedBox(height: 24),
          
          // Spending Trend
          _buildSectionHeader('Spending Trend'),
          const SizedBox(height: 12),
          const SpendingTrendWidget(),
          
          const SizedBox(height: 24),
          
          // Weekly Goals
          _buildSectionHeader('Weekly Goals'),
          const SizedBox(height: 12),
          _buildWeeklyGoals(homeProvider),
          
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.getSubHeadingStyle().copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildDailyAchievements(HomeProvider homeProvider) {
    final achievements = _getDailyAchievements(homeProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: achievements.map((achievement) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: achievement['completed'] ? Colors.green[100] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement['completed'] ? Icons.check : Icons.circle_outlined,
                    size: 14,
                    color: achievement['completed'] ? Colors.green[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    achievement['title'],
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 14,
                      color: achievement['completed'] ? Colors.grey[800] : Colors.grey[500],
                      fontWeight: achievement['completed'] ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  achievement['emoji'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildWeeklyGoals(HomeProvider homeProvider) {
    final goals = _getWeeklyGoals(homeProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: goals.map((goal) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal['title'],
                      style: AppTextStyles.getBodyStyle().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${goal['current']}/${goal['target']}',
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: goal['onTrack'] ? Colors.green[600] : Colors.orange[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: goal['progress'],
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal['onTrack'] ? Colors.green[600]! : Colors.orange[600]!,
                  ),
                ),
              ],
            ),
          ),
        ).toList(),
      ),
    );
  }

  String _getCurrentPeriodText() {
    if (_currentTabIndex == 0) {
      final now = DateTime.now();
      if (now.weekday == DateTime.monday) return 'Today (Monday)';
      if (now.weekday == DateTime.friday) return 'Today (Friday)';
      return 'Today';
    } else {
      return 'This Week';
    }
  }

  List<Map<String, dynamic>> _getDailyAchievements(HomeProvider homeProvider) {
    return [
      {
        'title': 'Stayed under budget',
        'completed': !homeProvider.isOverFoodBudget,
        'emoji': '💰',
      },
      {
        'title': 'Logged all meals',
        'completed': homeProvider.mealsCount >= 3,
        'emoji': '🍽️',
      },
      {
        'title': 'Met calorie goal',
        'completed': homeProvider.calorieProgress >= 0.8 && homeProvider.calorieProgress <= 1.2,
        'emoji': '🎯',
      },
      {
        'title': 'Balanced nutrition',
        'completed': _isNutritionBalanced(homeProvider),
        'emoji': '⚖️',
      },
    ];
  }

  List<Map<String, dynamic>> _getWeeklyGoals(HomeProvider homeProvider) {
    // Note: These would need actual weekly data calculation
    return [
      {
        'title': 'Budget Management',
        'current': 5,
        'target': 7,
        'progress': 5/7,
        'onTrack': true,
      },
      {
        'title': 'Meal Logging',
        'current': 18,
        'target': 21,
        'progress': 18/21,
        'onTrack': true,
      },
      {
        'title': 'Calorie Consistency',
        'current': 4,
        'target': 7,
        'progress': 4/7,
        'onTrack': false,
      },
    ];
  }

  bool _isNutritionBalanced(HomeProvider homeProvider) {
    final macros = homeProvider.macroProgressPercentages;
    return macros['protein']! >= 70 && 
           macros['carbs']! >= 70 && 
           macros['fat']! >= 70;
  }
}