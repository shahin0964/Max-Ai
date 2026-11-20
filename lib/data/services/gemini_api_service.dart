import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../../core/constants/app_strings.dart';
import 'tool_registry_service.dart';
import 'groq_api_service.dart';

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
  final String? groqApiKey;
  final ToolRegistryService _toolRegistry = ToolRegistryService();

  static const List<String> fallbackModels = [
    'gemini-3.8-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-1.5-flash',
  ];

  GeminiApiService({
    required this.apiKey,
    this.groqApiKey,
    String? model,
  });

  /// Parse multiple API keys separated by commas, semicolons, or newlines
  List<String> get keyPool {
    final list = apiKey
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return list.isEmpty ? [apiKey.trim()] : list;
  }

  /// Sends a token-optimized chat request to Google Gemini with automatic
  /// Key Rotation & Model Cascading to defeat 429 rate limits!
  Future<GeminiResponseResult> sendMessage({
    required String prompt,
    required List<ChatMessage> history,
    String? systemPromptOverride,
    int keyIndex = 0,
    int modelIndex = 0,
    int retryCount = 0,
  }) async {
    final keys = keyPool;
    if (keys.isEmpty || keys.first.isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final activeKey = keyIndex < keys.length ? keys[keyIndex] : keys.first;
    final activeModel = modelIndex < fallbackModels.length
        ? fallbackModels[modelIndex]
        : fallbackModels.first;

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
        'https://generativelanguage.googleapis.com/v1beta/models/$activeModel:generateContent?key=$activeKey',
      );

      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      stopwatch.stop();
      final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200) {
        return _parseSuccessResponse(response.body, elapsedSec, activeModel);
      } 
      // 429 Quota Exceeded (Free tier 20/day limit hit on 3.8) -> Auto-switch key or cascade model!
      else if (response.statusCode == 429) {
        // First try next API key in pool if available
        if (keyIndex + 1 < keys.length) {
          return await sendMessage(
            prompt: prompt,
            history: history,
            systemPromptOverride: systemPromptOverride,
            keyIndex: keyIndex + 1,
            modelIndex: modelIndex,
          );
        }
        // If all keys exhausted for current model, cascade to gemini-2.0-flash (1,500/day limit!)
        else if (modelIndex + 1 < fallbackModels.length) {
          return await sendMessage(
            prompt: prompt,
            history: history,
            systemPromptOverride: systemPromptOverride,
            keyIndex: 0,
            modelIndex: modelIndex + 1,
          );
        }
        // If Groq API key is available, seamlessly fallback to Groq (14,400/day limit!)
        else if (groqApiKey != null && groqApiKey!.trim().isNotEmpty) {
          final groq = GroqApiService(apiKey: groqApiKey!);
          return await groq.sendMessage(
            prompt: prompt,
            history: history,
            systemPromptOverride: systemPromptOverride,
          );
        } else {
          final error = jsonDecode(response.body);
          final message = error['error']?['message'] ?? 'Quota limit reached.';
          throw Exception('Daily Free Quota Exceeded on Gemini: $message. Please add a second API key or Groq Key in Settings to get unlimited messages.');
        }
      }
      // 503 High Demand temporary spike -> retry once, then cascade to next model (e.g. gemini-2.0-flash)
      else if (response.statusCode == 503) {
        if (retryCount < 1) {
          await Future.delayed(const Duration(milliseconds: 1000));
          return await sendMessage(
            prompt: prompt,
            history: history,
            systemPromptOverride: systemPromptOverride,
            keyIndex: keyIndex,
            modelIndex: modelIndex,
            retryCount: retryCount + 1,
          );
        } else if (modelIndex + 1 < fallbackModels.length) {
          return await sendMessage(
            prompt: prompt,
            history: history,
            systemPromptOverride: systemPromptOverride,
            keyIndex: 0,
            modelIndex: modelIndex + 1,
            retryCount: 0,
          );
        } else {
          final error = jsonDecode(response.body);
          final message = error['error']?['message'] ?? 'Servers busy';
          throw Exception('Gemini Error (503): $message');
        }
      }
      // 404 Model Not Found or deprecated -> immediately cascade to next active model!
      else if (response.statusCode == 404 && modelIndex + 1 < fallbackModels.length) {
        return await sendMessage(
          prompt: prompt,
          history: history,
          systemPromptOverride: systemPromptOverride,
          keyIndex: 0,
          modelIndex: modelIndex + 1,
          retryCount: 0,
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
          keyIndex: keyIndex,
          modelIndex: modelIndex,
          retryCount: retryCount + 1,
        );
      }
      // If Groq key exists and Gemini completely failed, try Groq
      if (groqApiKey != null && groqApiKey!.trim().isNotEmpty && !e.toString().contains('Groq')) {
        try {
          final groq = GroqApiService(apiKey: groqApiKey!);
          return await groq.sendMessage(
            prompt: prompt,
            history: history,
            systemPromptOverride: systemPromptOverride,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<GeminiResponseResult> _parseSuccessResponse(String responseBody, double elapsedSec, String usedModel) async {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final usageMetadata = data['usageMetadata'] as Map<String, dynamic>? ?? {};
    final inputTokens = usageMetadata['promptTokenCount'] as int? ?? 120;
    final outputTokens = usageMetadata['candidatesTokenCount'] as int? ?? 250;
    final cachedTokens = usageMetadata['cachedContentTokenCount'] as int? ?? 0;

    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates != null && candidates.isNotEmpty) {
      final content = candidates[0]['content'];
      final parts = content['parts'] as List<dynamic>;

      for (final part in parts) {
        // Check for Tool / Function call
        if (part.containsKey('functionCall')) {
          final functionCall = part['functionCall'] as Map<String, dynamic>;
          final toolName = functionCall['name'] as String;
          final args = (functionCall['args'] as Map<String, dynamic>?) ?? {};

          // Execute tool directly on Android device
          final toolExecutionResult = await _toolRegistry.executeTool(toolName, args);

          // Return response showing execution status
          return GeminiResponseResult(
            text: '⚡ [Tool Executed]: $toolName\n$toolExecutionResult',
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cachedTokens: cachedTokens,
            durationSeconds: elapsedSec,
            executedTool: toolName,
            toolOutput: toolExecutionResult,
            usedModel: usedModel,
          );
        }

        // Standard text response
        if (part.containsKey('text')) {
          return GeminiResponseResult(
            text: part['text'] as String,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cachedTokens: cachedTokens,
            durationSeconds: elapsedSec,
            usedModel: usedModel,
          );
        }
      }
    }

    return GeminiResponseResult(
      text: 'No response received from model.',
      durationSeconds: elapsedSec,
      usedModel: usedModel,
    );
  }

  /// Multimodal Vision: Analyze image with prompt
  Future<GeminiResponseResult> analyzeImage({
    required String prompt,
    required String base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    final keys = keyPool;
    if (keys.isEmpty || keys.first.isEmpty) {
      throw Exception('API Key is missing. Please set your Gemini API key in Settings.');
    }

    final key = keys.first;
    final stopwatch = Stopwatch()..start();
    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$key',
    );

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
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
        'maxOutputTokens': 1024,
      }
    };

    final response = await http.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    stopwatch.stop();
    final elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;

    if (response.statusCode == 200) {
      return _parseSuccessResponse(response.body, elapsedSec, 'gemini-2.0-flash');
    } else {
      final error = jsonDecode(response.body);
      final message = error['error']?['message'] ?? 'Image analysis failed';
      throw Exception('Gemini Vision Error: $message');
    }
  }
}
