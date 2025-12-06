// lib/data/services/api_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'fallback_provider.dart'; // Import for fallback mechanism
import 'food_info_parser.dart'; // Import for parsing food information
import '../../config/api_config.dart'; // Import for centralized API configuration
import '../../config/ai_prompts.dart'; // Import for centralized AI prompts

/// Service to interact with Vision AI (Gemini/OpenAI) for food recognition with fallback to Taiwan VM proxy
class FoodApiService {
  // Singleton instance
  static final FoodApiService _instance = FoodApiService._internal();
  factory FoodApiService() => _instance;
  FoodApiService._internal();

  // Fallback provider
  final FallbackProvider _fallbackProvider = FallbackProvider();

  // Food info parser
  final FoodInfoParser _parser = FoodInfoParser();

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
  /// Returns a Map containing the API response
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    // Check if we've exceeded our daily quota
    if (await isDailyQuotaExceeded()) {
      throw Exception('Daily API quota exceeded. Please try again tomorrow.');
    }

    try {
      // Try Gemini first
      return await _analyzeWithGemini(imageFile);
    } catch (e) {
      // Log the error for analytics
      await _logError('Gemini', e.toString());
      debugPrint('Gemini direct access error, trying fallback provider: $e');

      // Increment quota usage
      await incrementQuotaUsage();

      // Use fallback provider (Taiwan VM proxy)
      return await _fallbackProvider.analyzeImage(
          imageFile, _geminiApiKey, ApiConfig.visionModel);
    }
  }

  /// Analyze food image using Gemini's API directly
  Future<Map<String, dynamic>> _analyzeWithGemini(File imageFile) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // MIME type: PhotoCompressionService always outputs JPEG
    const String mimeType = 'image/jpeg';

    debugPrint('📤 Sending to Gemini API with MIME type: $mimeType');

    // Combine system and user prompts for Gemini
    final combinedPrompt = '${AiPrompts.foodImageSystemPrompt}\n\n${AiPrompts.foodImageUserPrompt}';

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

    // Increment quota usage for successful requests
    await incrementQuotaUsage();

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
      // Try Gemini first
      return await _getFoodInfoFromGemini(name);
    } catch (e) {
      // Log the error for analytics
      await _logError('Gemini', e.toString());
      debugPrint('Gemini error, using fallback provider: $e');

      // Increment quota usage
      await incrementQuotaUsage();

      // Use fallback provider
      return await _fallbackProvider.getFoodInformation(
          name, _geminiApiKey, ApiConfig.textModel);
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

    // Increment quota usage for successful requests
    await incrementQuotaUsage();

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