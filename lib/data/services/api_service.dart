// lib/data/services/api_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'fallback_provider.dart'; // Import for fallback mechanism

/// Service to interact with OpenAI API for food recognition with fallback to Taiwan VM proxy
class FoodApiService {
  // Singleton instance
  static final FoodApiService _instance = FoodApiService._internal();
  factory FoodApiService() => _instance;
  FoodApiService._internal();

  // OpenAI configuration
  final String _openAIBaseUrl = 'api.openai.com';
  final String _openAIImagesEndpoint = '/v1/chat/completions';

  // OpenAI model names - updated per your requirement
  final String _visionModel = 'gpt-4.1-mini';
  final String _textModel = 'gpt-4.1-mini';

  // Keys for storage
  static const String _errorLogKey = 'api_error_log';
  static const String _quotaUsedKey = 'food_api_quota_used';
  static const String _quotaDateKey = 'food_api_quota_date';

  // Fallback provider
  final FallbackProvider _fallbackProvider = FallbackProvider();

  // Daily quota limit
  final int dailyQuotaLimit = 150;

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
          imageFile, _openAIApiKey, _visionModel);
    }
  }

  /// Analyze food image using OpenAI's API directly
  Future<Map<String, dynamic>> _analyzeWithOpenAI(File imageFile) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Create OpenAI API request body with improved prompt for concise food names
    final requestBody = {
      "model": _visionModel,
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
                "url": "data:image/jpeg;base64,$base64Image",
                "detail": "low"
              }
            }
          ]
        }
      ],
      "max_tokens": 300
    };

    // Send request to OpenAI
    final uri = Uri.https(_openAIBaseUrl, _openAIImagesEndpoint);
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

    // Extract food information from OpenAI response
    return _extractFoodInfoFromOpenAI(responseData);
  }

  /// Extract food information from OpenAI response and format for our app
  Map<String, dynamic> _extractFoodInfoFromOpenAI(Map<String, dynamic> responseData) {
    try {
      // Get the content from OpenAI response
      final choices = responseData['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw Exception('No choices in OpenAI response');
      }

      final content = choices[0]['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        throw Exception('No content in OpenAI response');
      }

      // ✅ FIXED: Replace print with debugPrint
      debugPrint('OpenAI Response Content: $content');

      // Try to extract JSON from the response
      String name = 'Unknown Food';
      double calories = 0.0;
      double protein = 0.0;
      double carbs = 0.0;
      double fat = 0.0;

      // Try to parse JSON first
      try {
        final jsonMatch = RegExp(r'\{[^}]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final jsonData = jsonDecode(jsonMatch.group(0)!);
          name = jsonData['name'] ?? 'Unknown Food';
          calories = _parseDoubleValue(jsonData['calories']) ?? 0.0;
          protein = _parseDoubleValue(jsonData['protein']) ?? 0.0;
          carbs = _parseDoubleValue(jsonData['carbs']) ?? 0.0;
          fat = _parseDoubleValue(jsonData['fat']) ?? 0.0;
        }
      } catch (e) {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('JSON parsing failed, using regex extraction: $e');
      }

      // If JSON parsing failed, use regex extraction
      if (name == 'Unknown Food') {
        // Extract food name - looking for "name" or "Food Name:" patterns
        final nameMatches = RegExp(r'(?:name|food)[:\s]+([^,\n]+)', caseSensitive: false)
            .firstMatch(content);
        if (nameMatches != null && nameMatches.groupCount >= 1) {
          name = nameMatches.group(1)!.trim();
        }

        // Extract calories - looking for "Calories:" followed by numbers
        final caloriesMatches =
            RegExp(r'(?:Calories|Cal)[:\s]+(\d+\.?\d*)', caseSensitive: false)
                .firstMatch(content);
        if (caloriesMatches != null && caloriesMatches.groupCount >= 1) {
          calories = double.tryParse(caloriesMatches.group(1)!) ?? 0.0;
        }

        // Extract protein - looking for "Protein:" followed by numbers
        final proteinMatches =
            RegExp(r'(?:Protein)[:\s]+(\d+\.?\d*)', caseSensitive: false)
                .firstMatch(content);
        if (proteinMatches != null && proteinMatches.groupCount >= 1) {
          protein = double.tryParse(proteinMatches.group(1)!) ?? 0.0;
        }

        // Extract carbs - looking for "Carbs:" or "Carbohydrates:" followed by numbers
        final carbsMatches = RegExp(r'(?:Carbs|Carbohydrates)[:\s]+(\d+\.?\d*)',
                caseSensitive: false)
            .firstMatch(content);
        if (carbsMatches != null && carbsMatches.groupCount >= 1) {
          carbs = double.tryParse(carbsMatches.group(1)!) ?? 0.0;
        }

        // Extract fat - looking for "Fat:" followed by numbers
        final fatMatches =
            RegExp(r'(?:Fat)[:\s]+(\d+\.?\d*)', caseSensitive: false)
                .firstMatch(content);
        if (fatMatches != null && fatMatches.groupCount >= 1) {
          fat = double.tryParse(fatMatches.group(1)!) ?? 0.0;
        }
      }

      // Check if the food was unidentified or unknown
      if (name.toLowerCase().contains('unidentified') ||
          name.toLowerCase().contains('unknown') ||
          name.toLowerCase().contains('not food')) {
        name = 'Unidentified Food Item';
      }

      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Extracted values: name=$name, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');

      // Format the response for our app
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
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error extracting food info from OpenAI response: $e');
      // Return an undefined food item response if parsing fails
      return _getUndefinedFoodResponse();
    }
  }

  /// Get an undefined food item response
  Map<String, dynamic> _getUndefinedFoodResponse() {
    return {
      'category': {'name': 'Unidentified Food Item'},
      'nutrition': {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
        'nutrients': [
          {'name': 'Protein', 'amount': 0.0, 'unit': 'g'},
          {'name': 'Carbohydrates', 'amount': 0.0, 'unit': 'g'},
          {'name': 'Fat', 'amount': 0.0, 'unit': 'g'},
        ]
      }
    };
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
          name, _openAIApiKey, _textModel);
    }
  }

  /// Get food information from OpenAI
  Future<Map<String, dynamic>> _getFoodInfoFromOpenAI(String name) async {
    // Create OpenAI API request body with improved structured format
    final requestBody = {
      "model": _textModel,
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
    final uri = Uri.https(_openAIBaseUrl, _openAIImagesEndpoint);
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

    // Extract food information from OpenAI response
    return _extractFoodInfoFromOpenAI(responseData);
  }

  /// Search for foods by name
  Future<List<dynamic>> searchFoods(String query) async {
    // Check if we've exceeded our daily quota
    if (await isDailyQuotaExceeded()) {
      throw Exception('Daily API quota exceeded. Please try again tomorrow.');
    }

    try {
      // Try OpenAI first
      return await _searchFoodsWithOpenAI(query);
    } catch (e) {
      // Log the error for analytics
      await _logError('OpenAI Search', e.toString());
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('OpenAI search error: $e');

      // Increment quota usage
      await incrementQuotaUsage();

      // Use fallback or return empty list
      return [];
    }
  }

  /// Search for foods using OpenAI
  Future<List<dynamic>> _searchFoodsWithOpenAI(String query) async {
    // Create OpenAI API request body for food search
    final requestBody = {
      "model": _textModel,
      "messages": [
        {
          "role": "system",
          "content":
              "You are a food search system. Find foods matching the user's query and return nutritional information in JSON array format."
        },
        {
          "role": "user",
          "content":
              "Find foods matching '$query'. Return results as a JSON array with this format: [{\"name\": \"food_name\", \"calories\": number, \"protein\": number, \"carbs\": number, \"fat\": number}]. Limit to 5 results."
        }
      ],
      "max_tokens": 500
    };

    // Send request to OpenAI
    final uri = Uri.https(_openAIBaseUrl, _openAIImagesEndpoint);
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
    
    // Increment quota usage for successful requests
    await incrementQuotaUsage();

    // Extract search results from OpenAI response
    return _extractSearchResultsFromOpenAI(responseData);
  }

  /// Extract search results from OpenAI response
  List<dynamic> _extractSearchResultsFromOpenAI(Map<String, dynamic> responseData) {
    try {
      // Get the content from OpenAI response
      final choices = responseData['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        return [];
      }

      final content = choices[0]['message']['content'] as String?;
      if (content == null || content.isEmpty) {
        return [];
      }

      // ✅ FIXED: Replace print with debugPrint
      debugPrint('OpenAI Search Response Content: $content');

      // Try to parse JSON array from the response
      final jsonMatches = RegExp(r'\[\s*\{.*?\}\s*\]', dotAll: true).firstMatch(content);

      if (jsonMatches != null) {
        // Try to parse the JSON array
        final jsonString = jsonMatches.group(0)!;
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('Found JSON array: $jsonString');

        final items = jsonDecode(jsonString) as List;
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('Successfully parsed ${items.length} items');

        // Format each item
        return items.map((item) {
          // Ensure we have all required fields
          final name = item['name'] ?? 'Unknown Food';
          final calories = _parseDoubleValue(item['calories']) ?? 0.0;
          final protein = _parseDoubleValue(item['protein']) ?? 0.0;
          final carbs = _parseDoubleValue(item['carbs']) ?? 0.0;
          final fat = _parseDoubleValue(item['fat']) ?? 0.0;

          // ✅ FIXED: Replace print with debugPrint
          debugPrint('Formatted item: $name, cal=$calories, p=$protein, c=$carbs, f=$fat');

          return {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': name,
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
        }).toList();
      } else {
        // If JSON parsing fails, search for possible structured content
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('No valid JSON found, attempting to extract structured data');

        final items = <Map<String, dynamic>>[];

        // Match individual food entry blocks
        final foodBlocks = RegExp(
                r'(?:Food|Name)[:\s]+([^\n]+)(?:\s*Calories?[:\s]+(\d+\.?\d*)(?:\s*cal)?)?(?:\s*Protein[:\s]+(\d+\.?\d*)(?:\s*g)?)?(?:\s*Carb(?:s|ohydrates)?[:\s]+(\d+\.?\d*)(?:\s*g)?)?(?:\s*Fat[:\s]+(\d+\.?\d*)(?:\s*g)?)?',
                caseSensitive: false)
            .allMatches(content);

        for (final match in foodBlocks) {
          if (match.groupCount >= 1) {
            final name = match.group(1)?.trim() ?? 'Unknown Food';
            final calories = _parseDoubleValue(match.group(2)) ?? 0.0;
            final protein = _parseDoubleValue(match.group(3)) ?? 0.0;
            final carbs = _parseDoubleValue(match.group(4)) ?? 0.0;
            final fat = _parseDoubleValue(match.group(5)) ?? 0.0;

            items.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': name,
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
            });
          }
        }

        if (items.isNotEmpty) {
          // ✅ FIXED: Replace print with debugPrint
          debugPrint('Extracted ${items.length} items using regex');
          return items;
        }

        // If no items found, return empty list
        return [];
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error extracting food items from response: $e');
      // Return empty list on error
      return [];
    }
  }

  /// Parse a numeric value from various formats
  double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove any non-numeric characters except decimal points
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  /// Log error for analytics (minimal data usage)
  Future<void> _logError(String service, String errorMessage) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing error log
      final errorLog = prefs.getStringList(_errorLogKey) ?? [];

      // Add new error with timestamp
      final errorEntry = '${DateTime.now().toIso8601String()}: $service - $errorMessage';
      errorLog.add(errorEntry);

      // Keep only last 10 errors to avoid excessive storage
      if (errorLog.length > 10) {
        errorLog.removeRange(0, errorLog.length - 10);
      }

      await prefs.setStringList(_errorLogKey, errorLog);
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error logging API error: $e');
    }
  }

  /// Check if daily quota has been exceeded
  Future<bool> isDailyQuotaExceeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final quotaUsed = prefs.getInt(_quotaUsedKey) ?? 0;
      final quotaDate = prefs.getString(_quotaDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Reset quota if it's a new day
      if (quotaDate != today) {
        await prefs.setInt(_quotaUsedKey, 0);
        await prefs.setString(_quotaDateKey, today);
        return false;
      }
      
      return quotaUsed >= dailyQuotaLimit;
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
      
      final quotaUsed = prefs.getInt(_quotaUsedKey) ?? 0;
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      await prefs.setInt(_quotaUsedKey, quotaUsed + 1);
      await prefs.setString(_quotaDateKey, today);
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('API quota used: ${quotaUsed + 1}/$dailyQuotaLimit');
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error incrementing quota: $e');
    }
  }

  /// Get current quota usage for display
  Future<Map<String, dynamic>> getQuotaInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final quotaUsed = prefs.getInt(_quotaUsedKey) ?? 0;
      final quotaDate = prefs.getString(_quotaDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Reset quota if it's a new day
      if (quotaDate != today) {
        await prefs.setInt(_quotaUsedKey, 0);
        await prefs.setString(_quotaDateKey, today);
        return {
          'used': 0,
          'limit': dailyQuotaLimit,
          'remaining': dailyQuotaLimit,
          'date': today,
        };
      }
      
      return {
        'used': quotaUsed,
        'limit': dailyQuotaLimit,
        'remaining': (dailyQuotaLimit - quotaUsed).clamp(0, dailyQuotaLimit),
        'date': quotaDate,
      };
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error getting quota info: $e');
      return {
        'used': 0,
        'limit': dailyQuotaLimit,
        'remaining': dailyQuotaLimit,
        'date': DateTime.now().toIso8601String().split('T')[0],
      };
    }
  }

  /// Get error log for debugging
  Future<List<String>> getErrorLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_errorLogKey) ?? [];
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
      await prefs.remove(_errorLogKey);
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error clearing error log: $e');
    }
  }
}