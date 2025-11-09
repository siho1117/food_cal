// lib/data/services/fallback_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'food_info_parser.dart'; // Import for parsing food information
import '../../config/api_config.dart'; // Import for centralized API configuration

/// Provider to handle VM proxy for OpenAI API access
class FallbackProvider {
  // Food info parser
  final FoodInfoParser _parser = FoodInfoParser();

  /// Simple test function to check VM and OpenAI connectivity
  Future<Map<String, dynamic>> testConnection() async {
    try {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Testing connection to VM proxy...');
      
      // Generate a unique request ID for tracking
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create proper request body based on our testing
      final requestBody = json.encode({
        "foodName": "apple",
        "requestId": requestId,
      });
      
      // Send request to VM proxy using proper headers
      final uri = Uri(
        scheme: 'http',
        host: ApiConfig.vmProxyUrl,
        port: ApiConfig.vmProxyPort,
        path: ApiConfig.vmProxyEndpoint,
      );
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Sending request to: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-info', // Correct request type
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('Connection successful!');
        debugPrint('Response: ${response.body}');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('HTTP Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error in test connection: $e');
      throw Exception('Connection test failed: $e');
    }
  }

  /// Analyze a food image using VM proxy
  Future<Map<String, dynamic>> analyzeImage(File imageFile, String apiKey, String modelName) async {
    try {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('====== FOOD IMAGE ANALYSIS DEBUG ======');
      debugPrint('Starting image analysis via VM proxy...');
      debugPrint('Image file exists: ${imageFile.existsSync()}');
      debugPrint('Image file path: ${imageFile.path}');
      debugPrint('Image file size: ${await imageFile.length()} bytes');
      
      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Image bytes read: ${imageBytes.length} bytes');
      
      String base64Image = base64Encode(imageBytes);
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Base64 image length: ${base64Image.length}');
      
      // Generate request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create request body
      final requestBody = json.encode({
        "imageData": base64Image,
        "requestId": requestId,
        "modelName": modelName, // Pass the model name to the VM
      });
      
      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: ApiConfig.vmProxyUrl,
        port: ApiConfig.vmProxyPort,
        path: ApiConfig.vmProxyEndpoint,
      );
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Sending request to: $uri');
      debugPrint('Request ID: $requestId');
      debugPrint('Model name: $modelName');
      debugPrint('Request length: ${requestBody.length} bytes');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'image-analysis',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 60)); // Extended timeout
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Response received with status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('Response body length: ${response.body.length}');
        if (response.body.isNotEmpty) {
          try {
            // First try to parse as JSON
            final jsonData = json.decode(response.body);
            // ✅ FIXED: Replace print with debugPrint
            debugPrint('Successfully parsed response as JSON');
            
            // Check for OpenAI API style response with choices
            if (jsonData is Map<String, dynamic>) {
              // ✅ FIXED: Replace print with debugPrint
              debugPrint('Response keys: ${jsonData.keys.join(', ')}');
              
              // If the response already has the structure we need, return it directly
              if (jsonData.containsKey('category') && jsonData.containsKey('nutrition')) {
                // ✅ FIXED: Replace print with debugPrint
                debugPrint('Response already in correct format');
                return jsonData;
              }
              
              // If it's an OpenAI API response with choices
              if (jsonData.containsKey('choices') && jsonData['choices'] is List && jsonData['choices'].isNotEmpty) {
                final content = jsonData['choices'][0]['message']['content'] as String? ?? '';
                // ✅ FIXED: Replace print with debugPrint
                debugPrint('Extracted content from choices: ${content.substring(0, min(50, content.length))}...');

                return _parser.extractFromText(content);
              }
              
              // If it has 'error' field, throw exception with error message
              if (jsonData.containsKey('error')) {
                final errorMsg = jsonData['error'] is String 
                    ? jsonData['error'] 
                    : jsonData['error'] is Map 
                        ? jsonData['error']['message'] ?? 'Unknown error'
                        : 'Unknown error format';
                throw Exception('VM proxy returned error: $errorMsg');
              }
              
              // If it has other structure, try to extract from raw response
              // ✅ FIXED: Replace print with debugPrint
              debugPrint('Unexpected response structure, attempting to extract from raw content');
              // ✅ FIXED: Replace print with debugPrint
              debugPrint('Raw response: $jsonData');

              return _parser.extractFromText(response.body);
            }
          } catch (e) {
            // ✅ FIXED: Replace print with debugPrint
            debugPrint('JSON parsing failed: $e');
            // ✅ FIXED: Replace print with debugPrint
            debugPrint('Attempting to extract from raw text');

            return _parser.extractFromText(response.body);
          }
        }

        // Default response if nothing else works
        return _parser.getUndefinedFoodResponse();
      } else {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('HTTP Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error in image analysis: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Get detailed information about a specific food ingredient by name
  Future<Map<String, dynamic>> getFoodInformation(String name, String apiKey, String modelName) async {
    try {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Getting food information via VM proxy: $name');

      // Generate request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create request body for the VM proxy
      final requestBody = json.encode({
        "foodName": name,
        "requestId": requestId,
        "modelName": modelName, // Pass the model name to the VM
      });

      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: ApiConfig.vmProxyUrl,
        port: ApiConfig.vmProxyPort,
        path: ApiConfig.vmProxyEndpoint,
      );
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Sending food info request to: $uri');
      debugPrint('Food name: $name');
      debugPrint('Using model: $modelName');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-info',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Response received with status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          
          // If the response already has the structure we need, return it directly
          if (jsonData is Map<String, dynamic> && 
              jsonData.containsKey('category') && 
              jsonData.containsKey('nutrition')) {
            return jsonData;
          }
          
          // If it's an OpenAI API response with choices
          if (jsonData is Map<String, dynamic> &&
              jsonData.containsKey('choices') &&
              jsonData['choices'] is List &&
              jsonData['choices'].isNotEmpty) {

            final content = jsonData['choices'][0]['message']['content'] as String? ?? '';
            return _parser.extractFromText(content);
          }

          // Try to extract from raw response
          return _parser.extractFromText(response.body);
        } catch (e) {
          // ✅ FIXED: Replace print with debugPrint
          debugPrint('Error parsing JSON: $e');
          return _parser.extractFromText(response.body);
        }
      } else {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('HTTP Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error getting food information: $e');
      throw Exception('Failed to get food information: $e');
    }
  }

  // Helper function to get minimum of two integers
  int min(int a, int b) => a < b ? a : b;
}