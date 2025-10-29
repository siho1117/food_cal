// lib/widgets/food/food_item_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/design_system/theme_design.dart';
import '../../data/models/food_item.dart';
import '../../data/services/image_storage_service.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate values based on serving size
    final nutritionValues = foodItem.getNutritionForServing();

    // Extract values and log them for debugging
    final calories = nutritionValues['calories']!.round();
    final protein = nutritionValues['proteins']!.round().toString();
    final carbs = nutritionValues['carbs']!.round().toString();
    final fat = nutritionValues['fats']!.round().toString();

    // Print for debugging
    debugPrint('FoodItemCard - ${foodItem.name}: calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');
    debugPrint('Original values - calories: ${foodItem.calories}, proteins: ${foodItem.proteins}, carbs: ${foodItem.carbs}, fats: ${foodItem.fats}');
    debugPrint('Serving size: ${foodItem.servingSize}');

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // FIXED: Food image with proper async loading
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: foodItem.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FutureBuilder<File?>(
                          future: _getImageFile(foodItem.imagePath!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
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
                                  debugPrint('Error loading image ${foodItem.imagePath}: $error');
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

              const SizedBox(width: 12),

              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and meal type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            foodItem.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            foodItem.mealType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppLegacyColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Nutrition info
                    Row(
                      children: [
                        _buildNutritionChip('🔥', '${calories}cal'),
                        const SizedBox(width: 8),
                        _buildNutritionChip('💪', '${protein}g'),
                        const SizedBox(width: 8),
                        _buildNutritionChip('🍞', '${carbs}g'),
                        const SizedBox(width: 8),
                        _buildNutritionChip('🥑', '${fat}g'),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Serving info
                    Text(
                      '${foodItem.servingSize} ${foodItem.servingUnit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<File?> _getImageFile(String imagePath) async {
    try {
      final ImageStorageService imageService = ImageStorageService();
      return await imageService.getImageFile(imagePath);
    } catch (e) {
      debugPrint('Error getting image file: $e');
      return null;
    }
  }

  Widget _buildFallbackIcon() {
    return const Icon(
      Icons.fastfood,
      color: AppLegacyColors.primaryBlue,
      size: 30,
    );
  }
}