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
      print('====== FOOD IMAGE ANALYSIS DEBUG ======');
      print('Starting image analysis via VM proxy...');
      print('Image file exists: ${imageFile.existsSync()}');
      print('Image file path: ${imageFile.path}');
      print('Image file size: ${await imageFile.length()} bytes');
      
      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      print('Image bytes read: ${imageBytes.length} bytes');
      
      String base64Image = base64Encode(imageBytes);
      print('Base64 image length: ${base64Image.length}');
      
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
      
      print('Sending request to: $uri');
      print('Request ID: $requestId');
      print('Model name: $modelName');
      print('Request length: ${requestBody.length} bytes');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'image-analysis',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 60)); // Extended timeout
      
      print('Response received with status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Response body length: ${response.body.length}');
        if (response.body.isNotEmpty) {
          try {
            // First try to parse as JSON
            final jsonData = json.decode(response.body);
            print('Successfully parsed response as JSON');
            
            // Check for OpenAI API style response with choices
            if (jsonData is Map<String, dynamic>) {
              print('Response keys: ${jsonData.keys.join(', ')}');
              
              // If the response already has the structure we need, return it directly
              if (jsonData.containsKey('category') && jsonData.containsKey('nutrition')) {
                print('Response already in correct format');
                return jsonData;
              }
              
              // If it's an OpenAI API response with choices
              if (jsonData.containsKey('choices') && jsonData['choices'] is List && jsonData['choices'].isNotEmpty) {
                final content = jsonData['choices'][0]['message']['content'] as String? ?? '';
                print('Extracted content from choices: ${content.substring(0, min(50, content.length))}...');
                
                return _extractFoodInfoFromText(content);
              }
              
              // If it has 'error' field, throw exception with error message
              if (jsonData.containsKey('error')) {
                final errorMsg = jsonData['error'] is String 
                    ? jsonData['error'] 
                    : jsonData['error'] is Map 
                        ? jsonData['error']['message'] ?? 'Unknown error' 
                        : 'Unknown error';
                throw Exception('VM returned error: $errorMsg');
              }
              
              print('Response format not recognized, attempting text extraction');
              // Try to extract food info anyway
              return _extractFoodInfoFromText(response.body);
            } else {
              print('Response is not a Map: ${jsonData.runtimeType}');
              throw Exception('Unexpected response format: not a JSON object');
            }
          } catch (e) {
            print('Error parsing JSON: $e');
            // If not valid JSON, try to extract info directly from text
            print('Attempting to extract from raw text');
            return _extractFoodInfoFromText(response.body);
          }
        } else {
          print('Response body is empty');
          throw Exception('Empty response from VM');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error in image analysis: $e');
      print('====== END FOOD IMAGE ANALYSIS DEBUG ======');
      
      // Provide meaningful error for the user
      throw Exception('Image analysis failed: $e');
    }
  }
  
  /// Extract food information from raw text
  Map<String, dynamic> _extractFoodInfoFromText(String text) {
    print('Extracting food info from text: ${text.substring(0, min(100, text.length))}...');
    
    try {
      // Extract food name
      String foodName = 'Unidentified Food Item';
      final nameMatches = RegExp(r'(?:Food\s*Name|Name)[:\s]+([^\n\.]+)', caseSensitive: false).firstMatch(text);
      if (nameMatches != null && nameMatches.groupCount >= 1) {
        foodName = nameMatches.group(1)!.trim();
      } else {
        // Try alternate format
        final altNameMatches = RegExp(r'(?:is|contains|appears to be)[:\s]*(.*?)(?:\.|$|\n)', caseSensitive: false).firstMatch(text);
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
      
      print('Extracted: name=$foodName, calories=$calories, protein=$protein, carbs=$carbs, fat=$fat');
      
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
        print('No nutrition data found, using defaults for $foodName');
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
      print('Error extracting food info from text: $e');
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
      print('Getting food information via VM proxy: $name');

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
      
      print('Sending food info request to: $uri');
      print('Food name: $name');
      print('Using model: $modelName');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-info',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      print('Response received with status: ${response.statusCode}');
      
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
          
          // Try to extract anyway
          return _extractFoodInfoFromText(response.body);
        } catch (e) {
          print('Error parsing JSON: $e');
          return _extractFoodInfoFromText(response.body);
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error getting food information: $e');
      throw Exception('Failed to get food information: $e');
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
        "modelName": modelName, // Pass the model name to the VM
      });

      // Send request to VM proxy
      final uri = Uri(
        scheme: 'http',
        host: _vmProxyUrl,
        port: _vmProxyPort,
        path: _vmProxyEndpoint,
      );
      
      print('Sending food search request to: $uri');
      print('Search query: $query');
      print('Using model: $modelName');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Request-Type': 'food-search',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          
          // If it's an OpenAI API response with choices
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
          print('Error parsing JSON: $e');
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
        print('HTTP Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('VM proxy error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error searching foods: $e');
      throw Exception('Failed to search foods: $e');
    }
  }
  
  // Helper function to get minimum of two integers
  int min(int a, int b) => a < b ? a : b;
}