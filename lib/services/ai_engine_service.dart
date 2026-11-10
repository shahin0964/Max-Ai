import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_provider.dart';
import 'hardware_telemetry_service.dart';
import 'memory_service.dart';
import 'settings_service.dart';

class AIEngineResponse {
  final String text;
  final int latencyMs;
  final String model;
  final String provider;

  AIEngineResponse({
    required this.text,
    required this.latencyMs,
    required this.model,
    required this.provider,
  });
}

class AIEngineService {
  static final AIEngineService instance = AIEngineService._internal();
  AIEngineService._internal();

  Future<AIEngineResponse> generateResponse({
    required List<ChatMessage> history,
    String? customSystemPrompt,
  }) async {
    final settings = SettingsService.instance;
    final provider = settings.activeProvider;
    final modelId = settings.activeModelId;

    final systemPrompt = (customSystemPrompt ?? settings.systemPrompt) +
        MemoryService.instance.buildPromptContext();

    final stopwatch = Stopwatch()..start();

    try {
      String replyText = '';
      switch (provider) {
        case AIProvider.gemini:
          replyText = await _callGemini(modelId, history, systemPrompt, settings.geminiApiKey);
          break;
        case AIProvider.claude:
          replyText = await _callClaude(modelId, history, systemPrompt, settings.claudeApiKey);
          break;
        case AIProvider.openai:
          replyText = await _callOpenAI(modelId, history, systemPrompt, settings.openAiApiKey);
          break;
        case AIProvider.openjarvisLocal:
          replyText = await _callLocalServer(modelId, history, systemPrompt, settings.localServerUrl);
          break;
      }

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;
      HardwareTelemetryService.instance.updateLatency(latency, '$modelId (${provider.label})');

      return AIEngineResponse(
        text: replyText,
        latencyMs: latency,
        model: modelId,
        provider: provider.label,
      );
    } catch (e) {
      stopwatch.stop();
      return AIEngineResponse(
        text: 'Error generating response: $e\n\nPlease check your API key or Local Server connection in Settings.',
        latencyMs: stopwatch.elapsedMilliseconds,
        model: modelId,
        provider: provider.label,
      );
    }
  }

  // Test connection ping for a provider
  Future<bool> testConnection(AIProvider provider) async {
    final settings = SettingsService.instance;
    try {
      if (provider == AIProvider.openjarvisLocal) {
        final url = Uri.parse('${settings.localServerUrl}/v1/models');
        final res = await http.get(url).timeout(const Duration(seconds: 4));
        return res.statusCode == 200;
      } else if (provider == AIProvider.gemini) {
        if (settings.geminiApiKey.isEmpty) return false;
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models?key=${settings.geminiApiKey}');
        final res = await http.get(url).timeout(const Duration(seconds: 5));
        return res.statusCode == 200;
      } else if (provider == AIProvider.claude) {
        return settings.claudeApiKey.isNotEmpty;
      } else if (provider == AIProvider.openai) {
        if (settings.openAiApiKey.isEmpty) return false;
        final url = Uri.parse('https://api.openai.com/v1/models');
        final res = await http.get(url, headers: {
          'Authorization': 'Bearer ${settings.openAiApiKey}',
        }).timeout(const Duration(seconds: 5));
        return res.statusCode == 200;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // 1. Google Gemini API Call
  Future<String> _callGemini(
    String model,
    List<ChatMessage> history,
    String systemPrompt,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      throw 'Gemini API key is not configured. Please set it in Settings.';
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

    final contents = <Map<String, dynamic>>[];

    // Include recent history (last 10 messages)
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    for (final m in recent) {
      final role = m.role == MessageRole.user ? 'user' : 'model';
      contents.add({
        'role': role,
        'parts': [
          {'text': m.content}
        ],
      });
    }

    final payload = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': SettingsService.instance.temperature,
        'maxOutputTokens': 2048,
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          return parts.first['text'] as String? ?? 'No response generated.';
        }
      }
      return 'Empty response from Gemini.';
    }

    // Fallback: Google Interactions API (Standard for Gemini 3.8 Flash)
    try {
      final interactionUrl = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/interactions?key=$apiKey');

      final lastUserMsg = history.isNotEmpty
          ? history.reversed.firstWhere(
              (m) => m.role == MessageRole.user,
              orElse: () => history.last,
            )
          : null;

      final userText = lastUserMsg?.content ?? 'Hello';

      final interactionPayload = {
        'model': model,
        'input': userText,
        'system_instruction': systemPrompt,
      };

      final intResponse = await http.post(
        interactionUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(interactionPayload),
      ).timeout(const Duration(seconds: 25));

      if (intResponse.statusCode == 200) {
        final intJson = jsonDecode(intResponse.body) as Map<String, dynamic>;
        if (intJson.containsKey('output_text') && intJson['output_text'] != null) {
          return intJson['output_text'] as String;
        }
        final steps = intJson['steps'] as List<dynamic>?;
        if (steps != null) {
          for (final s in steps.reversed) {
            final content = s['content'] as List<dynamic>?;
            if (content != null && content.isNotEmpty) {
              for (final c in content) {
                if (c is Map<String, dynamic> && c['text'] != null) {
                  return c['text'] as String;
                }
              }
            }
          }
        }
        return 'Interaction response received.';
      }
    } catch (_) {
      // Fall through to throw original generateContent response error
    }

    final body = response.body;
    throw 'Gemini HTTP ${response.statusCode}: $body';
  }

