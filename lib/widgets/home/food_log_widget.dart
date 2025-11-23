// lib/widgets/home/food_log_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/food_item.dart';
import '../../services/food_image_service.dart';
import 'quick_edit_food_dialog.dart';

class FoodLogWidget extends StatelessWidget {
  final VoidCallback? onFoodAdded;

  const FoodLogWidget({
    super.key,
    this.onFoodAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, ThemeProvider>(
      builder: (context, homeProvider, themeProvider, child) {
        // Get all food items
        final allFoodItems = List<FoodItem>.from(homeProvider.foodEntries);

        // Sort by timestamp (newest first)
        allFoodItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Get theme-adaptive colors
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
            border: Border.all(
              color: borderColor,
              width: AppWidgetTheme.cardBorderWidth,
            ),
          ),
          child: Padding(
            padding: AppWidgetTheme.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title with icon
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: AppWidgetTheme.fontSizeLG,
                          color: textColor,
                          shadows: AppWidgetTheme.textShadows,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Food Log',
                          style: TextStyle(
                            fontSize: AppWidgetTheme.fontSizeLG,
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            shadows: AppWidgetTheme.textShadows,
                          ),
                        ),
                      ],
                    ),
                    // Add button
                    IconButton(
                      onPressed: () => _showManualEntryDialog(context, homeProvider),
                      icon: Icon(Icons.add, color: textColor),
                      tooltip: 'Add Food Manually',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Food items list or empty state
                if (allFoodItems.isEmpty)
                  _buildEmptyState(context, textColor, homeProvider)
                else
                  SlidableAutoCloseBehavior(
                    child: Column(
                      children: allFoodItems
                          .map((item) => _buildFoodItem(
                                context,
                                item,
                                homeProvider,
                                textColor,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color textColor,
    HomeProvider homeProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 48,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
            ),
            const SizedBox(height: 16),
            Text(
              'No food logged today',
              style: TextStyle(
                color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                fontSize: AppWidgetTheme.fontSizeML,
                fontWeight: FontWeight.w500,
                shadows: AppWidgetTheme.textShadows,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo or add manually',
              style: TextStyle(
                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigh),
                fontSize: AppWidgetTheme.fontSizeMS,
                shadows: AppWidgetTheme.textShadows,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Add Food button
            OutlinedButton.icon(
              onPressed: () => _showManualEntryDialog(context, homeProvider),
              icon: Icon(
                Icons.add,
                size: 18,
                color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
              ),
              label: Text(
                'Add Food',
                style: TextStyle(
                  color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: textColor.withValues(alpha: AppWidgetTheme.opacityHigh),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(
    BuildContext context,
    FoodItem item,
    HomeProvider homeProvider,
    Color textColor,
  ) {
    final nutrition = item.getNutritionForServing();
    final itemCalories = nutrition['calories']!.round();
    final protein = nutrition['proteins']!.round();
    final carbs = nutrition['carbs']!.round();
    final fat = nutrition['fats']!.round();
    final itemCost = item.getCostForServing() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) {
                _showDeleteConfirmation(context, item, homeProvider);
              },
              backgroundColor: AppDialogTheme.colorDestructive,
              borderRadius: BorderRadius.circular(16),
              autoClose: true,
              padding: EdgeInsets.zero,
              child: const Center(
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => _showQuickEditDialog(context, item, homeProvider),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Top section: Image + Title
                Row(
                  children: [
                    // Food image
                    _buildFoodImage(item),

                    const SizedBox(width: 12),

                    // Title section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: AppWidgetTheme.fontSizeMD,
                              fontWeight: FontWeight.w600,
                              color: AppWidgetTheme.colorPrimaryDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatTime(item.timestamp)}${itemCost > 0 ? ' • \$${itemCost.toStringAsFixed(2)}' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),

                const SizedBox(height: 12),

                // Bottom section: Quantity + Macros | Calories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity + Macros
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '×${item.servingSize.toStringAsFixed(item.servingSize.truncateToDouble() == item.servingSize ? 0 : 1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            '${protein}P • ${carbs}C • ${fat}F',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calories
                    Text(
                      '$itemCalories cal',
                      style: TextStyle(
                        fontSize: AppWidgetTheme.fontSizeLG,
                        fontWeight: FontWeight.w700,
                        color: AppWidgetTheme.colorPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(FoodItem item) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: item.imagePath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<File?>(
                future: FoodImageService.getImageFile(item.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildImagePlaceholder();
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    );
                  }

                  return _buildImagePlaceholder();
                },
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant,
        size: 24,
        color: Colors.grey[400],
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

  Future<void> _showQuickEditDialog(
    BuildContext context,
    FoodItem item,
    HomeProvider homeProvider,
  ) async {
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

  void _showDeleteConfirmation(
    BuildContext context,
    FoodItem item,
    HomeProvider homeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: const Text(
          'Delete Food Item',
          style: AppDialogTheme.titleStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppDialogTheme.cancelButtonStyle,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppDialogTheme.buttonGap),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await homeProvider.deleteFoodEntry(item.id);
            },
            style: AppDialogTheme.destructiveButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualEntryDialog(
    BuildContext context,
    HomeProvider homeProvider,
  ) async {
    // Create an empty food item for manual entry
    final emptyFoodItem = FoodItem.empty();

    await showDialog<void>(
      context: context,
      builder: (context) => QuickEditFoodDialog(
        foodItem: emptyFoodItem,
        onUpdated: () {
          homeProvider.refreshData();
        },
      ),
    );
  }
}