// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../config/design_system/gradient_background.dart';
import '../providers/home_provider.dart';
import '../widgets/home/calorie_summary_widget.dart';
import '../widgets/home/macronutrient_widget.dart';
import '../widgets/home/cost_summary_widget.dart';
import '../widgets/home/food_log_widget.dart';
import '../widgets/common/week_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen with gradient background
    return GradientBackground(
      gradientName: 'home', // Uses home gradient from theme.dart
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent to show gradient
        body: SafeArea(
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (homeProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white, // White spinner looks better on gradient
                  ),
                );
              }

              // Handle error state
              if (homeProvider.errorMessage != null) {
                return _buildErrorState(context, homeProvider);
              }
              
              return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: () => homeProvider.refreshData(),
                  color: Colors.white, // White refresh indicator on gradient
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  strokeWidth: 2.5,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calorie Summary Widget
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: CalorieSummaryWidget(),
                        ),

                        // Week Navigation Widget
                        WeekNavigationWidget(
                          selectedDate: homeProvider.selectedDate,
                          onDateChanged: (date) => homeProvider.changeDate(date),
                          daysToShow: 8, // 7 days back + today
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        ),

                        const SizedBox(height: 20),

                        // Macronutrient Widget
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: MacronutrientWidget(),
                        ),

                        const SizedBox(height: 20),

                        // Cost Summary Widget
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

                        // Bottom padding for navigation bar
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

  Widget _buildErrorState(BuildContext context, HomeProvider homeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text on gradient
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              homeProvider.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8), // Semi-transparent white
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => homeProvider.refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}