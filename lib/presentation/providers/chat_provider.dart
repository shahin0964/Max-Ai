import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/gemini_api_service.dart';
import '../../data/services/offline_task_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/tool_registry_service.dart';

class TokenStats {
  final String model;
  final int inputTokens;
  final int outputTokens;
  final int cachedTokens;
  final int totalTokens;
  final double durationSeconds;

  TokenStats({
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.cachedTokens,
    required this.totalTokens,
    required this.durationSeconds,
  });
}

class ChatProvider extends ChangeNotifier {
  final OfflineTaskService _offlineTaskService = OfflineTaskService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final ToolRegistryService _toolRegistry = ToolRegistryService();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String _apiKey = '';
  static const String fixedModel = 'gemini-3.8-flash';
  String _userName = 'Md Shahin';
  String _userEmail = 'shahin@example.com';
  String _language = 'English';
  String _persona = 'Maya';
  String _themeMode = 'Dark';
  bool _wakeWordEnabled = true;
  bool _voiceGuardianEnabled = true;
  TokenStats? _lastTokenStats;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get apiKey => _apiKey;
  String get selectedModel => fixedModel;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get language => _language;
  String get persona => _persona;
  String get themeMode => _themeMode;
  bool get wakeWordEnabled => _wakeWordEnabled;
  bool get voiceGuardianEnabled => _voiceGuardianEnabled;
  TokenStats? get lastTokenStats => _lastTokenStats;

  ChatProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key') ?? '';
    _userName = prefs.getString('user_name') ?? 'Md Shahin';
    _userEmail = prefs.getString('user_email') ?? 'shahin@example.com';
    _language = prefs.getString('app_language') ?? 'English';
    _persona = prefs.getString('app_persona') ?? 'Maya';
    _themeMode = prefs.getString('app_theme_mode') ?? 'Dark';
    _wakeWordEnabled = prefs.getBool('wake_word_enabled') ?? true;
    _voiceGuardianEnabled = prefs.getBool('voice_guardian_enabled') ?? true;

