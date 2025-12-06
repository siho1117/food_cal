// lib/data/services/food_info_parser.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Service to parse food information from various text and JSON formats
/// Consolidates duplicate parsing logic previously in api_service and fallback_provider
class FoodInfoParser {
  // Singleton instance
  static final FoodInfoParser _instance = FoodInfoParser._internal();
  factory FoodInfoParser() => _instance;
  FoodInfoParser._internal();

  /// Extract food information from plain text content
  /// Uses regex patterns to find nutritional data
  Map<String, dynamic> extractFromText(String text) {
    try {
      debugPrint('🔍 Parsing text response: $text');

      // First, try to extract JSON from markdown code blocks (```json ... ```)
      final markdownJsonMatch = RegExp(
        r'```(?:json)?\s*(\{[^`]*\})\s*```',
        multiLine: true,
        dotAll: true
      ).firstMatch(text);

      if (markdownJsonMatch != null) {
        try {
          final jsonString = markdownJsonMatch.group(1)!;
          debugPrint('📦 Found JSON in markdown: $jsonString');
          final jsonData = jsonDecode(jsonString);

          final name = jsonData['name'] ?? 'Unknown Food';
          final calories = parseDoubleValue(jsonData['calories']) ?? 0.0;
          final protein = parseDoubleValue(jsonData['protein']) ?? 0.0;
          final carbs = parseDoubleValue(jsonData['carbs']) ?? 0.0;
          final fat = parseDoubleValue(jsonData['fat']) ?? 0.0;

          debugPrint('✅ Extracted from JSON: name=$name, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');
          return _formatResponse(name, calories, protein, carbs, fat);
        } catch (e) {
          debugPrint('❌ Failed to parse JSON from markdown: $e');
        }
      }

      // Try to find raw JSON (without markdown)
      final rawJsonMatch = RegExp(
        r'\{[^\{\}]*"name"[^\{\}]*\}',
        multiLine: true,
        dotAll: true
      ).firstMatch(text);

      if (rawJsonMatch != null) {
        try {
          final jsonString = rawJsonMatch.group(0)!;
          debugPrint('📦 Found raw JSON: $jsonString');
          final jsonData = jsonDecode(jsonString);

          final name = jsonData['name'] ?? 'Unknown Food';
          final calories = parseDoubleValue(jsonData['calories']) ?? 0.0;
          final protein = parseDoubleValue(jsonData['protein']) ?? 0.0;
          final carbs = parseDoubleValue(jsonData['carbs']) ?? 0.0;
          final fat = parseDoubleValue(jsonData['fat']) ?? 0.0;

          debugPrint('✅ Extracted from JSON: name=$name, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');
          return _formatResponse(name, calories, protein, carbs, fat);
        } catch (e) {
          debugPrint('❌ Failed to parse raw JSON: $e');
        }
      }

      // Fallback: Extract using regex patterns for text-based responses
      debugPrint('🔄 Falling back to regex extraction');

      // Extract food name
      String foodName = 'Unidentified Food Item';

      // Look for "Food Name:" or "Name:" patterns
      final nameMatches = RegExp(
        r'(?:Food\s*Name|Name|name|food)[:\s]+([^,\n]+)',
        caseSensitive: false
      ).firstMatch(text);

      if (nameMatches != null && nameMatches.groupCount >= 1) {
        foodName = nameMatches.group(1)!.trim();
      } else {
        // Alternative patterns - "this is", "contains", "appears to be"
        final altNameMatches = RegExp(
          r'(?:this\s*is|contains|appears to be)[:\s]*(.*?)(?:\.|$|\n)',
          caseSensitive: false
        ).firstMatch(text);
        if (altNameMatches != null && altNameMatches.groupCount >= 1) {
          foodName = altNameMatches.group(1)!.trim();
        }
      }

      // Extract calories
      double calories = 0.0;
      final caloriesMatches = RegExp(
        r'(?:Calories|Cal)[:\s]+(\d+\.?\d*)',
        caseSensitive: false
      ).firstMatch(text);
      if (caloriesMatches != null && caloriesMatches.groupCount >= 1) {
        calories = double.tryParse(caloriesMatches.group(1)!) ?? 0.0;
      }

      // Extract protein
      double protein = 0.0;
      final proteinMatches = RegExp(
        r'(?:Protein)[:\s]+(\d+\.?\d*)',
        caseSensitive: false
      ).firstMatch(text);
      if (proteinMatches != null && proteinMatches.groupCount >= 1) {
        protein = double.tryParse(proteinMatches.group(1)!) ?? 0.0;
      }

      // Extract carbs
      double carbs = 0.0;
      final carbsMatches = RegExp(
        r'(?:Carbs|Carbohydrates)[:\s]+(\d+\.?\d*)',
        caseSensitive: false
      ).firstMatch(text);
      if (carbsMatches != null && carbsMatches.groupCount >= 1) {
        carbs = double.tryParse(carbsMatches.group(1)!) ?? 0.0;
      }

      // Extract fat
      double fat = 0.0;
      final fatMatches = RegExp(
        r'(?:Fat)[:\s]+(\d+\.?\d*)',
        caseSensitive: false
      ).firstMatch(text);
      if (fatMatches != null && fatMatches.groupCount >= 1) {
        fat = double.tryParse(fatMatches.group(1)!) ?? 0.0;
      }

      debugPrint('Extracted: name=$foodName, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');

      // If we found a name but no nutritional data, assign default values
      if (foodName != 'Unidentified Food Item' &&
          calories == 0.0 && protein == 0.0 && carbs == 0.0 && fat == 0.0) {
        debugPrint('No nutrition data found, using defaults for $foodName');
        // Use generic defaults
        calories = 150.0;
        protein = 5.0;
        carbs = 20.0;
        fat = 8.0;
      }

      return _formatResponse(foodName, calories, protein, carbs, fat);
    } catch (e) {
      debugPrint('Error extracting food info from text: $e');
      return getUndefinedFoodResponse();
    }
  }

  /// Parse a numeric value from various formats
  double? parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove any non-numeric characters except decimal points
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  /// Get a standardized undefined food response
  Map<String, dynamic> getUndefinedFoodResponse() {
    return _formatResponse('Unidentified Food Item', 0.0, 0.0, 0.0, 0.0);
  }

  /// Format the parsed values into the standard response structure
  Map<String, dynamic> _formatResponse(
    String name,
    double calories,
    double protein,
    double carbs,
    double fat
  ) {
    return {
      'category': {'name': name},
      'nutrition': {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'nutrients': [
          {'name': 'Protein', 'amount': protein, 'unit': 'g'},
          {'name': 'Carbohydrates', 'amount': carbs, 'unit': 'g'},
          {'name': 'Fat', 'amount': fat, 'unit': 'g'},
        ]
      }
    };
  }
}
