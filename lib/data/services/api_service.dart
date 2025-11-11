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

/// Service to interact with OpenAI API for food recognition with fallback to Taiwan VM proxy
class FoodApiService {
  // Singleton instance
  static final FoodApiService _instance = FoodApiService._internal();
  factory FoodApiService() => _instance;
  FoodApiService._internal();

  // Fallback provider
  final FallbackProvider _fallbackProvider = FallbackProvider();

  // Food info parser
  final FoodInfoParser _parser = FoodInfoParser();

  // Get OpenAI API key from environment variables
  String get _openAIApiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('WARNING: OPENAI_API_KEY not found in .env file');
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
      // Try OpenAI first
      return await _analyzeWithOpenAI(imageFile);
    } catch (e) {
      // Log the error for analytics
      await _logError('OpenAI', e.toString());
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('OpenAI direct access error, trying fallback provider: $e');

      // Increment quota usage
      await incrementQuotaUsage();

      // Use fallback provider (Taiwan VM proxy)
      return await _fallbackProvider.analyzeImage(
          imageFile, _openAIApiKey, ApiConfig.visionModel);
    }
  }

  /// Analyze food image using OpenAI's API directly
  Future<Map<String, dynamic>> _analyzeWithOpenAI(File imageFile) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Detect image format from file extension for proper MIME type
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    final String mimeType;
    if (fileExtension == 'webp') {
      mimeType = 'image/webp';
    } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (fileExtension == 'png') {
      mimeType = 'image/png';
    } else {
      // Default to JPEG for unknown formats
      mimeType = 'image/jpeg';
    }

    debugPrint('📤 Sending to OpenAI API with MIME type: $mimeType');

    // Create OpenAI API request body with improved prompt for concise food names
    final requestBody = {
      "model": ApiConfig.visionModel,
      "messages": [
        {
          "role": "system",
          "content":
              "You are a food recognition system. Identify food items in images and provide nutritional information. Respond with JSON format containing food name, calories, protein, carbs, and fat per serving."
        },
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "Identify the food item in this image and provide nutritional information per serving in this exact JSON format: {\"name\": \"food_name\", \"calories\": number, \"protein\": number, \"carbs\": number, \"fat\": number}"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:$mimeType;base64,$base64Image",
                "detail": "low"
              }
            }
          ]
        }
      ],
      "max_tokens": 300
    };

    // Send request to OpenAI
    final uri = Uri.https(ApiConfig.openAIBaseUrl, ApiConfig.openAIImagesEndpoint);
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_openAIApiKey',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
          'OpenAI API error: ${response.statusCode}, ${response.body}');
    }

    // Parse OpenAI response
    final responseData = jsonDecode(response.body);

    // Increment quota usage for successful requests
    await incrementQuotaUsage();

    // Extract food information from OpenAI response using parser
    return _parser.extractFromOpenAIResponse(responseData);
  }


  /// Get detailed information about a specific food ingredient by name
  Future<Map<String, dynamic>> getFoodInformation(String name) async {
    // Check if we've exceeded our daily quota
    if (await isDailyQuotaExceeded()) {
      throw Exception('Daily API quota exceeded. Please try again tomorrow.');
    }

    try {
      // Try OpenAI first
      return await _getFoodInfoFromOpenAI(name);
    } catch (e) {
      // Log the error for analytics
      await _logError('OpenAI', e.toString());
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('OpenAI error, using fallback provider: $e');

      // Increment quota usage
      await incrementQuotaUsage();

      // Use fallback provider
      return await _fallbackProvider.getFoodInformation(
          name, _openAIApiKey, ApiConfig.textModel);
    }
  }

  /// Get food information from OpenAI
  Future<Map<String, dynamic>> _getFoodInfoFromOpenAI(String name) async {
    // Create OpenAI API request body with improved structured format
    final requestBody = {
      "model": ApiConfig.textModel,
      "messages": [
        {
          "role": "system",
          "content":
              "You are a nutritional information system. Provide detailed nutritional facts for food items in a structured format."
        },
        {
          "role": "user",
          "content":
              "Provide nutritional information for $name. Reply in this exact format:\nFood Name: $name\nCalories: [number] cal\nProtein: [number] g\nCarbs: [number] g\nFat: [number] g"
        }
      ],
      "max_tokens": 300
    };

    // Send request to OpenAI
    final uri = Uri.https(ApiConfig.openAIBaseUrl, ApiConfig.openAIImagesEndpoint);
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_openAIApiKey',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
          'OpenAI API error: ${response.statusCode}, ${response.body}');
    }

    // Parse OpenAI response
    final responseData = jsonDecode(response.body);
    // ✅ FIXED: Replace print with debugPrint
    debugPrint('OpenAI Response: $responseData');

    // Increment quota usage for successful requests
    await incrementQuotaUsage();

    // Extract food information from OpenAI response using parser
    return _parser.extractFromOpenAIResponse(responseData);
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