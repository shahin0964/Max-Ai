import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../../core/constants/app_strings.dart';
import 'tool_registry_service.dart';

class GeminiResponseResult {
  final String text;
  final int inputTokens;
  final int outputTokens;
  final int cachedTokens;
  final double durationSeconds;
  final String? executedTool;
  final String? toolOutput;

  GeminiResponseResult({
    required this.text,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.cachedTokens = 0,
    this.durationSeconds = 0.0,
    this.executedTool,
    this.toolOutput,
  });
}

class GeminiApiService {
  final String apiKey;
  final String model;
  final ToolRegistryService _toolRegistry = ToolRegistryService();

  GeminiApiService({
    required this.apiKey,
    this.model = 'gemini-3.8-flash',
  });

  /// Sends a token-optimized chat request to Google Gemini API (Gemini 3.8 Flash)
  /// Includes full function calling schemas for all 19 extracted tools.
  Future<GeminiResponseResult> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    String? systemPromptOverride,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final stopwatch = Stopwatch()..start();
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
        'parts': [{'text': systemPromptOverride ?? AppStrings.defaultSystemPrompt}],
      },
      'contents': contents,
      'tools': [
        {
          'function_declarations': ToolRegistryService.toolsSchema,
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      },
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      stopwatch.stop();
      final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extract token usage metadata
        final usageMetadata = data['usageMetadata'] as Map<String, dynamic>? ?? {};
        final inputTokens = usageMetadata['promptTokenCount'] as int? ?? (prompt.length ~/ 4) + 120;
        final outputTokens = usageMetadata['candidatesTokenCount'] as int? ?? 150;
        final cachedTokens = usageMetadata['cachedContentTokenCount'] as int? ?? 0;

        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List<dynamic>;

          final textParts = <String>[];
          String? executedToolName;
          String? toolResultOutput;

          for (final part in parts) {
            if (part.containsKey('text')) {
              textParts.add(part['text']);
            } else if (part.containsKey('functionCall')) {
              final func = part['functionCall'];
              final name = func['name'] as String;
              final args = (func['args'] as Map<String, dynamic>?) ?? {};
              executedToolName = name;
              
              // Automatically execute the tool locally!
              toolResultOutput = await _toolRegistry.executeTool(name, args);
              textParts.add('⚡ [Tool Executed]: $name\n$toolResultOutput');
            }
          }

          final finalAnswer = textParts.isNotEmpty ? textParts.join('\n\n') : 'Command acknowledged.';
          return GeminiResponseResult(
            text: finalAnswer,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cachedTokens: cachedTokens,
            durationSeconds: elapsedSec,
            executedTool: executedToolName,
            toolOutput: toolResultOutput,
          );
        }
        return GeminiResponseResult(
          text: 'No response generated.',
          durationSeconds: elapsedSec,
        );
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

  /// Multimodal Vision: Analyze image with prompt using Gemini 3.8 Flash
  Future<GeminiResponseResult> analyzeImage({
    required String prompt,
    required String base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final stopwatch = Stopwatch()..start();
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt.isNotEmpty ? prompt : 'Please analyze this image in detail and describe what you see.'},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 2048,
      }
    };

    try {
      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      stopwatch.stop();
      final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final usageMetadata = data['usageMetadata'] as Map<String, dynamic>? ?? {};
        final inputTokens = usageMetadata['promptTokenCount'] as int? ?? 1200;
        final outputTokens = usageMetadata['candidatesTokenCount'] as int? ?? 300;

        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List<dynamic>;
          final text = parts.map((p) => p['text'] ?? '').join('\n');
          return GeminiResponseResult(
            text: text,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            durationSeconds: elapsedSec,
          );
        }
        return GeminiResponseResult(text: 'No visual insights generated.', durationSeconds: elapsedSec);
      } else {
        final error = jsonDecode(response.body);
        final message = error['error']?['message'] ?? 'Vision analysis failed';
        throw Exception('Gemini Error: $message');
      }
    } catch (e) {
      rethrow;
    }
  }
}
