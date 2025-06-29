// lib/widgets/home/food_log_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';
import '../../providers/home_provider.dart';

class FoodLogWidget extends StatefulWidget {
  final bool showHeader;
  final VoidCallback? onFoodAdded;

  const FoodLogWidget({
    super.key,
    this.showHeader = true,
    this.onFoodAdded,
  });

  @override
  State<FoodLogWidget> createState() => _FoodLogWidgetState();
}

class _FoodLogWidgetState extends State<FoodLogWidget> {
  final FoodRepository _foodRepository = FoodRepository();

  // Track expanded sections
  final Map<String, bool> _expandedSections = {
    'breakfast': true,
    'lunch': true,
    'dinner': true,
    'snack': true,
  };

  // Calculate total calories for a meal
  int _calculateMealCalories(List<FoodItem> items) {
    return items.fold(
        0, (sum, item) => sum + (item.calories * item.servingSize).round());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Removed individual loading state - rely on page-level loading

        // Get food entries from provider
        final foodByMeal = homeProvider.entriesByMeal;
        
        // Check if there are any food entries
        final bool hasEntries = foodByMeal.values.any((list) => list.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional header
            if (widget.showHeader) ...[
              _buildHeader(homeProvider),
              const SizedBox(height: 16),
            ],

            // No entries message
            if (!hasEntries)
              _buildEmptyState(),

            // Food entries by meal type
            if (hasEntries) ...[
              ..._buildMealSections(foodByMeal, homeProvider),
            ],
          ],
        );
      },
    );
  }
  
  Widget _buildHeader(HomeProvider homeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'TODAY\'S FOOD LOG',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            onPressed: () => homeProvider.refreshData(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_food,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Food Entries for Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the camera or "Add Food" button to log your meals',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  // Removed individual _buildLoadingState() method since we use page-level loading
  
  List<Widget> _buildMealSections(Map<String, List<FoodItem>> foodByMeal, HomeProvider homeProvider) {
    return ['breakfast', 'lunch', 'dinner', 'snack'].map((mealType) {
      final mealItems = foodByMeal[mealType] ?? [];

      // Skip empty meal types
      if (mealItems.isEmpty) {
        return const SizedBox.shrink();
      }

      final totalCalories = _calculateMealCalories(mealItems);
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildMealSection(
          mealType: mealType,
          mealItems: mealItems,
          totalCalories: totalCalories,
          homeProvider: homeProvider,
        ),
      );
    }).toList();
  }
  
  Widget _buildMealSection({
    required String mealType,
    required List<FoodItem> mealItems,
    required int totalCalories,
    required HomeProvider homeProvider,
  }) {
    final isExpanded = _expandedSections[mealType] ?? true;
    
    return Column(
      children: [
        // Meal header
        InkWell(
          onTap: () {
            setState(() {
              _expandedSections[mealType] = !isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Meal icon with background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMealTypeIcon(mealType),
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Meal title
                Text(
                  _formatMealType(mealType),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                
                const Spacer(),
                
                // Calorie count
                Text(
                  '$totalCalories cal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                
                // Expand/collapse button
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _expandedSections[mealType] = !isExpanded;
                    });
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
        
        // Food items list
        if (isExpanded) ...[
          // Divider between header and list
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[100],
          ),
          // List of food items
          ...mealItems.map((item) => _buildFoodItemTile(item, mealType, homeProvider)),
        ],
      ],
    );
  }
  
  Widget _buildFoodItemTile(FoodItem item, String mealType, HomeProvider homeProvider) {
    // Calculate calories for this item with serving size
    final itemCalories = (item.calories * item.servingSize).round();

    // Calculate nutrient values with serving size
    final nutrition = item.getNutritionForServing();
    final protein = nutrition['proteins']!.round();
    final carbs = nutrition['carbs']!.round();
    final fat = nutrition['fats']!.round();

    // Build the actual food item content
    Widget foodItemContent = InkWell(
      onTap: () {
        // Show serving size adjustment dialog
        _showServingSizeDialog(item, homeProvider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Food image (if available)
            _buildFoodImage(item),
            
            const SizedBox(width: 12),
            
            // Food details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Serving size
                  Text(
                    '${item.servingSize} ${item.servingUnit}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Macros
                  Text(
                    'P: ${protein}g  C: ${carbs}g  F: ${fat}g',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Calories
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${itemCalories}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'cal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),