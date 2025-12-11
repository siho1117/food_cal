// lib/data/services/api_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'food_info_parser.dart'; // Import for parsing food information
import 'qwen_api_adapter.dart'; // Import for Qwen API adapter
import '../../config/api_config.dart'; // Import for centralized API configuration
import '../../config/ai_prompts.dart'; // Import for centralized AI prompts
import '../../utils/nutrition_scaler.dart'; // Import for nutrition value scaling

/// Service to interact with Vision AI (Gemini/Qwen) for food recognition
/// Uses Gemini as primary provider with Qwen as automatic fallback
class FoodApiService {
  // Singleton instance
  static final FoodApiService _instance = FoodApiService._internal();
  factory FoodApiService() => _instance;
  FoodApiService._internal();

  // Food info parser
  final FoodInfoParser _parser = FoodInfoParser();

  // Qwen API adapter (for fallback)
  final QwenApiAdapter _qwenAdapter = QwenApiAdapter();

  // Get API key from environment variables (provider-agnostic)
  String get _geminiApiKey {
    final key = dotenv.env[ApiConfig.apiKeyEnvVar];
    if (key == null || key.isEmpty) {
      debugPrint('WARNING: ${ApiConfig.apiKeyEnvVar} not found in .env file');
      return '';
    }
    return key;
  }

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
      // PRIMARY: Try Gemini first
      debugPrint('🔷 Trying Gemini API (primary)...');
      final result = await _analyzeWithGemini(imageFile, language: language);

      // Increment quota usage for successful requests
      await incrementQuotaUsage();

