// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
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
                  child: CircularProgressIndicator(),
                );
              }
              
              // Show main content with RefreshIndicator for pull-to-refresh
              return RefreshIndicator(
                onRefresh: () => homeProvider.refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header text
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                        child: Text(
                          'DAILY SUMMARY',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                            letterSpacing: 1.5,
                          ),
                        ),
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

                      // Today's Food Log with Add Food button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                              // Header row with title only
                              const Text(
                                'TODAY\'S FOOD LOG',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Food log widget
                            const FoodLogWidget(
                              showHeader: false, // Hide the header since we're showing it above
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Date selector for looking at different days
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              onPressed: () => homeProvider.previousDay(),
                              color: AppTheme.primaryBlue,
                            ),
                            TextButton(
                              onPressed: () => _showDatePicker(context, homeProvider),
                              child: Text(
                                homeProvider.isToday
                                    ? 'Today'
                                    : '${homeProvider.selectedDate.day}/${homeProvider.selectedDate.month}/${homeProvider.selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: homeProvider.canGoToNextDay 
                                  ? () => homeProvider.nextDay()
                                  : null,
                              color: AppTheme.primaryBlue,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80), // Space for bottom nav
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

  // Helper method to show date picker
  Future<void> _showDatePicker(BuildContext context, HomeProvider homeProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: homeProvider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != homeProvider.selectedDate) {
      homeProvider.changeDate(picked);
    }
  }
}