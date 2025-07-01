// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/home_provider.dart';
import '../widgets/home/calorie_summary_widget.dart';
import '../widgets/home/macronutrient_widget.dart';
import '../widgets/home/food_log_widget.dart';
import '../widgets/common/week_navigation_widget.dart'; // Import the new widget

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
              
              // Show main content with completely custom pull-to-refresh (no visual indicators)
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
                        // Week Calendar Navigation - Now using the reusable widget!
                        WeekNavigationWidget(
                          selectedDate: homeProvider.selectedDate,
                          onDateChanged: (date) => homeProvider.changeDate(date),
                          daysToShow: 8, // 7 days back + today
                        ),

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