      // Scale nutrition values before returning
      return NutritionScaler.scale(result);
    } catch (geminiError) {
      // Log Gemini error
      await _logError('Gemini', geminiError.toString());
      debugPrint('⚠️ Gemini failed, trying Qwen backup: $geminiError');

      try {
        // BACKUP: Try Qwen
        debugPrint('🟡 Trying Qwen API (backup)...');
        final qwenResult = await _qwenAdapter.analyzeImage(imageFile, language: language);

        // Increment quota usage for successful requests
        await incrementQuotaUsage();

        // Parse and scale the result
        final parsed = _parser.extractFromText(qwenResult['text']);
        return NutritionScaler.scale(parsed);
      } catch (qwenError) {
        // Log Qwen error
        await _logError('Qwen', qwenError.toString());
        debugPrint('❌ Both Gemini and Qwen failed');

        // Increment quota usage
        await incrementQuotaUsage();

        // Both providers failed
        throw Exception('All API providers failed. Gemini: $geminiError, Qwen: $qwenError');
      }
    }
  }

  /// Analyze food image using Gemini's API directly
  Future<Map<String, dynamic>> _analyzeWithGemini(
    File imageFile, {
    String language = 'English',
  }) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // MIME type: PhotoCompressionService always outputs JPEG
    const String mimeType = 'image/jpeg';

    debugPrint('📤 Sending to Gemini API with MIME type: $mimeType, language: $language');

    // Combine system and user prompts for Gemini with language parameter
    final combinedPrompt = '${AiPrompts.foodImageSystemPrompt(language)}\n\n${AiPrompts.foodImageUserPrompt(language)}';

    // Create Gemini API request body
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": combinedPrompt
            },
            {
              "inline_data": {
                "mime_type": mimeType,
                "data": base64Image
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.1,
        "maxOutputTokens": 1500,
      }
    };

    // Send request to Gemini
    final uri = Uri.https(
      ApiConfig.geminiBaseUrl,
      '${ApiConfig.geminiEndpoint}${ApiConfig.visionModel}:generateContent',
      {'key': _geminiApiKey}
    );

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error: ${response.statusCode}, ${response.body}');
    }

    // Parse Gemini response
    final responseData = jsonDecode(response.body);

    // Debug: Log full response (debug builds only)
    if (kDebugMode) {
      debugPrint('🔍 Full Gemini Response: ${jsonEncode(responseData)}');

      // Extract and log token usage details if available
      final usageMetadata = responseData['usageMetadata'];
      if (usageMetadata != null) {
        debugPrint('📊 Token Usage Breakdown:');
        debugPrint('   Prompt tokens: ${usageMetadata['promptTokenCount']}');
        debugPrint('   Completion tokens: ${usageMetadata['candidatesTokenCount']}');
        debugPrint('   Total tokens: ${usageMetadata['totalTokenCount']}');
      }
    }

    // Extract text from Gemini response
    if (responseData['candidates'] != null &&
        responseData['candidates'].isNotEmpty &&
        responseData['candidates'][0]['content'] != null &&
        responseData['candidates'][0]['content']['parts'] != null &&
        responseData['candidates'][0]['content']['parts'].isNotEmpty) {

      final textContent = responseData['candidates'][0]['content']['parts'][0]['text'];
      debugPrint('Gemini text response: $textContent');

      // Parse the text response using the parser
      return _parser.extractFromText(textContent);
    }

    throw Exception('Invalid Gemini response format');
  }


  /// Get detailed information about a specific food ingredient by name
  Future<Map<String, dynamic>> getFoodInformation(String name) async {
    // Check if we've exceeded our daily quota
    if (await isDailyQuotaExceeded()) {
      throw Exception('Daily API quota exceeded. Please try again tomorrow.');
    }

    try {
      // PRIMARY: Try Gemini first
      debugPrint('🔷 Getting food info from Gemini (primary)...');
      final result = await _getFoodInfoFromGemini(name);

      // Increment quota usage for successful requests
      await incrementQuotaUsage();

      // Scale nutrition values before returning
      return NutritionScaler.scale(result);
    } catch (geminiError) {
      // Log Gemini error
      await _logError('Gemini', geminiError.toString());
      debugPrint('⚠️ Gemini failed, trying Qwen backup: $geminiError');

      try {
        // BACKUP: Try Qwen
        debugPrint('🟡 Getting food info from Qwen (backup)...');
        final qwenResult = await _qwenAdapter.getFoodInformation(name);

        // Increment quota usage
        await incrementQuotaUsage();

        // Parse and scale the result
        final parsed = _parser.extractFromText(qwenResult['text']);
        return NutritionScaler.scale(parsed);
      } catch (qwenError) {
        // Log Qwen error
        await _logError('Qwen', qwenError.toString());
        debugPrint('❌ Both Gemini and Qwen failed for food info');

        // Increment quota usage
        await incrementQuotaUsage();

        // Both providers failed
        throw Exception('All API providers failed. Gemini: $geminiError, Qwen: $qwenError');
      }
    }
  }

  /// Get food information from Gemini
  Future<Map<String, dynamic>> _getFoodInfoFromGemini(String name) async {
    debugPrint('Getting food information for: $name');

    // Combine system and user prompts for Gemini
    final combinedPrompt = '${AiPrompts.foodInfoSystemPrompt}\n\n${AiPrompts.foodInfoUserPrompt(name)}';

    // Create Gemini API request body
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": combinedPrompt
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.1,
        "maxOutputTokens": 1200,
      }
    };

    // Send request to Gemini
    final uri = Uri.https(
      ApiConfig.geminiBaseUrl,
      '${ApiConfig.geminiEndpoint}${ApiConfig.textModel}:generateContent',
      {'key': _geminiApiKey}
    );

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error: ${response.statusCode}, ${response.body}');
    }

    // Parse Gemini response
    final responseData = jsonDecode(response.body);
    debugPrint('Gemini Response: $responseData');

    // Extract text from Gemini response
    if (responseData['candidates'] != null &&
        responseData['candidates'].isNotEmpty &&
        responseData['candidates'][0]['content'] != null &&
        responseData['candidates'][0]['content']['parts'] != null &&
        responseData['candidates'][0]['content']['parts'].isNotEmpty) {

      final textContent = responseData['candidates'][0]['content']['parts'][0]['text'];
      debugPrint('Gemini text response: $textContent');

      // Parse the text response using the parser
      return _parser.extractFromText(textContent);
    }

    throw Exception('Invalid Gemini response format');
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