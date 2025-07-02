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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final foodByMeal = homeProvider.entriesByMeal;
        final hasEntries = foodByMeal.values.any((list) => list.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader) ...[
              _buildHeader(foodByMeal),
              const SizedBox(height: 16),
            ],

            if (!hasEntries)
              _buildEmptyState()
            else
              _buildFoodLogCard(foodByMeal, homeProvider),
          ],
        );
      },
    );
  }

  Widget _buildHeader(Map<String, List<FoodItem>> foodByMeal) {
    final allItems = foodByMeal.values.expand((x) => x).toList();
    final totalCalories = allItems.fold(0, (sum, item) => sum + (item.calories * item.servingSize).round());
    final mealCount = foodByMeal.values.where((list) => list.isNotEmpty).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('🍽️', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Food Log',
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$mealCount meals • $totalCalories calories',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          // Header section
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
          
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            color: Colors.grey[100],
          ),
          
          // Food items list with swipe-to-delete and tap-to-edit
          ...allFoodItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            return Column(
              children: [
                Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: _buildDeleteBackground(),
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

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodItem item, HomeProvider homeProvider) {
    final itemCalories = (item.calories * item.servingSize).round();
    final nutrition = item.getNutritionForServing();
    final protein = nutrition['proteins']!.round();
    final carbs = nutrition['carbs']!.round();
    final fat = nutrition['fats']!.round();

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
            
            // Food details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Name and calories
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔥', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '$itemCalories',
                              style: AppTextStyles.getNumericStyle().copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // ROW 2: Time and serving info with edit indicator
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
                      const Spacer(),
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ROW 3: Progress bar
                  _buildProgressBar(itemCalories, homeProvider.calorieGoal),
                  
                  const SizedBox(height: 8),
                  
                  // ROW 4: Macros
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildMacroChip('🥩', '${protein}g'),
                      _buildMacroChip('🍞', '${carbs}g'),
                      _buildMacroChip('🥑', '${fat}g'),
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

  Widget _buildFoodIcon() {
    return Icon(
      Icons.restaurant,
      color: AppTheme.primaryBlue.withOpacity(0.6),
      size: 32,
    );
  }

  Widget _buildProgressBar(int itemCalories, int calorieGoal) {
    final progress = (itemCalories / calorieGoal * 100).clamp(0.0, 100.0);
    
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: progress > 20 ? AppTheme.primaryBlue : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${progress.round()}% of goal',
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroChip(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _showQuickEditDialog(FoodItem item, HomeProvider homeProvider) async {
    await showDialog<void>(
      context: context,
      builder: (context) => QuickEditFoodDialog(
        foodItem: item,
        onUpdated: () {
          // Single provider update after successful edit
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