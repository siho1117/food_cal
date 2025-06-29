// lib/widgets/home/food_log_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
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

            // Main content
            if (!hasEntries)
              _buildEmptyState()
            else
              _buildFoodLogCard(foodByMeal, homeProvider),
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
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'TODAY\'S FOOD LOG',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🍽️',
            style: const TextStyle(fontSize: 48),
          ),
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
    // Combine all food items from all meals into a single chronological list
    final allFoodItems = <FoodItem>[];
    
    // Add all items from all meal types
    for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final mealItems = foodByMeal[mealType] ?? [];
      allFoodItems.addAll(mealItems);
    }
    
    // Sort by timestamp (most recent first)
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
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header showing total items
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Food',
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${allFoodItems.length} ${allFoodItems.length == 1 ? 'item' : 'items'} logged',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey[100],
          ),
          
          // All food items in a list
          ...allFoodItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildModernFoodItem(item, homeProvider),
                // Add subtle divider between items (except last)
                if (index < allFoodItems.length - 1)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 1,
                    color: Colors.grey[50],
                  ),
              ],
            );
          }).toList(),
          
          // Bottom padding
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModernFoodItem(FoodItem item, HomeProvider homeProvider) {
    final itemCalories = (item.calories * item.servingSize).round();
    final nutrition = item.getNutritionForServing();
    final protein = nutrition['proteins']!.round();
    final carbs = nutrition['carbs']!.round();
    final fat = nutrition['fats']!.round();
    
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline,
              color: Colors.red[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: AppTextStyles.getBodyStyle().copyWith(
                color: Colors.red[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(item),
      onDismissed: (direction) => _deleteItem(item, homeProvider),
      child: InkWell(
        onTap: () => _showServingSizeDialog(item, homeProvider),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Food image
              _buildFoodImage(item),
              
              const SizedBox(width: 20),
              
              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name
                    Text(
                      item.name,
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Time logged
                    Text(
                      _formatTime(item.timestamp),
                      style: AppTextStyles.getBodyStyle().copyWith(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Macro breakdown
                    Row(
                      children: [
                        _buildMacroIndicator('${protein}g', Colors.red[400]!),
                        const SizedBox(width: 12),
                        _buildMacroIndicator('${carbs}g', Colors.orange[400]!),
                        const SizedBox(width: 12),
                        _buildMacroIndicator('${fat}g', Colors.blue[400]!),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Calories with flame icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔥',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$itemCalories',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'calories',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(FoodItem item) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: item.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(item.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: AppTheme.primaryBlue.withOpacity(0.6),
                      size: 36,
                    ),
                  );
                },
              ),
            )
          : Icon(
              Icons.fastfood,
              color: AppTheme.primaryBlue.withOpacity(0.6),
              size: 36,
            ),
    );
  }

  Widget _buildMacroIndicator(String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Delete confirmation dialog
  Future<bool?> _showDeleteConfirmation(FoodItem item) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Food Item?',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}" from your food log?',
          style: AppTextStyles.getBodyStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.getBodyStyle().copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Delete item from repository and refresh
  Future<void> _deleteItem(FoodItem item, HomeProvider homeProvider) async {
    try {
      final success = await _foodRepository.deleteFoodEntry(item.id, item.timestamp);
      
      if (success) {
        // Refresh the home provider to update the UI
        homeProvider.refreshData();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} deleted from your food log'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete food item. Please try again.'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Show serving size adjustment dialog
  Future<void> _showServingSizeDialog(FoodItem item, HomeProvider homeProvider) async {
    double newServingSize = item.servingSize;
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Adjust Serving Size',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Serving Size',
                        style: AppTextStyles.getBodyStyle(),
                      ),
                      Text(
                        '${newServingSize.toStringAsFixed(1)} ${item.servingUnit}',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: newServingSize,
                    min: 0.1,
                    max: 5.0,
                    divisions: 49,
                    activeColor: AppTheme.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        newServingSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calories: ${(item.calories * newServingSize).round()}',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.getBodyStyle().copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(newServingSize),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Update',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result != item.servingSize) {
      // Update the item's serving size
      final updatedItem = item.copyWith(servingSize: result);
      await _foodRepository.updateFoodEntry(updatedItem);
      
      // Refresh the home provider to show updated data
      homeProvider.refreshData();
    }
  }
}