    _isOnline = await _connectivityService.checkIsConnected();
    _connectivityService.onConnectivityChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
    });

    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    String greeting;
    if (_language == 'বাংলা') {
      greeting = 'স্বাগতম! আমি Max AI, Google Gemini 3.8 Flash দ্বারা চালিত। আমাকে কী করতে হবে বলুন!';
    } else if (_language == 'हिन्दी') {
      greeting = 'नमस्ते! मैं Max AI हूँ, Google Gemini 3.8 Flash से संचालित। बताइए मैं आपकी क्या मदद करूँ?';
    } else {
      greeting = 'Hello! I am Max AI, powered exclusively by Gemini 3.8 Flash. How can I assist you today?';
    }

    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: greeting,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        isOffline: !_isOnline,
      ),
    );
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKey);
    notifyListeners();
  }

  Future<void> setProfile(String name, String email) async {
    _userName = name.trim();
    _userEmail = email.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_email', _userEmail);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _language);
    notifyListeners();
  }

  Future<void> setPersona(String newPersona) async {
    _persona = newPersona;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_persona', _persona);
    notifyListeners();
  }

  Future<void> setThemeMode(String theme) async {
    _themeMode = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_mode', _themeMode);
    notifyListeners();
  }

  Future<void> toggleWakeWord(bool val) async {
    _wakeWordEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wake_word_enabled', _wakeWordEnabled);
    notifyListeners();
  }

  Future<void> toggleVoiceGuardian(bool val) async {
    _voiceGuardianEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_guardian_enabled', _voiceGuardianEnabled);
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  String _getDynamicSystemPrompt() {
    return '''
You are MAX AI (ম্যাক্স এআই), an extraordinarily capable on-device AI voice agent and autonomous assistant.
User's Name: $_userName.
Language: $_language.
Persona Style: $_persona.
Engine: Google Gemini 3.8 Flash.
Available Tools: All 19 registered automation tools (termux_run, whatsapp_send_message, whatsapp_read_chat, make_call, send_sms, open_app, tap_text, tap_coordinates, read_screen_text, swipe_screen, set_torch, set_volume, play_youtube, spotify_play, get_weather, web_search, save_memory, recall_memory, run_macro).
When user asks for actions or device manipulation, execute the appropriate tool function.
''';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      final textLower = text.trim().toLowerCase();

      // Offline command interceptors
      if (textLower.startsWith('termux ') || textLower.startsWith('bash ')) {
        final cmd = text.substring(text.indexOf(' ') + 1);
        final result = await _toolRegistry.executeTool('termux_run', {'command': cmd});
        _addReply(result, isOffline: true);
        return;
      }

      if (textLower.contains('torch on') || textLower.contains('flashlight on')) {
        final result = await _toolRegistry.executeTool('set_torch', {'enabled': true});
        _addReply(result, isOffline: true);
        return;
      }

      if (textLower.contains('torch off') || textLower.contains('flashlight off')) {
        final result = await _toolRegistry.executeTool('set_torch', {'enabled': false});
        _addReply(result, isOffline: true);
        return;
      }

      if (textLower.startsWith('run macro ') || textLower.startsWith('macro ')) {
        final macro = text.substring(text.indexOf(' ') + 1);
        final result = await _toolRegistry.executeTool('run_macro', {'macro_name': macro});
        _addReply(result, isOffline: true);
        return;
      }

      // Offline Mode
      if (!_isOnline) {
        final offlineReply = await _offlineTaskService.processOfflineInput(text);
        _addReply(offlineReply ?? 'Offline Mode: Action processed.', isOffline: true);
      } 
      // Online Mode: Gemini 3.8 Flash
      else {
        if (textLower.startsWith('add task ') || textLower.startsWith('task: ')) {
          final taskReply = await _offlineTaskService.processOfflineInput(text);
          _addReply(taskReply ?? 'Task added locally.', isOffline: true);
        } else {
          final geminiService = GeminiApiService(
            apiKey: _apiKey,
            model: fixedModel,
          );
          final response = await geminiService.sendMessage(
            prompt: text,
            history: _messages,
            systemPromptOverride: _getDynamicSystemPrompt(),
          );

          _lastTokenStats = TokenStats(
            model: fixedModel,
            inputTokens: response.inputTokens,
            outputTokens: response.outputTokens,
            cachedTokens: response.cachedTokens,
            totalTokens: response.inputTokens + response.outputTokens,
            durationSeconds: response.durationSeconds,
          );

          _addReply(response.text, isOffline: false);
        }
      }
    } catch (e) {
      final errStr = e.toString().replaceAll("Exception: ", "");
      String friendlyMsg = errStr;
      if (errStr.contains('503') || errStr.toLowerCase().contains('high demand')) {
        friendlyMsg = 'Gemini 3.8 Flash is experiencing high server demand right now. Spikes are temporary—please try again in a moment!';
      } else if (errStr.toLowerCase().contains('api key')) {
        friendlyMsg = 'Please verify and save your Gemini API Key in Settings.';
      }
      _messages.add(
        ChatMessage(
          id: _uuid.v4(),
          text: friendlyMsg,
          sender: MessageSender.system,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendVisionQuery(String base64Image, String prompt) async {
    _isLoading = true;
    notifyListeners();

    try {
      final geminiService = GeminiApiService(
        apiKey: _apiKey,
        model: fixedModel,
      );

      final result = await geminiService.analyzeImage(
        prompt: prompt,
        base64Image: base64Image,
      );

      _lastTokenStats = TokenStats(
        model: fixedModel,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        cachedTokens: 0,
        totalTokens: result.inputTokens + result.outputTokens,
        durationSeconds: result.durationSeconds,
      );

      _addReply('🖼️ [Vision Analysis Result]:\n\n${result.text}', isOffline: false);
    } catch (e) {
      _addReply('⚠️ Vision Error: ${e.toString().replaceAll("Exception: ", "")}', isOffline: false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addReply(String text, {required bool isOffline}) {
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: text,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        isOffline: isOffline,
      ),
    );
  }
}
