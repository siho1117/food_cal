// lib/data/services/qwen_api_adapter.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';
import '../../config/providers/qwen_config.dart';
import '../../config/ai_prompts.dart';

/// Adapter for Qwen API (OpenAI-compatible format)
/// Converts between the app's Gemini-style interface and Qwen's OpenAI format
class QwenApiAdapter {
  // Get API key from environment variables
  String get _apiKey {
    final key = dotenv.env[QwenConfig.apiKeyEnvVar];
    if (key == null || key.isEmpty) {
      debugPrint('WARNING: ${QwenConfig.apiKeyEnvVar} not found in .env file');
      return '';
    }
    return key;
  }

  /// Analyze food image using Qwen's OpenAI-compatible API
  /// [imageFile] - The image file to analyze
  /// [language] - Target language for food name (default: "English")
  Future<Map<String, dynamic>> analyzeImage(
    File imageFile, {
    String language = 'English',
  }) async {
    // Convert image to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    debugPrint('📤 Sending to Qwen API (${QwenConfig.visionModel}) with language: $language');

    // Combine prompts with language parameter
    final combinedPrompt = '${AiPrompts.foodImageSystemPrompt(language)}\n\n${AiPrompts.foodImageUserPrompt(language)}';

    // Create OpenAI-compatible request for Qwen
    final requestBody = {
      "model": QwenConfig.visionModel,
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": combinedPrompt
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:image/jpeg;base64,$base64Image"
              }
            }
          ]
        }
      ],
      "temperature": 0.1,
      "max_tokens": 1500,
    };

    // Send request to Qwen
    final uri = Uri.https(QwenConfig.baseUrl, QwenConfig.endpoint);

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(ApiConfig.imageAnalysisTimeout);

    if (response.statusCode != 200) {
      throw Exception(
          'Qwen API error: ${response.statusCode}, ${response.body}');
    }

    // Parse OpenAI-compatible response
    final responseData = jsonDecode(response.body);

    // Debug: Log full response
    if (kDebugMode) {
      debugPrint('🔍 Full Qwen Response: ${jsonEncode(responseData)}');

      // Extract and log token usage if available
      final usage = responseData['usage'];
      if (usage != null) {
        debugPrint('📊 Token Usage:');
        debugPrint('   Prompt tokens: ${usage['prompt_tokens']}');
        debugPrint('   Completion tokens: ${usage['completion_tokens']}');
        debugPrint('   Total tokens: ${usage['total_tokens']}');
      }
    }

    // Extract text from OpenAI-format response
    if (responseData['choices'] != null &&
        responseData['choices'].isNotEmpty &&
        responseData['choices'][0]['message'] != null &&
        responseData['choices'][0]['message']['content'] != null) {

      final textContent = responseData['choices'][0]['message']['content'];
      debugPrint('✅ Qwen response: $textContent');

      // Return in format expected by the rest of the app
      return {
        'text': textContent,
        'rawResponse': responseData,
        'provider': 'Qwen',
        'model': QwenConfig.visionModel,
      };
    }

    throw Exception('Invalid Qwen API response format');
  }

  /// Get food information by name using Qwen text model
  Future<Map<String, dynamic>> getFoodInformation(String foodName) async {
    debugPrint('📤 Sending food info request to Qwen: $foodName');

    // Create text-only request
    final requestBody = {
      "model": QwenConfig.textModel,
      "messages": [
        {
          "role": "system",
          "content": AiPrompts.foodInfoSystemPrompt
        },
        {
          "role": "user",
          "content": AiPrompts.foodInfoUserPrompt(foodName)
        }
      ],
      "temperature": 0.1,
      "max_tokens": 1000,
    };

    // Send request to Qwen
    final uri = Uri.https(QwenConfig.baseUrl, QwenConfig.endpoint);

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(ApiConfig.textAnalysisTimeout);

    if (response.statusCode != 200) {
      throw Exception(
          'Qwen API error: ${response.statusCode}, ${response.body}');
    }

    // Parse response
    final responseData = jsonDecode(response.body);

    if (responseData['choices'] != null &&
        responseData['choices'].isNotEmpty &&
        responseData['choices'][0]['message'] != null &&
        responseData['choices'][0]['message']['content'] != null) {

      final textContent = responseData['choices'][0]['message']['content'];
      debugPrint('✅ Qwen food info response: $textContent');

      return {
        'text': textContent,
        'rawResponse': responseData,
        'provider': 'Qwen',
      };
    }

    throw Exception('Invalid Qwen API response format');
  }
}
