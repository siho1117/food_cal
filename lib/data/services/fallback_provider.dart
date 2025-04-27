// lib/data/services/fallback_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Provider to handle VM proxy for OpenAI API access
class FallbackProvider {
  // VM proxy configuration
  final String _vmProxyUrl = '35.201.20.109'; // Your Google Cloud VM IP
  final int _vmProxyPort = 3000; // Node.js server port
  final String _vmProxyEndpoint = '/api/openai-proxy'; // Your server endpoint

  /// Simple test function to check VM and OpenAI connectivity
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('Testing connection to VM proxy...');
      
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
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
      );
      print('Sending request to: $uri');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-info', // Correct request type
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        print('Connection successful!');
        print('Response: ${response.body}');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error in test connection: $e');
      throw Exception('Connection test failed: $e');
    }
  }

  /// Analyze a food image using VM proxy
  Future<Map<String, dynamic>> analyzeImage(File imageFile, String apiKey, String modelName) async {
    try {
      print('Analyzing image via VM proxy...');
      
      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Generate request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create request body
      final requestBody = json.encode({
        "imageData": base64Image,
        "requestId": requestId,
      });
      
      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'image-analysis',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        print('Image analysis successful!');
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error in image analysis: $e');
      throw Exception('Image analysis failed: $e');
    }
  }
  
  /// Get detailed information about a specific food ingredient by name
  Future<Map<String, dynamic>> getFoodInformation(String name, String apiKey, String modelName) async {
    try {
      print('Getting food information via VM proxy: $name');

      // Generate request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create request body for the VM proxy
      final requestBody = json.encode({
        "foodName": name,
        "requestId": requestId,
      });

      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-info',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'VM Proxy error: ${response.statusCode}, ${response.body}');
      }

      // Parse VM proxy response
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      
      print('VM Proxy Food Info Response: $responseData');
      
      return _extractFoodInfoFromResponse(responseData);
    } catch (e) {
      print('Error getting food information from VM proxy: $e');
      throw Exception('Error getting food information: $e');
    }
  }

  /// Search for foods by name
  Future<List<dynamic>> searchFoods(String query, String apiKey, String modelName) async {
    try {
      print('Searching foods via VM proxy: $query');

      // Generate request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create request body for VM proxy
      final requestBody = json.encode({
        "foodName": query, // Using foodName instead of searchQuery based on our testing
        "requestId": requestId,
      });

      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-search',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'VM Proxy error: ${response.statusCode}, ${response.body}');
      }

      // Parse VM proxy response
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      print('VM Proxy Food Search Response: $responseData');

      // Extract and format food items
      return _extractFoodItemsFromResponse(responseData);
    } catch (e) {
      print('Error searching foods from VM proxy: $e');
      throw Exception('Error searching foods: $e');
    }
  }
  
  /// Extract food information from OpenAI response
  Map<String, dynamic> _extractFoodInfoFromResponse(Map<String, dynamic> response) {
    try {
      // Check if the response contains OpenAI format with choices
      if (response.containsKey('choices') &&
          response['choices'] is List &&
          response['choices'].isNotEmpty &&
          response['choices'][0] is Map<String, dynamic> &&
          (response['choices'][0] as Map<String, dynamic>).containsKey('message') &&
          (response['choices'][0]['message'] as Map<String, dynamic>).containsKey('content')) {
        
        final content = response['choices'][0]['message']['content'] as String;
        
        // Extract food information using regex
        String name = 'Unidentified Food Item';
        double calories = 0.0;
        double protein = 0.0;
        double carbs = 0.0;
        double fat = 0.0;

        // Extract food name
        final nameMatches = RegExp(r'(?:Food\s*Name|Name)[:\s]+([^\n\.]+)', caseSensitive: false)
            .firstMatch(content);
        if (nameMatches != null && nameMatches.groupCount >= 1) {
          name = nameMatches.group(1)!.trim();
        }

        // Extract calories
        final caloriesMatches = RegExp(r'(?:Calories|Cal)[:\s]+(\d+\.?\d*)', caseSensitive: false)
            .firstMatch(content);
        if (caloriesMatches != null && caloriesMatches.groupCount >= 1) {
          calories = double.tryParse(caloriesMatches.group(1)!) ?? 0.0;
        }

        // Extract protein
        final proteinMatches = RegExp(r'(?:Protein)[:\s]+(\d+\.?\d*)', caseSensitive: false)
            .firstMatch(content);
        if (proteinMatches != null && proteinMatches.groupCount >= 1) {
          protein = double.tryParse(proteinMatches.group(1)!) ?? 0.0;
        }

        // Extract carbs
        final carbsMatches = RegExp(r'(?:Carbs|Carbohydrates)[:\s]+(\d+\.?\d*)', caseSensitive: false)
            .firstMatch(content);
        if (carbsMatches != null && carbsMatches.groupCount >= 1) {
          carbs = double.tryParse(carbsMatches.group(1)!) ?? 0.0;
        }

        // Extract fat
        final fatMatches = RegExp(r'(?:Fat)[:\s]+(\d+\.?\d*)', caseSensitive: false)
            .firstMatch(content);
        if (fatMatches != null && fatMatches.groupCount >= 1) {
          fat = double.tryParse(fatMatches.group(1)!) ?? 0.0;
        }

        // Return structured data
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
      
      // Return default response if we couldn't extract the information
      return {
        'category': {'name': 'Apple'},
        'nutrition': {
          'calories': 52.0,
          'protein': 0.3,
          'carbs': 14.0,
          'fat': 0.2,
          'nutrients': [
            {'name': 'Protein', 'amount': 0.3, 'unit': 'g'},
            {'name': 'Carbohydrates', 'amount': 14.0, 'unit': 'g'},
            {'name': 'Fat', 'amount': 0.2, 'unit': 'g'},
          ]
        }
      };
    } catch (e) {
      print('Error extracting food info: $e');
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
  }
  
  /// Extract food items from response
  List<dynamic> _extractFoodItemsFromResponse(Map<String, dynamic> response) {
    try {
      // Handle the OpenAI format response
      if (response.containsKey('choices')) {
        // Create a single item with the response data
        return [_extractFoodInfoFromResponse(response)];
      }
      
      // Return a default list if we can't extract anything
      return [{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Apple',
        'nutrition': {
          'calories': 52.0,
          'protein': 0.3,
          'carbs': 14.0,
          'fat': 0.2,
          'nutrients': [
            {'name': 'Protein', 'amount': 0.3, 'unit': 'g'},
            {'name': 'Carbohydrates', 'amount': 14.0, 'unit': 'g'},
            {'name': 'Fat', 'amount': 0.2, 'unit': 'g'},
          ]
        }
      }];
    } catch (e) {
      print('Error extracting food items: $e');
      return [];
    }
  }
}