import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../../core/constants/app_strings.dart';
import 'gemini_api_service.dart';

class GroqApiService {
  final String apiKey;
  final String model;

  GroqApiService({
    required this.apiKey,
    this.model = 'llama-3.3-70b-versatile',
  });

  Future<GeminiResponseResult> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    String? systemPromptOverride,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Groq API Key is empty.');
    }

    final stopwatch = Stopwatch()..start();

    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': systemPromptOverride ?? AppStrings.defaultSystemPrompt,
      }
    ];

    final trimmedHistory = history.length > 10
        ? history.sublist(history.length - 10)
        : history;

    for (final msg in trimmedHistory) {
      messages.add({
        'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
        'content': msg.text,
      });
    }

    messages.add({
      'role': 'user',
      'content': prompt,
    });

    final payload = {
      'model': model,
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 2048,
    };

    final endpoint = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final response = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.trim()}',
      },
      body: jsonEncode(payload),
    );

    stopwatch.stop();
    final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final replyText = data['choices']?[0]?['message']?['content'] ?? '';
      final usage = data['usage'] ?? {};
      final promptTokens = usage['prompt_tokens'] as int? ?? 50;
      final completionTokens = usage['completion_tokens'] as int? ?? 120;

      return GeminiResponseResult(
        text: replyText,
        inputTokens: promptTokens,
        outputTokens: completionTokens,
        cachedTokens: 0,
        durationSeconds: elapsedSec,
        usedModel: 'Groq ($model)',
      );
    } else {
      final err = jsonDecode(response.body);
      final msg = err['error']?['message'] ?? 'Groq API error';
      throw Exception('Groq Error (${response.statusCode}): $msg');
    }
  }
}
