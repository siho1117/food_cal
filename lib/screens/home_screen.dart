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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: No ChangeNotifierProvider here - use existing app-level provider!
    return Scaffold(
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
                color: AppTheme.primaryBlue,
                backgroundColor: Colors.white,
                strokeWidth: 2.5,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calorie Summary Widget (TOP PRIORITY)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: CalorieSummaryWidget(),
                      ),

                      // Week Calendar Navigation
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
    );
  }

  /// Build error state with retry functionality
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
                color: AppTheme.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              homeProvider.errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => homeProvider.refreshData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Navigate to settings or try to reinitialize
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Text(
                'Check Settings',
                style: TextStyle(color: AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}