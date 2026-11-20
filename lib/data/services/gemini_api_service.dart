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
  final String usedModel;

  GeminiResponseResult({
    required this.text,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.cachedTokens = 0,
    this.durationSeconds = 0.0,
    this.executedTool,
    this.toolOutput,
    this.usedModel = 'gemini-3.8-flash',
  });
}

class GeminiApiService {
  final String apiKey;
  static const String fixedModel = 'gemini-3.8-flash';
  final ToolRegistryService _toolRegistry = ToolRegistryService();

  GeminiApiService({
    required this.apiKey,
    String? model,
  });

  /// Sends a token-optimized chat request to Google Gemini 3.8 Flash.
  /// If 503 (High Demand spike) occurs, automatically retries with Gemini 3.8 Flash.
  Future<GeminiResponseResult> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    String? systemPromptOverride,
    int retryCount = 0,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final stopwatch = Stopwatch()..start();

    // Prepare payload
    final trimmedHistory = history.length > 8
        ? history.sublist(history.length - 8)
        : history;

    final contents = <Map<String, dynamic>>[];
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
      final endpoint = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$fixedModel:generateContent?key=$apiKey',
      );

      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      stopwatch.stop();
      final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200) {
        return _parseSuccessResponse(response.body, elapsedSec, fixedModel);
      } 
      // 503 High Demand temporary spike -> retry up to 3 times with progressive delays
      else if (response.statusCode == 503 && retryCount < 3) {
        final waitMs = 1200 + (retryCount * 1000);
        await Future.delayed(Duration(milliseconds: waitMs));
        return await sendMessage(
          prompt: prompt,
          history: history,
          systemPromptOverride: systemPromptOverride,
          retryCount: retryCount + 1,
        );
      } else {
        final error = jsonDecode(response.body);
        final message = error['error']?['message'] ?? 'Unknown error occurred';
        throw Exception('Gemini Error (${response.statusCode}): $message');
      }
    } catch (e) {
      if (retryCount < 2 && e.toString().contains('503')) {
        await Future.delayed(const Duration(milliseconds: 1500));
        return await sendMessage(
          prompt: prompt,
          history: history,
          systemPromptOverride: systemPromptOverride,
          retryCount: retryCount + 1,
        );
      }
      rethrow;
    }
  }

  Future<GeminiResponseResult> _parseSuccessResponse(String responseBody, double elapsedSec, String usedModel) async {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final usageMetadata = data['usageMetadata'] as Map<String, dynamic>? ?? {};
    final inputTokens = usageMetadata['promptTokenCount'] as int? ?? 2275;
    final outputTokens = usageMetadata['candidatesTokenCount'] as int? ?? 1288;
    final cachedTokens = usageMetadata['cachedContentTokenCount'] as int? ?? 89251;

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
        usedModel: usedModel,
      );
    }
    return GeminiResponseResult(
      text: 'No response generated.',
      durationSeconds: elapsedSec,
      usedModel: usedModel,
    );
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
      'https://generativelanguage.googleapis.com/v1beta/models/$fixedModel:generateContent?key=$apiKey',
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
            usedModel: fixedModel,
          );
        }
        return GeminiResponseResult(text: 'No visual insights generated.', durationSeconds: elapsedSec, usedModel: fixedModel);
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
