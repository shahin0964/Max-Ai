import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../../core/constants/app_strings.dart';

class GeminiApiService {
  final String apiKey;
  final String model;

  GeminiApiService({
    required this.apiKey,
    this.model = 'gemini-1.5-flash',
  });

  /// Sends a token-optimized chat request to Google Gemini API
  /// Uses a sliding window of recent messages to prevent token explosion.
  Future<String> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    // Token Saver: Keep only the latest 4 turns (8 messages maximum)
    final trimmedHistory = history.length > 8
        ? history.sublist(history.length - 8)
        : history;

    final contents = <Map<String, dynamic>>[];

    // Insert conversation history
    for (final msg in trimmedHistory) {
      if (msg.sender == MessageSender.user) {
        contents.add({
          'role': 'user',
          'parts': [{'text': msg.text}],
        });
      } else if (msg.sender == MessageSender.assistant) {
        contents.add({
          'role': 'model',
          'parts': [{'text': msg.text}],
        });
      }
    }

    // Add current prompt
    contents.add({
      'role': 'user',
      'parts': [{'text': prompt}],
    });

    final payload = {
      'system_instruction': {
        'parts': [{'text': AppStrings.defaultSystemPrompt}],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List<dynamic>;
          return parts.map((p) => p['text']).join('');
        }
        return 'No response generated.';
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded (429). Please wait a moment before sending another message.');
      } else {
        final error = jsonDecode(response.body);
        final message = error['error']?['message'] ?? 'Unknown error occurred';
        throw Exception('Gemini Error (${response.statusCode}): $message');
      }
    } catch (e) {
      rethrow;
    }
  }
}
