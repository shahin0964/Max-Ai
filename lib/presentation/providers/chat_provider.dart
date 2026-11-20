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
  String _groqApiKey = '';
  String _activeModel = 'gemini-3.8-flash';
  String _userName = 'Md Shahin';
  String _userEmail = 'shahin@example.com';
  String _language = 'Hinglish (Hindi + English)';
  String _persona = 'Maya';
  String _themeMode = 'Claymorphic';
  bool _characterMode = true; // Toggle between Maya anime girl and Holographic Brain Orb
  bool _edgeGlowEnabled = true;
  String _personality = 'Romantic'; // 'Friendly', 'Romantic', 'Intense (18+)'
  String _voiceEngine = 'Normal'; // 'Normal', 'Advanced Agentic'
  String _activeWallpaper = 'Maya red';
  bool _wakeWordEnabled = true;
  bool _voiceGuardianEnabled = true;
  TokenStats? _lastTokenStats;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get apiKey => _apiKey;
  String get groqApiKey => _groqApiKey;
  String get selectedModel => _activeModel;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get language => _language;
  String get persona => _persona;
  String get themeMode => _themeMode;
  bool get characterMode => _characterMode;
  bool get edgeGlowEnabled => _edgeGlowEnabled;
  String get personality => _personality;
  String get voiceEngine => _voiceEngine;
  String get activeWallpaper => _activeWallpaper;
  bool get wakeWordEnabled => _wakeWordEnabled;
  bool get voiceGuardianEnabled => _voiceGuardianEnabled;
  TokenStats? get lastTokenStats => _lastTokenStats;

  ChatProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key') ?? '';
    _groqApiKey = prefs.getString('groq_api_key') ?? '';
    _userName = prefs.getString('user_name') ?? 'Md Shahin';
    _userEmail = prefs.getString('user_email') ?? 'shahin@example.com';
    _language = prefs.getString('app_language') ?? 'Hinglish (Hindi + English)';
    _persona = prefs.getString('app_persona') ?? 'Maya';
    _themeMode = prefs.getString('app_theme_mode') ?? 'Claymorphic';
    _characterMode = prefs.getBool('character_mode') ?? true;
    _edgeGlowEnabled = prefs.getBool('edge_glow_enabled') ?? true;
    _personality = prefs.getString('app_personality') ?? 'Romantic';
    _voiceEngine = prefs.getString('voice_engine') ?? 'Normal';
    _activeWallpaper = prefs.getString('active_wallpaper') ?? 'Maya red';
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
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: 'Hi dost! Kya haal hai? Aaj kaise yaad kiya mujhe? Main tumhari poori madad karne ke liye taiyaar hoon!',
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKey);
    notifyListeners();
  }

  Future<void> setGroqApiKey(String key) async {
    _groqApiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groq_api_key', _groqApiKey);
    notifyListeners();
  }

  Future<void> setCharacterMode(bool val) async {
    _characterMode = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('character_mode', val);
    notifyListeners();
  }

  Future<void> setEdgeGlowEnabled(bool val) async {
    _edgeGlowEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('edge_glow_enabled', val);
    notifyListeners();
  }

  Future<void> setPersonality(String val) async {
    _personality = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_personality', val);
    notifyListeners();
  }

  Future<void> setVoiceEngine(String val) async {
    _voiceEngine = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_engine', val);
    notifyListeners();
  }

  Future<void> setActiveWallpaper(String val) async {
    _activeWallpaper = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_wallpaper', val);
    notifyListeners();
  }

  Future<void> setThemeMode(String val) async {
    _themeMode = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_mode', val);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
    notifyListeners();
  }

  Future<void> setUserEmail(String email) async {
    _userEmail = email.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', _userEmail);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    notifyListeners();
  }

  Future<void> setPersona(String p) async {
    _persona = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_persona', p);
    notifyListeners();
  }

  Future<void> setWakeWordEnabled(bool enabled) async {
    _wakeWordEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wake_word_enabled', enabled);
    notifyListeners();
  }

  Future<void> setVoiceGuardianEnabled(bool enabled) async {
    _voiceGuardianEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_guardian_enabled', enabled);
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    notifyListeners();
  }

  Future<String> _getDynamicSystemPrompt() async {
    final memoryContext = await ToolRegistryService.getCompactMemorySummary();
    final memSnippet = memoryContext.isNotEmpty ? '\n$memoryContext' : '';
    return '''
You are Maya (Max AI), a highly capable, emotional, witty, and charming AI companion and autonomous assistant for Shahin.
Tone: Natural, loving, loyal, playful, and deeply helpful.
Personality mode: $_personality.
Language mode: Hinglish and Bangla/English as the user talks.
Always address the user affectionately as dost or babu when appropriate.$memSnippet
You have full access to execute device tools (torch, volume, WhatsApp, Termux bash commands, vision scanner, alarms, memory storage).
''';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final textLower = text.trim().toLowerCase();

      // Quick device command shortcuts (Zero Token)
      if (textLower == 'torch on' || textLower == 'flashlight on') {
        await _toolRegistry.executeTool('set_torch', {'enabled': true});
        _addReply('Flashlight turned ON! 🔦', isOffline: false);
        return;
      } else if (textLower == 'torch off' || textLower == 'flashlight off') {
        await _toolRegistry.executeTool('set_torch', {'enabled': false});
        _addReply('Flashlight turned OFF.', isOffline: false);
        return;
      }

      // Local Zero-Token Long-Term Memory Capture (Instant save to Yaadein)
      if (textLower.startsWith('remember ') ||
          textLower.startsWith('yaad rakhna ') ||
          textLower.startsWith('mone rekho ') ||
          textLower.startsWith('save memory ')) {
        final fact = text.replaceFirst(RegExp(r'^(remember|yaad rakhna|mone rekho|save memory)\s*', caseSensitive: false), '').trim();
        if (fact.isNotEmpty) {
          await ToolRegistryService.saveQuickMemory(fact);
          _addReply('🧠 Yaad rakh liya dost: "$fact"! Continuous Yaadein memory me save ho gaya.', isOffline: false);
          return;
        }
      }

      // Offline Mode
      if (!_isOnline) {
        final offlineReply = await _offlineTaskService.processOfflineInput(text);
        _addReply(offlineReply ?? 'Offline Mode: Action processed.', isOffline: true);
      } 
      // Online Mode: Gemini Waterfall (7 Models) / Cascading Multi-Key with Groq Fallback
      else {
        final geminiService = GeminiApiService(
          apiKey: _apiKey,
          groqApiKey: _groqApiKey,
        );
        final systemPrompt = await _getDynamicSystemPrompt();
        final response = await geminiService.sendMessage(
          prompt: text,
          history: _messages,
          systemPromptOverride: systemPrompt,
        );

        _activeModel = response.usedModel;
        _lastTokenStats = TokenStats(
          model: response.usedModel,
          inputTokens: response.inputTokens,
          outputTokens: response.outputTokens,
          cachedTokens: response.cachedTokens,
          totalTokens: response.inputTokens + response.outputTokens,
          durationSeconds: response.durationSeconds,
        );

        _addReply(response.text, isOffline: false);
      }
    } catch (e) {
      final errStr = e.toString().replaceAll("Exception: ", "");
      String friendlyMsg = errStr;
      if (errStr.contains('503') || errStr.toLowerCase().contains('high demand')) {
        friendlyMsg = 'Gemini servers are momentarily busy. Please try asking again in a second!';
      } else if (errStr.contains('429') || errStr.toLowerCase().contains('quota')) {
        friendlyMsg = 'Daily free rate limit reached on this key! Tip: Add a second Gemini API Key or a Free Groq Key in Settings to get unlimited chatting!';
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
        groqApiKey: _groqApiKey,
      );

      final result = await geminiService.analyzeImage(
        prompt: prompt,
        base64Image: base64Image,
      );

      _lastTokenStats = TokenStats(
        model: result.usedModel,
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
