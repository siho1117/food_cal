// lib/data/models/food_item.dart
import 'package:flutter/foundation.dart'; // Added for debugPrint

/// Model class representing a food item recognized from an image or added manually
class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String? imagePath;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime timestamp;
  final double servingSize;
  final String servingUnit;
  final int? spoonacularId; // Kept for backward compatibility
  final double? cost; // NEW: Optional cost field for per-serving cost

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.imagePath,
    required this.mealType,
    required this.timestamp,
    required this.servingSize,
    required this.servingUnit,
    this.spoonacularId,
    this.cost, // NEW: Optional cost parameter
  });

  /// Create a FoodItem from API image analysis response (generic format)
  factory FoodItem.fromApiAnalysis(Map<String, dynamic> data, String mealType) {
    try {
      // Default values if something is missing
      double calories = 0.0;
      double proteins = 0.0;
      double carbs = 0.0;
      double fats = 0.0;
      String name = 'Unknown Food';
      int? spoonacularId;

      // Extract the food name
      if (data.containsKey('category')) {
        name = data['category']['name'] ?? 'Unknown Food';
      }

      // Extract nutritional information
      if (data.containsKey('nutrition')) {
        final nutrition = data['nutrition'];

        // Extract calories
        if (nutrition.containsKey('calories')) {
          if (nutrition['calories'] is num) {
            calories = (nutrition['calories'] as num).toDouble();
          } else if (nutrition['calories'] is Map &&
              nutrition['calories'].containsKey('value')) {
            calories =
                (nutrition['calories']['value'] as num?)?.toDouble() ?? 0.0;
          }
        }

        // Extract macronutrients from the nutrients array
        if (nutrition.containsKey('nutrients') &&
            nutrition['nutrients'] is List) {
          for (var nutrient in nutrition['nutrients']) {
            if (nutrient['name'] == 'Protein' ||
                nutrient['name'] == 'protein') {
              proteins = (nutrient['amount'] as num?)?.toDouble() ?? 0.0;
            } else if (nutrient['name'] == 'Carbohydrates' ||
                nutrient['name'] == 'carbohydrates') {
              carbs = (nutrient['amount'] as num?)?.toDouble() ?? 0.0;
            } else if (nutrient['name'] == 'Fat' || nutrient['name'] == 'fat') {
              fats = (nutrient['amount'] as num?)?.toDouble() ?? 0.0;
            }
          }
        }

        // Fallback: try direct properties if nutrients array didn't work
        if (proteins == 0.0 && nutrition.containsKey('protein')) {
          proteins = _extractNumericValue(nutrition['protein']) ?? 0.0;
        }
        if (carbs == 0.0 && nutrition.containsKey('carbs')) {
          carbs = _extractNumericValue(nutrition['carbs']) ?? 0.0;
        }
        if (fats == 0.0 && nutrition.containsKey('fat')) {
          fats = _extractNumericValue(nutrition['fat']) ?? 0.0;
        }
      }

      // Generate unique ID based on timestamp and name
      final now = DateTime.now();
      final id = '${now.millisecondsSinceEpoch}_${name.replaceAll(' ', '_').toLowerCase()}';

      return FoodItem(
        id: id,
        name: name,
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        mealType: mealType,
        timestamp: now,
        servingSize: 1.0,
        servingUnit: 'serving',
        spoonacularId: spoonacularId,
        cost: null, // API won't provide cost, so start with null
      );
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error parsing food item from API: $e');
      
      // Return a basic fallback item
      final now = DateTime.now();
      return FoodItem(
        id: '${now.millisecondsSinceEpoch}_unknown',
        name: 'Unknown Food',
        calories: 0.0,
        proteins: 0.0,
        carbs: 0.0,
        fats: 0.0,
        mealType: mealType,
        timestamp: now,
        servingSize: 1.0,
        servingUnit: 'serving',
        cost: null, // No cost for unknown items
      );
    }
  }

  /// Create a copy of this food item with modified properties
  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    String? imagePath,
    String? mealType,
    DateTime? timestamp,
    double? servingSize,
    String? servingUnit,
    int? spoonacularId,
    double? cost, // NEW: Include cost in copyWith
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      imagePath: imagePath ?? this.imagePath,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      spoonacularId: spoonacularId ?? this.spoonacularId,
      cost: cost ?? this.cost, // NEW: Include cost in copyWith
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'imagePath': imagePath,
      'mealType': mealType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'spoonacularId': spoonacularId,
      'cost': cost, // NEW: Include cost in storage
    };
  }

  /// Create from Map for retrieval from storage
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Food',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      proteins: (map['proteins'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (map['fats'] as num?)?.toDouble() ?? 0.0,
      imagePath: map['imagePath'],
      mealType: map['mealType'] ?? 'snack',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      servingSize: (map['servingSize'] as num?)?.toDouble() ?? 1.0,
      servingUnit: map['servingUnit'] ?? 'serving',
      spoonacularId: map['spoonacularId'],
      cost: (map['cost'] as num?)?.toDouble(), // NEW: Parse cost from storage
    );
  }

  /// Get nutrition values adjusted for actual serving size
  Map<String, double> getNutritionForServing() {
    return {
      'calories': calories * servingSize,
      'proteins': proteins * servingSize,
      'carbs': carbs * servingSize,
      'fats': fats * servingSize,
    };
  }

  /// Get the cost for the actual serving size
  /// Returns null if no cost is set
  double? getCostForServing() {
    if (cost == null) return null;
    return cost! * servingSize;
  }

  /// Get formatted cost string for display
  String getFormattedCost() {
    final servingCost = getCostForServing();
    if (servingCost == null) return '';
    return '\$${servingCost.toStringAsFixed(2)}';
  }

  /// Check if this food item has cost information
  bool get hasCost => cost != null && cost! > 0;

  /// Helper method to extract numeric values from API response
  static double? _extractNumericValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is Map && value.containsKey('value')) {
      return (value['value'] as num?)?.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, calories: $calories, mealType: $mealType, servingSize: $servingSize $servingUnit)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}