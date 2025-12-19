// lib/data/services/vertex_ai_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

/// Vertex AI Service
///
/// Handles all communication with Google Cloud Vertex AI via secure proxy endpoint.
/// Uses backend proxy architecture with X-App-Secret authentication.
///
/// Architecture:
/// Flutter App → Gemini Public Proxy (Cloud Function) → Vertex AI API
///
/// Configuration:
/// - Endpoint: https://gemini-public-proxy-2fbg2toazq-uc.a.run.app
/// - Authentication: X-App-Secret header (OptimateFoodApp2025)
/// - Project: geminiopti
/// - Model: gemini-2.5-flash-lite
/// - Temperature: 0.0 (for maximum accuracy)
///
/// Request format (with image):
/// {"message": "your prompt", "image": "base64-encoded-image-data"}
///
/// Request format (text only):
/// {"message": "your prompt"}
///
/// Response format:
/// {"response": "```json\n{...}\n```"}
///
/// The raw text response is returned to api_service.dart which then uses
/// food_info_parser.dart to extract the JSON data from the markdown code blocks.
///
/// Key responsibilities:
/// - Image analysis via Gemini vision models (through proxy)
/// - Text generation via Gemini text models (through proxy)
/// - Error handling and retries
/// - Request/response formatting
class VertexAIService {
  // Singleton pattern
  static final VertexAIService _instance = VertexAIService._internal();
  factory VertexAIService() => _instance;
  VertexAIService._internal();

  /// Get Cloud Function URL from environment
  String get _cloudFunctionUrl {
    final url = dotenv.env['VERTEX_CLOUD_FUNCTION_URL'];

    if (url == null || url.isEmpty || url.contains('PASTE_YOUR_')) {
      throw Exception(
        'Cloud Function URL not configured. '
        'Please deploy the Cloud Function and add its URL to .env file.\n'
        'See: cloud_functions/vertex_ai_proxy/README.md'
      );
    }

    return url;
  }

  /// Get App Secret from environment
  String get _appSecret {
    final secret = dotenv.env['VERTEX_APP_SECRET'];

    if (secret == null || secret.isEmpty) {
      throw Exception(
        'App Secret not configured. '
        'Please add VERTEX_APP_SECRET to .env file.'
      );
    }

    return secret;
  }

  /// Analyze food image using Vertex AI Gemini Vision (via Cloud Function)
  ///
  /// [imageFile] - The image file to analyze
  /// [prompt] - The analysis prompt (e.g., food recognition instructions)
  /// [language] - The response language
  ///
  /// Returns a Map containing the parsed response with food information
  Future<Map<String, dynamic>> analyzeImage(
    File imageFile, {
    required String prompt,
    String language = 'English',
  }) async {
    try {
      // Log configuration details
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📡 Vertex AI Configuration:');
      debugPrint('   Project: geminiopti');
      debugPrint('   Region: us-central1 (Iowa, USA)');
      debugPrint('   Model: gemini-2.5-flash-lite');
      debugPrint('   Endpoint: $_cloudFunctionUrl');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Convert image to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Build request body with separate message and image fields
      // Backend expects: {"message": "prompt text", "image": "base64data"}
      final requestBody = {
        'message': prompt,
        'image': base64Image,
      };

      // Call Cloud Function with X-App-Secret header
      final response = await http.post(
        Uri.parse(_cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': _appSecret,
        },
        body: jsonEncode(requestBody),
      ).timeout(
        ApiConfig.imageAnalysisTimeout,
        onTimeout: () {
          throw Exception('Cloud Function request timed out after ${ApiConfig.imageAnalysisTimeout.inSeconds}s');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract token usage if available
        final usageMetadata = data['usageMetadata'];
        if (usageMetadata != null) {
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📊 Token Usage:');
          debugPrint('   Input tokens: ${usageMetadata['promptTokenCount'] ?? 'N/A'}');
          debugPrint('   Output tokens: ${usageMetadata['candidatesTokenCount'] ?? 'N/A'}');
          debugPrint('   Total tokens: ${usageMetadata['totalTokenCount'] ?? 'N/A'}');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        }

        // Extract the raw text response for the parser
        final rawText = data['response'] as String?;
        if (rawText == null || rawText.isEmpty) {
          throw Exception('No response text from API');
        }

        // Return the raw text so food_info_parser can extract the JSON
        return {
          'text': rawText,
          '_metadata': {
            'provider': 'vertex-ai-proxy',
            'model': 'gemini-2.5-flash-lite',
            'project': 'geminiopti',
            'region': 'us-central1',
            'timestamp': DateTime.now().toIso8601String(),
            'tokens': usageMetadata,
          }
        };
      } else {
        throw Exception(
          'Cloud Function error (${response.statusCode}): ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Failed to analyze image via Cloud Function: $e');
    }
  }

  /// Get food information using text-only Vertex AI request (via Cloud Function)
  ///
  /// [foodName] - The name of the food to look up
  /// [language] - The response language
  ///
  /// Returns a Map containing nutritional information
  Future<Map<String, dynamic>> getFoodInformation(
    String foodName, {
    String language = 'English',
  }) async {
    try {
      // Build prompt
      final prompt = '''
Provide detailed nutritional information for: $foodName

Return ONLY a JSON object with this exact structure (no markdown, no code blocks):
{
  "name": "food name in $language",
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "fiber": number,
  "servingSize": "typical serving size",
  "confidence": "high/medium/low"
}

Use standard USDA values for 100g serving.
''';

      // Build simplified request body
      final requestBody = {
        'message': prompt,
      };

      // Call Cloud Function with X-App-Secret header
      final response = await http.post(
        Uri.parse(_cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': _appSecret,
        },
        body: jsonEncode(requestBody),
      ).timeout(
        ApiConfig.textAnalysisTimeout,
        onTimeout: () {
          throw Exception('Cloud Function request timed out after ${ApiConfig.textAnalysisTimeout.inSeconds}s');
        },
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the raw text response for the parser
        final rawText = data['response'] as String?;
        if (rawText == null || rawText.isEmpty) {
          throw Exception('No response text from API');
        }

        // Return the raw text so food_info_parser can extract the JSON
        return {
          'text': rawText,
          '_metadata': {
            'provider': 'vertex-ai-proxy',
            'model': 'gemini-2.5-flash-lite',
            'timestamp': DateTime.now().toIso8601String(),
          }
        };
      } else {
        throw Exception(
          'Cloud Function error (${response.statusCode}): ${response.body}'
        );
      }
    } catch (e) {
      throw Exception('Failed to get food information via Cloud Function: $e');
    }
  }

  /// Test Cloud Function connection
  ///
  /// Useful for debugging and verifying setup
  /// Returns true if Cloud Function is accessible and responding
  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-App-Secret': _appSecret,
        },
        body: jsonEncode({
          'message': 'Say "Hello from Vertex AI"',
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      // Connection test failed - return false without logging in production
      return false;
    }
  }
}
