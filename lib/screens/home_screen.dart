// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/home_provider.dart';
import '../widgets/home/calorie_summary_widget.dart';
import '../widgets/home/macronutrient_widget.dart';
import '../widgets/home/cost_summary_widget.dart';
import '../widgets/home/food_log_widget.dart';
import '../widgets/common/week_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  // ✅ FIXED: Use super parameter
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadData(),
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
                child: _CustomRefreshWrapper(
                  onRefresh: () => homeProvider.refreshData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔥 FIRST: Calorie Summary Widget (TOP PRIORITY)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: CalorieSummaryWidget(),
                        ),

                        // Week Calendar Navigation with reduced spacing
                        WeekNavigationWidget(
                          selectedDate: homeProvider.selectedDate,
                          onDateChanged: (date) => homeProvider.changeDate(date),
                          daysToShow: 8, // 7 days back + today
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2), // Reduced from 16 to 8
                        ),

                        const SizedBox(height: 20),

                        // Macronutrient Widget
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: MacronutrientWidget(),
                        ),

                        const SizedBox(height: 20),

                        // 💰 NEW: Cost Summary Widget (OPTION 3 POSITION)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: CostSummaryWidget(),
                        ),

                        const SizedBox(height: 20),

                        // Food Log Widget
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: FoodLogWidget(
                            onFoodAdded: () => homeProvider.refreshData(),
                          ),
                        ),

                        // Bottom padding for better scrolling
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Custom refresh wrapper that handles pull-to-refresh
class _CustomRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const _CustomRefreshWrapper({
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryBlue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: child,
    );
  }
}