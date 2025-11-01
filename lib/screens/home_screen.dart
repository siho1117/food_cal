// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme_background.dart';
import '../config/design_system/theme_design.dart';
import '../providers/home_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/home/calorie_summary_widget.dart';
import '../widgets/home/macronutrient_widget.dart';
import '../widgets/home/cost_summary_widget.dart';
import '../widgets/home/food_log_widget.dart';
import '../widgets/common/week_navigation_widget.dart';
import '../widgets/common/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: ThemeBackground.getGradient(themeProvider.selectedGradient),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(currentPage: 'home'),
            body: Consumer<HomeProvider>(
              builder: (context, homeProvider, child) {
                if (homeProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                if (homeProvider.errorMessage != null) {
                  return _buildErrorState(context, homeProvider);
                }
                
                return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (notification) {
                    notification.disallowIndicator();
                    return true;
                  },
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // 1. Calorie Summary (MOVED TO TOP - largest card)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: CalorieSummaryWidget(),
                        ),

                        const SizedBox(height: 20),

                        // 2. Week Navigation
                        WeekNavigationWidget(
                          selectedDate: homeProvider.selectedDate,
                          onDateChanged: (date) => homeProvider.changeDate(date),
                          daysToShow: 8,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                        ),

                        const SizedBox(height: 20),

                        // 3. Macronutrient Widget
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: MacronutrientWidget(),
                        ),

                        const SizedBox(height: 20),

                        // 4. Cost Summary Widget
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: CostSummaryWidget(),
                        ),

                        const SizedBox(height: 20),

                        // 5. Food Log Widget
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
                );
              },
            ),
          ),
        );
      },
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
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              homeProvider.errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
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
                foregroundColor: AppColors.textDark,
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