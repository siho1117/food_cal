// lib/widgets/home/food_log_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/typography.dart';
import '../../providers/home_provider.dart';
import '../../data/models/food_item.dart';
import '../../data/services/image_storage_service.dart';
import '../../data/repositories/food_repository.dart';
import 'quick_edit_food_dialog.dart';

class FoodLogWidget extends StatelessWidget {
  final VoidCallback? onFoodAdded;

  const FoodLogWidget({
    super.key,
    this.onFoodAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Combine all food items from all meals
        final List<FoodItem> allFoodItems = [];
        
        for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
          final mealItems = homeProvider.entriesByMeal[mealType] ?? [];
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
                color: Colors.black.withValues(alpha: 0.05),
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
                    const Text('📋', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Food Log',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            '${allFoodItems.length} ${allFoodItems.length == 1 ? 'item' : 'items'} today',
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Food items list
              if (allFoodItems.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: allFoodItems.map((item) => _buildFoodItem(context, item, homeProvider)).toList(),
                ),

              // Bottom padding
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No food logged today',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of your food to get started!',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, FoodItem item, HomeProvider homeProvider) {
    final itemCalories = (item.calories * item.servingSize).round();
    final nutrition = item.getNutritionForServing();
    final protein = nutrition['proteins']!.round();
    final carbs = nutrition['carbs']!.round();
    final fat = nutrition['fats']!.round();
    
    // Get cost for serving - fix for null safety
    final itemCost = item.cost != null ? (item.cost! * item.servingSize) : 0.0;

    return GestureDetector(
      onTap: () => _showQuickEditDialog(context, item, homeProvider),
      onLongPress: () => _showDeleteConfirmation(context, item, homeProvider),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.transparent,
        child: Row(
          children: [
            // FIXED: Food image (80x80) with proper async loading
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
                      child: FutureBuilder<File?>(
                        future: _getImageFile(item.imagePath!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                            );
                          }
                          
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Error loading image ${item.imagePath}: $error');
                                return _buildFallbackIcon();
                              },
                            );
                          }
                          
                          return _buildFallbackIcon();
                        },
                      ),
                    )
                  : _buildFallbackIcon(),
            ),

            const SizedBox(width: 16),

            // Food details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Food name + cost
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTypography.displaySmall.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (itemCost > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.goldAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '\$${itemCost.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.goldAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // ROW 2: Serving size + time
                  Row(
                    children: [
                      Text(
                        '${item.servingSize} ${item.servingUnit}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.timestamp),
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ROW 3: Combined nutrition badge + Calorie badge
                  Row(
                    children: [
                      // Combined nutrition badge with icons
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💪', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 2),
                            Text('${protein}g', style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Text('🍞', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 2),
                            Text('${carbs}g', style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Text('🥑', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 2),
                            Text('${fat}g', style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Calorie badge on the right
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🔥',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${itemCalories}cal',
                              style: AppTypography.bodySmall.copyWith(
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

  // FIXED: Helper method to get image file using ImageStorageService
  Future<File?> _getImageFile(String imagePath) async {
    try {
      final ImageStorageService imageService = ImageStorageService();
      return await imageService.getImageFile(imagePath);
    } catch (e) {
      debugPrint('Error getting image file: $e');
      return null;
    }
  }

  // Helper method for fallback icon
  Widget _buildFallbackIcon() {
    return Icon(
      Icons.restaurant,
      color: Colors.grey[400],
      size: 40,
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
  Future<void> _showQuickEditDialog(BuildContext context, FoodItem item, HomeProvider homeProvider) async {
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
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        content: Text(
          'Remove "${item.name}" from your food log?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Delete',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final success = await _deleteItem(item, homeProvider, context);
      return success;
    }
    
    return false;
  }

  Future<bool> _deleteItem(FoodItem item, HomeProvider homeProvider, BuildContext context) async {
    try {
      final foodRepository = FoodRepository();
      final success = await foodRepository.deleteFoodEntry(item.id, item.timestamp);
      
      if (success) {
        homeProvider.refreshData();
        onFoodAdded?.call();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} deleted from your food log'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }
}