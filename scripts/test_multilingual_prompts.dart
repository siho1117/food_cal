// scripts/test_multilingual_prompts.dart
// Test multilingual food recognition with updated prompts
// Run with: dart run scripts/test_multilingual_prompts.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🌍 Testing Multilingual Food Recognition\n');
  print('=' * 70);

  // Load API key
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Error: .env file not found!');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final lines = envContent.split('\n');
  String? apiKey;

  for (final line in lines) {
    if (line.startsWith('QWEN_API_KEY=')) {
      apiKey = line.substring('QWEN_API_KEY='.length).trim();
      break;
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ Error: QWEN_API_KEY not found!');
    exit(1);
  }

  print('✅ API Key loaded\n');

  const baseUrl = 'dashscope-intl.aliyuncs.com';
  const endpoint = '/compatible-mode/v1/chat/completions';
  const model = 'qwen3-vl-flash';
  const testImageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';

  // Test languages
  final languages = ['English', 'Chinese', 'Spanish', 'French'];

  for (final language in languages) {
    print('\n${'=' * 70}');
    print('Testing Language: $language');
    print('=' * 70);

    // Create prompts with language parameter
    final systemPrompt =
        "Food recognition. Return food name in $language. "
        "Return ONLY JSON with exact values (no rounding). "
        "Name: capitalize first letter, max 8 words, no parentheses. "
        "Assume 1.0 serving.";

    final userPrompt =
        "Identify food, assume 1.0 serving, return food name in $language. "
        "Return ONLY this JSON: "
        '{"name": "Food name", "calories": 0, "protein": 0, "carbs": 0, "fat": 0}';

    final combinedPrompt = '$systemPrompt\n\n$userPrompt';

    print('\n📤 Sending request...');

    final requestBody = {
      "model": model,
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
              "image_url": {"url": testImageUrl}
            }
          ]
        }
      ],
      "temperature": 0.1,
    };

    try {
      final uri = Uri.https(baseUrl, endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        print('✅ Response received:');
        print('-' * 70);
        print(content);
        print('-' * 70);

        // Try to parse as JSON to verify format
        try {
          final jsonContent = jsonDecode(content);
          print('\n✅ Valid JSON format');
          print('   Name: ${jsonContent['name']}');
          print('   Calories: ${jsonContent['calories']}');
          print('   Protein: ${jsonContent['protein']}g');
          print('   Carbs: ${jsonContent['carbs']}g');
          print('   Fat: ${jsonContent['fat']}g');
        } catch (e) {
          print('\n⚠️ Response is not valid JSON');
        }

        if (data['usage'] != null) {
          print('\n📊 Tokens: ${data['usage']['total_tokens']}');
        }
      } else {
        print('❌ Error: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('❌ Request failed: $e');
    }

    // Wait a bit between requests
    await Future.delayed(const Duration(seconds: 2));
  }

  print('\n${'=' * 70}');
  print('✅ Multilingual testing complete!');
  print('=' * 70);
}
