// lib/widgets/home/food_log_widget.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/food_item.dart';
import '../../services/food_image_service.dart';
import 'quick_edit_food_dialog.dart';
import '../common/quick_actions_dialog.dart';

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
          GlassCardStyle.borderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassCardStyle.blurSigma,
              sigmaY: GlassCardStyle.blurSigma,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                border: Border.all(
                  color: borderColor,
                  width: GlassCardStyle.borderWidth,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        const AnimatedEmoji(
                          AnimatedEmojis.spaghetti,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.foodLog,
                          style: TextStyle(
                            fontSize: AppWidgetTheme.fontSizeLG,
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            shadows: AppWidgetTheme.textShadows,
                          ),
                        ),
                      ],
                    ),
                    // Add button
                    IconButton(
                      onPressed: () => showQuickActionsDialog(context),
                      icon: Icon(Icons.add, color: textColor),
                      tooltip: AppLocalizations.of(context)!.quickActions,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.noFoodLoggedToday,
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
              l10n.takePhotoOrAddManually,
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
              onPressed: () => showQuickActionsDialog(context),
              icon: Icon(
                Icons.add,
                size: 18,
                color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
              ),
              label: Text(
                l10n.addFood,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDialogTheme.backdropBlurSigmaX,
                sigmaY: AppDialogTheme.backdropBlurSigmaY,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
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
                                style: const TextStyle(
                                  fontSize: AppWidgetTheme.fontSizeMD,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatTime(context, item.timestamp)}${itemCost > 0 ? ' • \$${itemCost.toStringAsFixed(2)}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
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
                      color: Colors.white.withValues(alpha: 0.3),
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
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              Text(
                                '${protein}P • ${carbs}C • ${fat}F',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Calories
                        Text(
                          '$itemCalories ${AppLocalizations.of(context)!.cal}',
                          style: const TextStyle(
                            fontSize: AppWidgetTheme.fontSizeLG,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  String _formatTime(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? l10n.pm : l10n.am;
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: Text(
          l10n.deleteFoodItem,
          style: AppDialogTheme.titleStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppDialogTheme.cancelButtonStyle,
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: AppDialogTheme.buttonGap),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await homeProvider.deleteFoodEntry(item.id);
            },
            style: AppDialogTheme.destructiveButtonStyle,
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}