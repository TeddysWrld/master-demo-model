import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:master_demo_app/env.dart';

/// OpenAI service for Flutter Web demo
class OpenAIService {
  String apiKey = OPEN_AI_KEY;
  final FlutterTts _flutterTts = FlutterTts();

  OpenAIService(this.apiKey);

  /// Translate nested JSON into a given language
  Future<List<dynamic>?> translateJsonNested(List<dynamic> jsonArray, String language) async {
    final prompt = """
Translate only the STRING VALUES of this JSON into $language.
**Return ONLY JSON**, do not include markdown, explanations, or backticks
- Keep all keys, numbers, booleans, and hex colors unchanged.
- Maintain the exact JSON structure.
- Return valid JSON only.

JSON:
${jsonEncode(jsonArray)}
""";

    final response = await _sendRequest(prompt);
    if (response == null) return null;

    try {
      final List<dynamic> translatedJson = jsonDecode(response);
      return translatedJson;
    } catch (e) {
      print("❌ Failed to parse JSON: $e");
      return null;
    }
  }

  /// Review code and simulate execution
  Future<Map<String, String>?> reviewAndExecuteCode(String code) async {
    final prompt = """
You are a Flutter/Dart code reviewer.
1. Review the code and provide suggestions.
2. Simulate the output/result of running the code (do NOT actually execute, just reason about the result).
3. Return valid JSON only, structured like this:
{
  "review": "your suggestions here",
  "execution_result": "expected output here"
}

Code:
```dart
$code
""";
    final response = await _sendRequest(prompt);
    if (response == null) return null;

    try {
      final Map<String, dynamic> parsed = jsonDecode(response);
      return {"review": parsed["review"] ?? "", "execution_result": parsed["execution_result"] ?? ""};
    } catch (e) {
      print("❌ Failed to parse code review JSON: $e");
      return null;
    }
  }

  /// Speak text out loud in a given language
  Future<void> speakText(String text, String languageCode) async {
    await _flutterTts.setLanguage(languageCode); // e.g., "fr-FR", "zu-ZA"
    await _flutterTts.speak(text);
  }

  /// Internal helper to call OpenAI API
  Future<String?> _sendRequest(String prompt) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print("❌ API Error: ${response.body}");
      return null;
    }
  }
}
