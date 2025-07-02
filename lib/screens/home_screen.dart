// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/home_provider.dart';
import '../widgets/home/calorie_summary_widget.dart';
import '../widgets/home/macronutrient_widget.dart';
import '../widgets/home/food_log_widget.dart';
import '../widgets/common/week_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Custom refresh wrapper that handles pull-to-refresh without any visual indicators
  Widget _CustomRefreshWrapper({
    required Future<void> Function() onRefresh,
    required Widget child,
  }) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Track downward pan gesture
        if (details.delta.dy > 0) {
          // User is pulling down
        }
      },
      onPanEnd: (details) {
        // Check if it was a significant pull down gesture
        if (details.velocity.pixelsPerSecond.dy > 300) {
          // Trigger refresh for fast downward swipe
          onRefresh();
        }
      },
      child: child,
    );
  }
}