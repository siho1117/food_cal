// lib/data/services/api_service.dart
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'food_info_parser.dart';
import 'vertex_ai_service.dart'; // Vertex AI service
import '../../config/api_config.dart';
import '../../config/ai_prompts.dart';
import '../../utils/nutrition_scaler.dart';

/// Service to interact with Vertex AI for food recognition
/// Uses Google Cloud Vertex AI (Gemini 2.0 Flash) exclusively
///
/// Changed from: Gemini/Qwen with fallback
/// Now: Vertex AI only (no fallback for testing)
class FoodApiService {
  // Singleton instance
  static final FoodApiService _instance = FoodApiService._internal();
  factory FoodApiService() => _instance;
  FoodApiService._internal();

  // Food info parser
  final FoodInfoParser _parser = FoodInfoParser();

  // Vertex AI service
  final VertexAIService _vertexAI = VertexAIService();

  /// Analyze a food image and return recognition results
  /// Takes a [File] containing the food image
  /// [language] - Target language for food name (default: "English")
  /// Returns a Map containing the API response with scaled nutrition values
  Future<Map<String, dynamic>> analyzeImage(
    File imageFile, {
    String language = 'English',
  }) async {
    // Check if we've exceeded our daily quota
    if (await isDailyQuotaExceeded()) {
      throw Exception('Daily API quota exceeded. Please try again tomorrow.');
    }

    try {
      debugPrint('🔷 Analyzing image with Vertex AI...');

      // Combine system and user prompts
      final combinedPrompt = '${AiPrompts.foodImageSystemPrompt(language)}\n\n${AiPrompts.foodImageUserPrompt(language)}';

      // Call Vertex AI
      final rawResult = await _vertexAI.analyzeImage(
        imageFile,
        prompt: combinedPrompt,
        language: language,
      );

      // Increment quota usage for successful requests
      await incrementQuotaUsage();

      // Parse the result (Vertex AI returns text in same format as Gemini)
      final parsed = _parser.extractFromText(rawResult['_metadata'] != null
        ? (rawResult['text'] ?? '')
        : rawResult.toString());

      // Scale nutrition values before returning
      return NutritionScaler.scale(parsed);
    } catch (error) {
      // Log error
      await _logError('VertexAI', error.toString());
      debugPrint('❌ Vertex AI failed: $error');

      // Increment quota usage even on failure
      await incrementQuotaUsage();

      // Re-throw the error
      throw Exception('Vertex AI analysis failed: $error');
    }
  }


  /// Get detailed information about a specific food ingredient by name
  Future<Map<String, dynamic>> getFoodInformation(String name) async {
    // Check if we've exceeded our daily quota
    if (await isDailyQuotaExceeded()) {
      throw Exception('Daily API quota exceeded. Please try again tomorrow.');
    }

    try {
      debugPrint('🔷 Getting food info from Vertex AI for: $name');

      // Call Vertex AI
      final rawResult = await _vertexAI.getFoodInformation(
        name,
        language: 'English',
      );

      // Increment quota usage for successful requests
      await incrementQuotaUsage();

      // Parse the result
      final parsed = _parser.extractFromText(rawResult['_metadata'] != null
        ? (rawResult['text'] ?? '')
        : rawResult.toString());

      // Scale nutrition values before returning
      return NutritionScaler.scale(parsed);
    } catch (error) {
      // Log error
      await _logError('VertexAI', error.toString());
      debugPrint('❌ Vertex AI food info failed: $error');

      // Increment quota usage even on failure
      await incrementQuotaUsage();

      // Re-throw the error
      throw Exception('Vertex AI food information failed: $error');
    }
  }


  /// Log error for analytics (minimal data usage)
  Future<void> _logError(String service, String errorMessage) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing error log
      final errorLog = prefs.getStringList(ApiConfig.errorLogKey) ?? [];

      // Add new error with timestamp
      final errorEntry = '${DateTime.now().toIso8601String()}: $service - $errorMessage';
      errorLog.add(errorEntry);

      // Keep only last 10 errors to avoid excessive storage
      if (errorLog.length > 10) {
        errorLog.removeRange(0, errorLog.length - 10);
      }

      await prefs.setStringList(ApiConfig.errorLogKey, errorLog);
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error logging API error: $e');
    }
  }

  /// Check if daily quota has been exceeded
  Future<bool> isDailyQuotaExceeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final quotaUsed = prefs.getInt(ApiConfig.quotaUsedKey) ?? 0;
      final quotaDate = prefs.getString(ApiConfig.quotaDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Reset quota if it's a new day
      if (quotaDate != today) {
        await prefs.setInt(ApiConfig.quotaUsedKey, 0);
        await prefs.setString(ApiConfig.quotaDateKey, today);
        return false;
      }
      
      return quotaUsed >= ApiConfig.dailyQuotaLimit;
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error checking quota: $e');
      return false;
    }
  }

  /// Increment the daily quota usage
  Future<void> incrementQuotaUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final quotaUsed = prefs.getInt(ApiConfig.quotaUsedKey) ?? 0;
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      await prefs.setInt(ApiConfig.quotaUsedKey, quotaUsed + 1);
      await prefs.setString(ApiConfig.quotaDateKey, today);
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('API quota used: ${quotaUsed + 1}/${ApiConfig.dailyQuotaLimit}');
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error incrementing quota: $e');
    }
  }

  /// Get current quota usage for display
  Future<Map<String, dynamic>> getQuotaInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final quotaUsed = prefs.getInt(ApiConfig.quotaUsedKey) ?? 0;
      final quotaDate = prefs.getString(ApiConfig.quotaDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Reset quota if it's a new day
      if (quotaDate != today) {
        await prefs.setInt(ApiConfig.quotaUsedKey, 0);
        await prefs.setString(ApiConfig.quotaDateKey, today);
        return {
          'used': 0,
          'limit': ApiConfig.dailyQuotaLimit,
          'remaining': ApiConfig.dailyQuotaLimit,
          'date': today,
        };
      }
      
      return {
        'used': quotaUsed,
        'limit': ApiConfig.dailyQuotaLimit,
        'remaining': (ApiConfig.dailyQuotaLimit - quotaUsed).clamp(0, ApiConfig.dailyQuotaLimit),
        'date': quotaDate,
      };
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error getting quota info: $e');
      return {
        'used': 0,
        'limit': ApiConfig.dailyQuotaLimit,
        'remaining': ApiConfig.dailyQuotaLimit,
        'date': DateTime.now().toIso8601String().split('T')[0],
      };
    }
  }

  /// Get error log for debugging
  Future<List<String>> getErrorLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(ApiConfig.errorLogKey) ?? [];
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error getting error log: $e');
      return [];
    }
  }

  /// Clear error log
  Future<void> clearErrorLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.errorLogKey);
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error clearing error log: $e');
    }
  }
}