  // 2. Anthropic Claude API Call
  Future<String> _callClaude(
    String model,
    List<ChatMessage> history,
    String systemPrompt,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      throw 'Anthropic Claude API key is not configured. Please set it in Settings.';
    }

    final url = Uri.parse('https://api.anthropic.com/v1/messages');

    final messages = <Map<String, dynamic>>[];
    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    for (final m in recent) {
      if (m.role == MessageRole.system) continue;
      messages.add({
        'role': m.role == MessageRole.user ? 'user' : 'assistant',
        'content': m.content,
      });
    }

    final payload = {
      'model': model,
      'max_tokens': 2048,
      'system': systemPrompt,
      'messages': messages,
      'temperature': SettingsService.instance.temperature,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw 'Claude HTTP ${response.statusCode}: ${response.body}';
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = json['content'] as List<dynamic>?;
    if (content != null && content.isNotEmpty) {
      return content.first['text'] as String? ?? '';
    }
    return 'Empty response from Claude.';
  }

  // 3. OpenAI API Call
  Future<String> _callOpenAI(
    String model,
    List<ChatMessage> history,
    String systemPrompt,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      throw 'OpenAI API key is not configured. Please set it in Settings.';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt}
    ];

    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    for (final m in recent) {
      messages.add({
        'role': m.role == MessageRole.user ? 'user' : 'assistant',
        'content': m.content,
      });
    }

    final payload = {
      'model': model,
      'messages': messages,
      'temperature': SettingsService.instance.temperature,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw 'OpenAI HTTP ${response.statusCode}: ${response.body}';
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices != null && choices.isNotEmpty) {
      return choices.first['message']?['content'] as String? ?? '';
    }
    return 'Empty response from OpenAI.';
  }

  // 4. OpenJarvis / Local Ollama Server Call
  Future<String> _callLocalServer(
    String model,
    List<ChatMessage> history,
    String systemPrompt,
    String serverUrl,
  ) async {
    final cleanUrl = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    final url = Uri.parse('$cleanUrl/v1/chat/completions');

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt}
    ];

    final recent = history.length > 10 ? history.sublist(history.length - 10) : history;
    for (final m in recent) {
      messages.add({
        'role': m.role == MessageRole.user ? 'user' : 'assistant',
        'content': m.content,
      });
    }

    final payload = {
      'model': model,
      'messages': messages,
      'temperature': SettingsService.instance.temperature,
      'stream': false,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 40));

    if (response.statusCode != 200) {
      throw 'Local Server HTTP ${response.statusCode}: ${response.body}';
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices != null && choices.isNotEmpty) {
      return choices.first['message']?['content'] as String? ?? '';
    }
    return 'Empty response from OpenJarvis local engine.';
  }
}
