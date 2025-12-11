// lib/utils/nutrition_scaler.dart

/// Utility class to scale nutrition values by a fixed multiplier
///
/// This class applies a 1.017x multiplier to nutrition values to add variance
/// and make the data appear more professional/accurate. The scaling is transparent
/// to the rest of the app - values are still treated as "1.0 serving".
///
/// Example:
/// - Input (1.0 serving): calories: 420, protein: 22, carbs: 38, fat: 24
/// - Output (1.0 serving): calories: 427, protein: 22, carbs: 39, fat: 24
class NutritionScaler {
  // Private constructor to prevent instantiation
  NutritionScaler._();

  /// Multiplier applied to nutrition values (1.017)
  /// This adds ~1.7% variance to make values appear less rounded
  static const double _multiplier = 1.017;

  /// Scale nutrition values from API response
  ///
  /// Takes raw API data and multiplies calories, protein, carbs, and fat by 1.017,
  /// rounding to whole numbers. All other fields pass through unchanged.
  ///
  /// Handles both flat structure and nested structure:
  /// - Flat: {'calories': 220, 'protein': 15, ...}
  /// - Nested: {'nutrition': {'calories': 220, 'protein': 15, ...}, ...}
  ///
  /// The scaled values are still treated as "1.0 serving" by the rest of the app,
  /// allowing normal serving size adjustments to work correctly.
  static Map<String, dynamic> scale(Map<String, dynamic> rawData) {
    if (rawData.isEmpty) return rawData;

    // Check if nutrition data is nested inside 'nutrition' key
    final bool isNested = rawData.containsKey('nutrition') &&
                          rawData['nutrition'] is Map<String, dynamic>;

    if (isNested) {
      // Handle nested structure - scale values inside 'nutrition' object
      final nutrition = rawData['nutrition'] as Map<String, dynamic>;

      return {
        ...rawData,
        'nutrition': {
          'calories': _scaleValue(nutrition['calories']),
          'protein': _scaleValue(nutrition['protein']),
          'carbs': _scaleValue(nutrition['carbs']),
          'fat': _scaleValue(nutrition['fat']),

          // Pass through other nutrition fields unchanged
          ...nutrition.entries
              .where((e) => !['calories', 'protein', 'carbs', 'fat'].contains(e.key))
              .fold<Map<String, dynamic>>({}, (map, entry) {
                map[entry.key] = entry.value;
                return map;
              }),
        },
      };
    } else {
      // Handle flat structure - scale values at top level
      return {
        'calories': _scaleValue(rawData['calories']),
        'protein': _scaleValue(rawData['protein']),
        'carbs': _scaleValue(rawData['carbs']),
        'fat': _scaleValue(rawData['fat']),

        // Pass through all other fields unchanged
        ...rawData.entries
            .where((e) => !['calories', 'protein', 'carbs', 'fat'].contains(e.key))
            .fold<Map<String, dynamic>>({}, (map, entry) {
              map[entry.key] = entry.value;
              return map;
            }),
      };
    }
  }

  /// Scale a single nutrition value by the multiplier and round to whole number
  ///
  /// Examples:
  /// - 420 × 1.017 = 427.14 → 427
  /// - 22 × 1.017 = 22.374 → 22
  /// - 38 × 1.017 = 38.646 → 39
  /// - 24 × 1.017 = 24.408 → 24
  static double _scaleValue(dynamic value) {
    if (value == null) return 0.0;

    // Convert to number (handle both int and double, or string numbers)
    final num numValue = value is num
        ? value
        : double.tryParse(value.toString()) ?? 0;

    // Multiply and round to whole number
    return (numValue * _multiplier).roundToDouble();
  }
}
