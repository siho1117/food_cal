// lib/data/services/fallback_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Added for debugPrint

/// Provider to handle VM proxy for OpenAI API access
class FallbackProvider {
  // VM proxy configuration
  final String _vmProxyUrl = '35.201.20.109'; // Your Google Cloud VM IP
  final int _vmProxyPort = 3000; // Node.js server port
  final String _vmProxyEndpoint = '/api/openai-proxy'; // Your server endpoint

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
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
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
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
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
                
                return _extractFoodInfoFromText(content);
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
              
              return _extractFoodInfoFromText(response.body);
            }
          } catch (e) {
            // ✅ FIXED: Replace print with debugPrint
            debugPrint('JSON parsing failed: $e');
            // ✅ FIXED: Replace print with debugPrint
            debugPrint('Attempting to extract from raw text');
            
            return _extractFoodInfoFromText(response.body);
          }
        }
        
        // Default response if nothing else works
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

  /// Extract food information from text content
  Map<String, dynamic> _extractFoodInfoFromText(String text) {
    try {
      // Try to find the food name first
      String foodName = 'Unidentified Food Item';
      
      // Look for "Food Name:" or "Name:" patterns
      final nameMatches = RegExp(r'(?:Food\s*Name|Name)[:\s]+([^\n]+)', caseSensitive: false).firstMatch(text);
      if (nameMatches != null && nameMatches.groupCount >= 1) {
        foodName = nameMatches.group(1)!.trim();
      } else {
        // Alternative patterns - "this is", "contains", "appears to be"
        final altNameMatches = RegExp(r'(?:this\s*is|contains|appears to be)[:\s]*(.*?)(?:\.|$|\n)', caseSensitive: false).firstMatch(text);
        if (altNameMatches != null && altNameMatches.groupCount >= 1) {
          foodName = altNameMatches.group(1)!.trim();
        }
      }
      
      // Extract calories
      double calories = 0.0;
      final caloriesMatches = RegExp(r'(?:Calories|Cal)[:\s]+(\d+\.?\d*)', caseSensitive: false).firstMatch(text);
      if (caloriesMatches != null && caloriesMatches.groupCount >= 1) {
        calories = double.tryParse(caloriesMatches.group(1)!) ?? 0.0;
      }
      
      // Extract protein
      double protein = 0.0;
      final proteinMatches = RegExp(r'(?:Protein)[:\s]+(\d+\.?\d*)', caseSensitive: false).firstMatch(text);
      if (proteinMatches != null && proteinMatches.groupCount >= 1) {
        protein = double.tryParse(proteinMatches.group(1)!) ?? 0.0;
      }
      
      // Extract carbs
      double carbs = 0.0;
      final carbsMatches = RegExp(r'(?:Carbs|Carbohydrates)[:\s]+(\d+\.?\d*)', caseSensitive: false).firstMatch(text);
      if (carbsMatches != null && carbsMatches.groupCount >= 1) {
        carbs = double.tryParse(carbsMatches.group(1)!) ?? 0.0;
      }
      
      // Extract fat
      double fat = 0.0;
      final fatMatches = RegExp(r'(?:Fat)[:\s]+(\d+\.?\d*)', caseSensitive: false).firstMatch(text);
      if (fatMatches != null && fatMatches.groupCount >= 1) {
        fat = double.tryParse(fatMatches.group(1)!) ?? 0.0;
      }
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Extracted: name=$foodName, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');
      
      // If we found a name but no nutritional data, assign default values
      if (foodName != 'Unidentified Food Item' && calories == 0.0 && protein == 0.0 && carbs == 0.0 && fat == 0.0) {
        // Set default values based on common food category
        if (foodName.toLowerCase().contains('apple')) {
          calories = 52.0;
          protein = 0.3;
          carbs = 14.0;
          fat = 0.2;
        } else if (foodName.toLowerCase().contains('banana')) {
          calories = 89.0;
          protein = 1.1;
          carbs = 23.0;
          fat = 0.3;
        } else {
          // Generic defaults
          calories = 150.0;
          protein = 5.0;
          carbs = 20.0;
          fat = 8.0;
        }
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('No nutrition data found, using defaults for $foodName');
      }
      
      // Return formatted result
      return {
        'category': {'name': foodName},
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
      debugPrint('Error extracting food info from text: $e');
      return {
        'category': {'name': 'Unidentified Food Item'},
        'nutrition': {
          'calories': 100.0,
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
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
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
            return _extractFoodInfoFromText(content);
          }
          
          // Try to extract from raw response
          return _extractFoodInfoFromText(response.body);
        } catch (e) {
          // ✅ FIXED: Replace print with debugPrint
          debugPrint('Error parsing JSON: $e');
          return _extractFoodInfoFromText(response.body);
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

  /// Search for foods by name using VM proxy
  Future<List<dynamic>> searchFoods(String query, String apiKey, String modelName) async {
    try {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Searching foods via VM proxy: $query');

      // Generate request ID
      final requestId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create request body for the VM proxy
      final requestBody = json.encode({
        "searchQuery": query,
        "requestId": requestId,
        "modelName": modelName,
        "maxResults": 5,
      });

      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
      );
      
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Sending search request to: $uri');
      debugPrint('Search query: $query');
      debugPrint('Using model: $modelName');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-search',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Response received with status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          
          // If the response has a content field with OpenAI response
          if (jsonData is Map<String, dynamic> && 
              jsonData.containsKey('choices') && 
              jsonData['choices'] is List && 
              jsonData['choices'].isNotEmpty) {
            
            final content = jsonData['choices'][0]['message']['content'] as String? ?? '';
            final foodInfo = _extractFoodInfoFromText(content);
            
            return [{
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': foodInfo['category']['name'],
              'nutrition': foodInfo['nutrition']
            }];
          }
          
          // If the response has an items array
          if (jsonData is Map<String, dynamic> && 
              jsonData.containsKey('items') && 
              jsonData['items'] is List) {
            return jsonData['items'] as List;
          }
          
          // If the response itself is a list
          if (jsonData is List) {
            return jsonData;
          }
          
          // If the response has the structure we need
          if (jsonData is Map<String, dynamic> && 
              jsonData.containsKey('category') && 
              jsonData.containsKey('nutrition')) {
            
            return [{
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': jsonData['category']['name'],
              'nutrition': jsonData['nutrition']
            }];
          }
        } catch (e) {
          // ✅ FIXED: Replace print with debugPrint
          debugPrint('Error parsing JSON: $e');
        }
        
        // Return a default response if we couldn't extract anything
        return [{
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': query,
          'nutrition': {
            'calories': 100.0,
            'protein': 5.0,
            'carbs': 15.0,
            'fat': 3.0,
            'nutrients': [
              {'name': 'Protein', 'amount': 5.0, 'unit': 'g'},
              {'name': 'Carbohydrates', 'amount': 15.0, 'unit': 'g'},
              {'name': 'Fat', 'amount': 3.0, 'unit': 'g'},
            ]
          }
        }];
      } else {
        // ✅ FIXED: Replace print with debugPrint
        debugPrint('HTTP Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error searching foods: $e');
      throw Exception('Failed to search foods: $e');
    }
  }
  
  // Helper function to get minimum of two integers
  int min(int a, int b) => a < b ? a : b;
}