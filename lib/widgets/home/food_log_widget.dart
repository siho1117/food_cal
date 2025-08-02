// lib/widgets/home/food_log_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';
import '../../providers/home_provider.dart';
import 'quick_edit_food_dialog.dart';

class FoodLogWidget extends StatefulWidget {
  final VoidCallback? onFoodAdded;

  const FoodLogWidget({
    super.key,
    this.onFoodAdded,
  });

  @override
  State<FoodLogWidget> createState() => _FoodLogWidgetState();
}

class _FoodLogWidgetState extends State<FoodLogWidget> {
  final FoodRepository _foodRepository = FoodRepository();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final foodByMeal = homeProvider.entriesByMeal;
        final hasEntries = foodByMeal.values.any((list) => list.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REMOVED: Today's Food Log header - this was the redundant header

            if (!hasEntries)
              _buildEmptyState()
            else
              _buildFoodLogCard(foodByMeal, homeProvider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('🍽️', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No food logged yet',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the camera to start tracking your meals',
            textAlign: TextAlign.center,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLogCard(Map<String, List<FoodItem>> foodByMeal, HomeProvider homeProvider) {
    // Combine all food items chronologically
    final allFoodItems = <FoodItem>[];
    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final mealItems = foodByMeal[mealType] ?? [];
      allFoodItems.addAll(mealItems);
    }

    // Sort by timestamp (newest first)
    allFoodItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section - KEPT: Recent Food Log header only
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text('📋', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Food Log',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        '${allFoodItems.length} ${allFoodItems.length == 1 ? 'item' : 'items'} logged',
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider - KEPT: Exact same styling
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            color: Colors.grey[100],
          ),
          
          // Food items list with IMPROVED swipe-to-delete - KEPT: All existing design
          ...allFoodItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Column(
              children: [
                Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: _buildDeleteBackground(),
                  // IMPROVED: Better dismiss threshold
                  dismissThresholds: const {
                    DismissDirection.endToStart: 0.3, // Easier to trigger
                  },
                  // IMPROVED: Smoother animation timing
                  resizeDuration: const Duration(milliseconds: 200),
                  movementDuration: const Duration(milliseconds: 200),
                  confirmDismiss: (direction) async {
                    // Show confirmation dialog before dismissing
                    return await _showDeleteConfirmation(context, item, homeProvider);
                  },
                  onDismissed: (direction) async {
                    await _deleteItem(item, homeProvider);
                  },
                  child: _buildFoodItem(item, homeProvider),
                ),
                if (index < allFoodItems.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 1,
                    color: Colors.grey[50],
                  ),
              ],
            );
          }).toList(),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // IMPROVED: Better delete background with animation hint
  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 32), // Increased padding for better UX
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        // IMPROVED: Gradient background for better visual appeal
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red[400]!,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // IMPROVED: Add swipe indicator
          Icon(
            Icons.arrow_back_ios,
            color: Colors.white.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Delete',
            style: AppTextStyles.getBodyStyle().copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: 3-row layout food item (removed progress bar and individual macro chips)
  Widget _buildFoodItem(FoodItem item, HomeProvider homeProvider) {
    final itemCalories = (item.calories * item.servingSize).round();
    final nutrition = item.getNutritionForServing();
    final protein = nutrition['proteins']!.round();
    final carbs = nutrition['carbs']!.round();
    final fat = nutrition['fats']!.round();
    
    // Get cost for serving
    final itemCost = item.getCostForServing();

    return GestureDetector(
      onTap: () => _showQuickEditDialog(item, homeProvider),
      onLongPress: () => _showDeleteConfirmation(context, item, homeProvider),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.transparent,
        child: Row(
          children: [
            // Food image (80x80)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: item.imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFoodIcon();
                        },
                      ),
                    )
                  : _buildFoodIcon(),
            ),
            
            const SizedBox(width: 16),
            
            // Food details - NEW: 3-row layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Name and cost badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.getSubHeadingStyle().copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      
                      // Cost badge (only if cost exists)
                      if (itemCost != null && itemCost > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('💰', style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                itemCost.toStringAsFixed(2),
                                style: AppTextStyles.getNumericStyle().copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // ROW 2: Time and serving info
                  Row(
                    children: [
                      Text(
                        '${_formatTime(item.timestamp)} • ${item.servingSize} ${item.servingUnit}',
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ROW 3: Combined nutrition badge + Calorie badge (NEW)
                  Row(
                    children: [
                      // Combined nutrition badge with icons
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Protein
                            Text('🥩', style: const TextStyle(fontSize: 11)),
                            Text(
                              '${protein}g',
                              style: AppTextStyles.getBodyStyle().copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Carbs
                            Text('🍞', style: const TextStyle(fontSize: 11)),
                            Text(
                              '${carbs}g',
                              style: AppTextStyles.getBodyStyle().copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Fat
                            Text('🥑', style: const TextStyle(fontSize: 11)),
                            Text(
                              '${fat}g',
                              style: AppTextStyles.getBodyStyle().copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Calorie badge on the right
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🔥',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${itemCalories}cal',
                              style: AppTextStyles.getNumericStyle().copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildFoodIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.restaurant,
        color: Colors.grey[400],
        size: 32,
      ),
    );
  }

  // Time formatting helper
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  // Dialog and interaction methods
  Future<void> _showQuickEditDialog(FoodItem item, HomeProvider homeProvider) async {
    await showDialog<void>(
      context: context,
      builder: (context) => QuickEditFoodDialog(
        foodItem: item,
        onUpdated: () {
          homeProvider.refreshData();
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, FoodItem item, HomeProvider homeProvider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Food Item',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        content: Text(
          'Remove "${item.name}" from your food log?',
          style: AppTextStyles.getBodyStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _deleteItem(FoodItem item, HomeProvider homeProvider) async {
    try {
      final success = await _foodRepository.deleteFoodEntry(item.id, item.timestamp);
      
      if (success && mounted) {
        homeProvider.refreshData();
        widget.onFoodAdded?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from food log'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete. Please try again.'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}