import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/model_provider.dart';
import 'diagnostics_logger_service.dart';
import 'hardware_telemetry_service.dart';
import 'memory_service.dart';
import 'settings_service.dart';
import 'update_service.dart';

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

  Future<String> sendMessage({
    required String prompt,
    String? customSystemPrompt,
  }) async {
    final response = await generateResponse(
      history: [
        ChatMessage(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          content: prompt,
          role: MessageRole.user,
          timestamp: DateTime.now(),
        ),
      ],
      customSystemPrompt: customSystemPrompt,
    );
    return response.text;
  }

  Future<AIEngineResponse> generateResponse({
    required List<ChatMessage> history,
    String? customSystemPrompt,
  }) async {
    final settings = SettingsService.instance;
    final provider = settings.activeProvider;
    final modelId = settings.activeModelId;

    final stopwatch = Stopwatch()..start();

    // 1. Autonomous In-App Update Intent Handler
    final lastUserMsg = history.isNotEmpty
        ? history.reversed.firstWhere(
            (m) => m.role == MessageRole.user,
            orElse: () => history.last,
          )
        : null;
    final promptText = lastUserMsg?.content.trim() ?? '';
    final lowerPrompt = promptText.toLowerCase();

    final isUpdateIntent = lowerPrompt.contains('update') &&
        (lowerPrompt.contains('check') ||
         lowerPrompt.contains('asche') ||
         lowerPrompt.contains('ase') ||
         lowerPrompt.contains('ache') ||
         lowerPrompt.contains('koro') ||
         lowerPrompt.contains('notun') ||
         lowerPrompt.contains('app') ||
         lowerPrompt.contains('install') ||
         lowerPrompt == 'update' ||
         lowerPrompt == 'update check');

    if (isUpdateIntent) {
      final updateResult = await UpdateService.instance.autonomousCheckAndAutoUpdate();
      stopwatch.stop();
      return AIEngineResponse(
        text: '🔄 **Max AI সিস্টেম অটো-আপডেটার**:\n\n$updateResult',
        latencyMs: stopwatch.elapsedMilliseconds,
        model: 'update-engine',
        provider: 'System Auto-Updater',
      );
    }

    // 2. Full on-device telemetry and subsystems context injection
    final telemetry = HardwareTelemetryService.instance.currentData;
    final telemetryContext = '\n[LIVE ON-DEVICE TELEMETRY: Model: ${telemetry.deviceModel}, Android OS: ${telemetry.androidVersion}, Battery: ${telemetry.batteryLevel}%, RAM: ${(telemetry.availRamMb / 1024).toStringAsFixed(1)} GB free of ${(telemetry.totalRamMb / 1024).toStringAsFixed(1)} GB total]';
    final appContext = '\n[CONNECTED SUBSYSTEMS & CAPABILITIES: Max AI App Version: ${UpdateService.currentVersion}, GitHub In-App Auto-Updater: CONNECTED, Linux Terminal Runner: CONNECTED, Local AI Models Daemon: CONNECTED, Live Web Search: CONNECTED, SMTP Email Dispatch: ${settings.smtpConfigured ? "CONNECTED" : "AVAILABLE"}, Long-term Memory: CONNECTED. You have full autonomous access to all device systems. You are NOT an isolated AI; you are deeply integrated with this device and can inspect telemetry, run terminal commands, and check/install updates autonomously. Answer politely and naturally in Bengali or English.]';

    final systemPrompt = (customSystemPrompt ?? settings.systemPrompt) +
        telemetryContext +
        appContext +
        MemoryService.instance.buildPromptContext();

    try {
      String replyText = '';
      String effectiveModel = modelId;

      switch (provider) {
        case AIProvider.gemini:
          final geminiResult = await _callGeminiWithFailover(
            modelId,
            history,
            systemPrompt,
            settings.geminiApiKey,
          );
          replyText = geminiResult.replyText;
          effectiveModel = geminiResult.activeModel;
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
      HardwareTelemetryService.instance.updateLatency(latency, '$effectiveModel (${provider.label})');

      return AIEngineResponse(
        text: replyText,
        latencyMs: latency,
        model: effectiveModel,
        provider: provider.label,
      );
    } catch (e) {
      stopwatch.stop();
      DiagnosticsLoggerService.instance.logError(
        'ENGINE_ERROR',
        'Inference failed for $modelId (${provider.label})',
        e.toString(),
      );

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

  // Multimodal Visual Intelligence Scanner (Jarvis Vision)
  Future<String> analyzeImage({
    required List<int> imageBytes,
    required String mimeType,
    required String prompt,
  }) async {
    final settings = SettingsService.instance;
    final apiKey = settings.geminiApiKey;
    if (apiKey.isEmpty) {
      throw 'Gemini API key is not configured. Please set it in Settings.';
    }

    final base64Image = base64Encode(imageBytes);
    final model = 'gemini-3.8-flash';

    DiagnosticsLoggerService.instance.logInfo(
      'VISION_SCAN',
      'Sending visual payload (${(imageBytes.length / 1024).toStringAsFixed(1)} KB) to $model',
    );

    // 1. Try generateContent with inline_data
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

    final payload = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 2048,
      }
    };

    http.Response? response;
    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            DiagnosticsLoggerService.instance.logSuccess(
              'VISION_RESOLVED',
              'Vision analysis successfully produced response',
            );
            return parts.first['text'] as String? ?? 'No analysis generated.';
          }
        }
      }
    } catch (_) {}

    // 2. Try Interactions API fallback
    try {
      final interactionUrl = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/interactions?key=$apiKey');

      final interactionPayload = {
        'model': model,
        'input': [
          {
            'type': 'image',
            'data': base64Image,
            'mime_type': mimeType,
          },
          {
            'type': 'text',
            'text': prompt,
          }
        ]
      };

      final intResponse = await http.post(
        interactionUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(interactionPayload),
      ).timeout(const Duration(seconds: 40));

      if (intResponse.statusCode == 200) {
        final intJson = jsonDecode(intResponse.body) as Map<String, dynamic>;
        if (intJson.containsKey('output_text') && intJson['output_text'] != null) {
          return intJson['output_text'] as String;
        }
        final steps = intJson['steps'] as List<dynamic>?;
        if (steps != null) {
          for (final s in steps.reversed) {
            if (s['type'] == 'model_output' || s['type'] == 'agent_output') {
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
        }
      }
    } catch (_) {}

    final errBody = response != null ? response.body : 'Request timed out or failed';
    final errCode = response != null ? response.statusCode : 500;
    DiagnosticsLoggerService.instance.logError(
      'VISION_ERROR',
      'Failed to analyze: HTTP $errCode: $errBody',
    );
    throw 'Vision Analysis Error ($errCode): $errBody';
  }

  // 1. Google Gemini Smart Auto-Failover Engine (Ultra-Low Latency)
  Future<({String replyText, String activeModel})> _callGeminiWithFailover(
    String requestedModel,
    List<ChatMessage> history,
    String systemPrompt,
    String apiKey,
  ) async {
    if (apiKey.isEmpty) {
      throw 'Gemini API key is not configured. Please set it in Settings.';
    }

    // Sanitize requested model to exclude deprecated/broken models
    String baseModel = requestedModel.trim();
    if (baseModel.contains('2.5') ||
        baseModel.contains('1.5') ||
        baseModel.contains('2.0') ||
        baseModel.isEmpty) {
      baseModel = 'gemini-3.8-flash';
    }

    // Ordered failover candidates if a model is unavailable or overloaded (HTTP 503 / 404 / 429)
    final candidates = <String>{
      baseModel,
      'gemini-3.8-flash',
      'gemini-3.7-flash',
      'gemini-3.5-flash',
      'gemini-3.1-pro-preview',
    }.toList();

    String lastError = '';

    for (int i = 0; i < candidates.length; i++) {
      final currentModel = candidates[i];
      try {
        DiagnosticsLoggerService.instance.logInfo(
          'GEMINI_DISPATCH',
          'Dispatching query to $currentModel (candidate ${i + 1}/${candidates.length})',
        );

        final text = await _callGeminiSingle(currentModel, history, systemPrompt, apiKey);

        DiagnosticsLoggerService.instance.logSuccess(
          'GEMINI_RESOLVED',
          'Successfully received response from $currentModel',
        );

        return (replyText: text, activeModel: currentModel);
      } catch (e) {
        lastError = e.toString();
        DiagnosticsLoggerService.instance.logWarn(
          'GEMINI_RETRY',
          'Model $currentModel failed: $e. ${i + 1 < candidates.length ? 'Auto-healing failover triggered...' : 'All failover candidates exhausted.'}',
        );

        // Immediate failover for 404/400 (not found); short yield only if rate-limited
        if (i + 1 < candidates.length && lastError.contains('429')) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }

    DiagnosticsLoggerService.instance.logError(
      'GEMINI_EXHAUSTED',
      'All Gemini model candidates failed. Last error: $lastError',
    );
    throw lastError;
  }

  // Single Gemini Model Request (Direct High-Speed generateContent)
  Future<String> _callGeminiSingle(
    String model,
    List<ChatMessage> history,
    String systemPrompt,
    String apiKey,
  ) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

    final contents = <Map<String, dynamic>>[];
    final recent = history.length > 8 ? history.sublist(history.length - 8) : history;
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
    ).timeout(const Duration(seconds: 12));

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

    throw 'Gemini HTTP ${response.statusCode}: ${response.body}';
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
