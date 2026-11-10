import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_provider.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  late SharedPreferences _prefs;

  // Keys
  static const _kGeminiKey = 'gemini_api_key';
  static const _kClaudeKey = 'claude_api_key';
  static const _kOpenAiKey = 'openai_api_key';
  static const _kElevenLabsKey = 'elevenlabs_api_key';
  static const _kVoiceId = 'voice_id';
  static const _kLocalServerUrl = 'local_server_url';
  static const _kActiveProvider = 'active_provider';
  static const _kActiveModelId = 'active_model_id';
  static const _kSystemPrompt = 'system_prompt';
  static const _kTemperature = 'temperature';
  static const _kTtsRate = 'tts_rate';

  // Persona & Gemini Voice keys
  static const _kGeminiVoiceName = 'gemini_voice_name';
  static const _kGeminiVoiceGender = 'gemini_voice_gender';
  static const _kAssistantName = 'assistant_name';
  static const _kAssistantPersonaTone = 'assistant_persona_tone';
  static const _kVoiceEngine = 'voice_engine';
  static const _kAssistantLanguage = 'assistant_language';
  static const _kSleepTimer = 'sleep_timer';
  static const _kCompanionMode = 'companion_mode';
  static const _kCompanionLevel = 'companion_level';
  static const _kMemoryAutoLearn = 'memory_auto_learn';
  static const _kCallAnnouncement = 'call_announcement';
  static const _kCallLoudspeaker = 'call_loudspeaker';
  static const _kDrivingMode = 'driving_mode';
  static const _kDrivingSmsText = 'driving_sms_text';

  // Router & Custom Providers keys
  static const _kRouterStrategy = 'router_strategy';
  static const _kCustomProvidersEnabled = 'custom_providers_enabled';
  static const _kCustomProvidersList = 'custom_providers_list';

  // Connectors keys
  static const _kConnectorsConfig = 'connectors_config';

  // Email SMTP keys
  static const _kSmtpEmail = 'smtp_email';
  static const _kSmtpPassword = 'smtp_password';
  static const _kSmtpSenderName = 'smtp_sender_name';
  static const _kSmtpSignature = 'smtp_signature';
  static const _kSmtpHost = 'smtp_host';
  static const _kSmtpPort = 'smtp_port';
  static const _kSmtpConfigured = 'smtp_configured';

  String _geminiApiKey = '';
  String _claudeApiKey = '';
  String _openAiApiKey = '';
  String _elevenLabsApiKey = '';
  String _voiceId = 'wDsJlOXPqcvIUKdLXjDs';
  String _localServerUrl = 'http://127.0.0.1:8000';
  AIProvider _activeProvider = AIProvider.gemini;
  String _activeModelId = 'gemini-3.8-flash';
  String _systemPrompt =
      'You are Max AI, an advanced, ultra-responsive autonomous AI assistant powered by the OpenJarvis framework. You provide clear, concise, highly intelligent answers and invoke tools proactively when needed.';
  double _temperature = 0.7;
  double _ttsRate = 0.55;

  // Persona & Voice fields
  String _geminiVoiceName = 'Kore';
  String _geminiVoiceGender = 'female';
  String _assistantName = 'Max AI';
  String _assistantPersonaTone = 'Max AI';
  String _voiceEngine = 'Normal Swift';
  String _assistantLanguage = 'Bengali + English (default)';
  String _sleepTimer = '10 min';
  bool _companionMode = false;
  String _companionLevel = 'Friendly';
  bool _memoryAutoLearn = true;
  bool _callAnnouncement = true;
  bool _callLoudspeaker = false;
  bool _drivingMode = false;
  String _drivingSmsText =
      'Max AI Auto-Reply: Shahin is currently driving and cannot attend your call right now. Will call back soon.';

  // Router & Custom Providers
  String _routerStrategy = 'ranked';
  bool _customProvidersEnabled = true;
  List<Map<String, dynamic>> _customProviders = [];

  // Connectors
  Map<String, Map<String, dynamic>> _connectorsConfig = {};

  // Email SMTP
  String _smtpEmail = 'user@gmail.com';
  String _smtpPassword = '';
  String _smtpSenderName = 'Shahin';
  String _smtpSignature = 'Sent via Max AI Autonomous Assistant';
  String _smtpHost = 'smtp.gmail.com';
  int _smtpPort = 465;
  bool _smtpConfigured = false;

  String get geminiApiKey => _geminiApiKey;
  String get claudeApiKey => _claudeApiKey;
  String get openAiApiKey => _openAiApiKey;
  String get elevenLabsApiKey => _elevenLabsApiKey;
  String get voiceId => _voiceId;
  String get localServerUrl => _localServerUrl;
  AIProvider get activeProvider => _activeProvider;
  String get activeModelId => _activeModelId;
  String get systemPrompt => _systemPrompt;
  double get temperature => _temperature;
  double get ttsRate => _ttsRate;

  // Persona Getters
  String get geminiVoiceName => _geminiVoiceName;
  String get geminiVoiceGender => _geminiVoiceGender;
  String get assistantName => _assistantName;
  String get assistantPersonaTone => _assistantPersonaTone;
  String get voiceEngine => _voiceEngine;
  String get assistantLanguage => _assistantLanguage;
  String get sleepTimer => _sleepTimer;
  bool get companionMode => _companionMode;
  String get companionLevel => _companionLevel;
  bool get memoryAutoLearn => _memoryAutoLearn;
  bool get callAnnouncement => _callAnnouncement;
  bool get callLoudspeaker => _callLoudspeaker;
  bool get drivingMode => _drivingMode;
  String get drivingSmsText => _drivingSmsText;

  // Router Getters
  String get routerStrategy => _routerStrategy;
  bool get customProvidersEnabled => _customProvidersEnabled;
  List<Map<String, dynamic>> get customProviders => _customProviders;

  // Connectors Getters
  Map<String, Map<String, dynamic>> get connectorsConfig => _connectorsConfig;

  // Email SMTP Getters
  String get smtpEmail => _smtpEmail;
  String get smtpPassword => _smtpPassword;
  String get smtpSenderName => _smtpSenderName;
  String get smtpSignature => _smtpSignature;
  String get smtpHost => _smtpHost;
  int get smtpPort => _smtpPort;
  bool get smtpConfigured => _smtpConfigured;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _geminiApiKey = _prefs.getString(_kGeminiKey) ?? '';
    _claudeApiKey = _prefs.getString(_kClaudeKey) ?? '';
    _openAiApiKey = _prefs.getString(_kOpenAiKey) ?? '';
    _elevenLabsApiKey = _prefs.getString(_kElevenLabsKey) ?? '';
    _voiceId = _prefs.getString(_kVoiceId) ?? 'wDsJlOXPqcvIUKdLXjDs';
    _localServerUrl = _prefs.getString(_kLocalServerUrl) ?? 'http://127.0.0.1:8000';
    
    final provStr = _prefs.getString(_kActiveProvider);
    if (provStr != null) {
      _activeProvider = AIProvider.values.firstWhere(
        (p) => p.name == provStr,
        orElse: () => AIProvider.gemini,
      );
    }

    _activeModelId = _prefs.getString(_kActiveModelId) ?? 'gemini-3.8-flash';
    // Auto-migrate legacy and deprecated model IDs to gemini-3.8-flash
    if (_activeModelId == 'gemini-2.0-flash' ||
        _activeModelId == 'gemini-2.5-flash' ||
        _activeModelId == 'gemini-2.5-pro' ||
        _activeModelId == 'gemini-3.8-pro' ||
        _activeModelId == 'gemini-2.5-flash-lite' ||
        _activeModelId == 'gemini-1.5-flash' ||
        _activeModelId == 'gemini-1.5-pro' ||
        _activeModelId == 'gemini-2.0-flash-lite') {
      _activeModelId = 'gemini-3.8-flash';
      await _prefs.setString(_kActiveModelId, _activeModelId);
    }
    _systemPrompt = _prefs.getString(_kSystemPrompt) ?? _systemPrompt;
    _temperature = _prefs.getDouble(_kTemperature) ?? 0.7;
    _ttsRate = _prefs.getDouble(_kTtsRate) ?? 0.55;

    // Load Persona & Gemini Voice
    _geminiVoiceName = _prefs.getString(_kGeminiVoiceName) ?? 'Kore';
    _geminiVoiceGender = _prefs.getString(_kGeminiVoiceGender) ?? 'female';
    _assistantName = _prefs.getString(_kAssistantName) ?? 'Max AI';
    _assistantPersonaTone = _prefs.getString(_kAssistantPersonaTone) ?? 'Max AI';
    _voiceEngine = _prefs.getString(_kVoiceEngine) ?? 'Normal Swift';
    _assistantLanguage = _prefs.getString(_kAssistantLanguage) ?? 'Bengali + English (default)';
    _sleepTimer = _prefs.getString(_kSleepTimer) ?? '10 min';
    _companionMode = _prefs.getBool(_kCompanionMode) ?? false;
    _companionLevel = _prefs.getString(_kCompanionLevel) ?? 'Friendly';
    _memoryAutoLearn = _prefs.getBool(_kMemoryAutoLearn) ?? true;
    _callAnnouncement = _prefs.getBool(_kCallAnnouncement) ?? true;
    _callLoudspeaker = _prefs.getBool(_kCallLoudspeaker) ?? false;
    _drivingMode = _prefs.getBool(_kDrivingMode) ?? false;
    _drivingSmsText = _prefs.getString(_kDrivingSmsText) ?? _drivingSmsText;

    // Load Router & Providers
    _routerStrategy = _prefs.getString(_kRouterStrategy) ?? 'ranked';
    _customProvidersEnabled = _prefs.getBool(_kCustomProvidersEnabled) ?? true;
    final providersRaw = _prefs.getString(_kCustomProvidersList);
    if (providersRaw != null && providersRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(providersRaw) as List;
        _customProviders = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _initDefaultProviders();
      }
    } else {
      _initDefaultProviders();
    }

    // Load Connectors
    final connRaw = _prefs.getString(_kConnectorsConfig);
    if (connRaw != null && connRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(connRaw) as Map<String, dynamic>;
        _connectorsConfig = decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
      } catch (_) {
        _connectorsConfig = {};
      }
    }

    // Load SMTP
    _smtpEmail = _prefs.getString(_kSmtpEmail) ?? 'user@gmail.com';
    _smtpPassword = _prefs.getString(_kSmtpPassword) ?? '';
    _smtpSenderName = _prefs.getString(_kSmtpSenderName) ?? 'Shahin';
    _smtpSignature = _prefs.getString(_kSmtpSignature) ?? 'Sent via Max AI Autonomous Assistant';
    _smtpHost = _prefs.getString(_kSmtpHost) ?? 'smtp.gmail.com';
    _smtpPort = _prefs.getInt(_kSmtpPort) ?? 465;
    _smtpConfigured = _prefs.getBool(_kSmtpConfigured) ?? false;

    notifyListeners();
  }

  void _initDefaultProviders() {
    _customProviders = [
      {
        'name': 'Gemini 3.8 Flash (Default Core)',
        'provider': 'Google AI Studio',
        'model': 'gemini-3.8-flash',
        'url': 'https://generativelanguage.googleapis.com',
        'apiKey': '',
        'enabled': true,
        'isDefault': true,
      },
      {
        'name': 'OpenJarvis Edge Node (Ollama)',
        'provider': 'Local Linux Daemon',
        'model': 'qwen2.5:7b',
        'url': 'http://127.0.0.1:11434/v1',
        'apiKey': '',
        'enabled': true,
        'isDefault': false,
      },
      {
        'name': 'Groq LPU Engine',
        'provider': 'Groq High-Speed',
        'model': 'llama-3.3-70b-versatile',
        'url': 'https://api.groq.com/openai/v1',
        'apiKey': '',
        'enabled': false,
        'isDefault': false,
      },
    ];
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key.trim();
    await _prefs.setString(_kGeminiKey, _geminiApiKey);
    notifyListeners();
  }

  Future<void> setClaudeApiKey(String key) async {
    _claudeApiKey = key.trim();
    await _prefs.setString(_kClaudeKey, _claudeApiKey);
    notifyListeners();
  }

  Future<void> setOpenAiApiKey(String key) async {
    _openAiApiKey = key.trim();
    await _prefs.setString(_kOpenAiKey, _openAiApiKey);
    notifyListeners();
  }

  Future<void> setElevenLabsApiKey(String key) async {
    _elevenLabsApiKey = key.trim();
    await _prefs.setString(_kElevenLabsKey, _elevenLabsApiKey);
    notifyListeners();
  }

  Future<void> setVoiceId(String id) async {
    _voiceId = id.trim();
    await _prefs.setString(_kVoiceId, _voiceId);
    notifyListeners();
  }

  Future<void> setLocalServerUrl(String url) async {
    _localServerUrl = url.trim();
    await _prefs.setString(_kLocalServerUrl, _localServerUrl);
    notifyListeners();
  }

  Future<void> setActiveProvider(AIProvider provider) async {
    _activeProvider = provider;
    await _prefs.setString(_kActiveProvider, provider.name);

    final models = AIModelInfo.availableModels.where((m) => m.provider == provider).toList();
    if (models.isNotEmpty) {
      _activeModelId = models.first.id;
      await _prefs.setString(_kActiveModelId, _activeModelId);
    }
    notifyListeners();
  }

  Future<void> setActiveModelId(String modelId) async {
    _activeModelId = modelId;
    await _prefs.setString(_kActiveModelId, modelId);
    notifyListeners();
  }

  Future<void> setSystemPrompt(String prompt) async {
    _systemPrompt = prompt;
    await _prefs.setString(_kSystemPrompt, prompt);
    notifyListeners();
  }

  Future<void> setTemperature(double temp) async {
    _temperature = temp;
    await _prefs.setDouble(_kTemperature, temp);
    notifyListeners();
  }

  Future<void> setTtsRate(double rate) async {
    _ttsRate = rate;
    await _prefs.setDouble(_kTtsRate, rate);
    notifyListeners();
  }

  // Persona Setters
  Future<void> setGeminiVoice(String voiceName, String gender) async {
    _geminiVoiceName = voiceName;
    _geminiVoiceGender = gender;
    await _prefs.setString(_kGeminiVoiceName, voiceName);
    await _prefs.setString(_kGeminiVoiceGender, gender);
    notifyListeners();
  }

  Future<void> setAssistantName(String name) async {
    _assistantName = name.trim();
    await _prefs.setString(_kAssistantName, _assistantName);
    notifyListeners();
  }

  Future<void> setAssistantPersonaTone(String tone) async {
    _assistantPersonaTone = tone;
    await _prefs.setString(_kAssistantPersonaTone, tone);
    notifyListeners();
  }

  Future<void> setVoiceEngine(String engine) async {
    _voiceEngine = engine;
    await _prefs.setString(_kVoiceEngine, engine);
    notifyListeners();
  }

  Future<void> setAssistantLanguage(String lang) async {
    _assistantLanguage = lang;
    await _prefs.setString(_kAssistantLanguage, lang);
    notifyListeners();
  }

  Future<void> setSleepTimer(String timer) async {
    _sleepTimer = timer;
    await _prefs.setString(_kSleepTimer, timer);
    notifyListeners();
  }

  Future<void> setCompanionMode(bool enabled) async {
    _companionMode = enabled;
    await _prefs.setBool(_kCompanionMode, enabled);
    notifyListeners();
  }

  Future<void> setCompanionLevel(String level) async {
    _companionLevel = level;
    await _prefs.setString(_kCompanionLevel, level);
    notifyListeners();
  }

  Future<void> setMemoryAutoLearn(bool val) async {
    _memoryAutoLearn = val;
    await _prefs.setBool(_kMemoryAutoLearn, val);
    notifyListeners();
  }

  Future<void> setCallAnnouncement(bool val) async {
    _callAnnouncement = val;
    await _prefs.setBool(_kCallAnnouncement, val);
    notifyListeners();
  }

  Future<void> setCallLoudspeaker(bool val) async {
    _callLoudspeaker = val;
    await _prefs.setBool(_kCallLoudspeaker, val);
    notifyListeners();
  }

  Future<void> setDrivingMode(bool val) async {
    _drivingMode = val;
    await _prefs.setBool(_kDrivingMode, val);
    notifyListeners();
  }

  Future<void> setDrivingSmsText(String text) async {
    _drivingSmsText = text;
    await _prefs.setString(_kDrivingSmsText, text);
    notifyListeners();
  }

  // Router & Custom Providers Setters
  Future<void> setRouterStrategy(String strategy) async {
    _routerStrategy = strategy;
    await _prefs.setString(_kRouterStrategy, strategy);
    notifyListeners();
  }

  Future<void> setCustomProvidersEnabled(bool val) async {
    _customProvidersEnabled = val;
    await _prefs.setBool(_kCustomProvidersEnabled, val);
    notifyListeners();
  }

  Future<void> addCustomProvider(Map<String, dynamic> provider) async {
    _customProviders.add(provider);
    await _prefs.setString(_kCustomProvidersList, jsonEncode(_customProviders));
    notifyListeners();
  }

  Future<void> removeCustomProvider(int index) async {
    if (index >= 0 && index < _customProviders.length) {
      _customProviders.removeAt(index);
      await _prefs.setString(_kCustomProvidersList, jsonEncode(_customProviders));
      notifyListeners();
    }
  }

  Future<void> toggleCustomProvider(int index, bool enabled) async {
    if (index >= 0 && index < _customProviders.length) {
      _customProviders[index]['enabled'] = enabled;
      await _prefs.setString(_kCustomProvidersList, jsonEncode(_customProviders));
      notifyListeners();
    }
  }

  // Connectors Setters
  Future<void> setConnectorToken(
    String id,
    String token, {
    String accountName = '',
    bool connected = true,
  }) async {
    _connectorsConfig[id] = {
      'token': token,
      'connected': connected,
      'accountName': accountName,
      'lastVerified': DateTime.now().toIso8601String(),
    };
    await _prefs.setString(_kConnectorsConfig, jsonEncode(_connectorsConfig));
    notifyListeners();
  }

  Future<void> disconnectConnector(String id) async {
    if (_connectorsConfig.containsKey(id)) {
      _connectorsConfig[id] = {
        'token': '',
        'connected': false,
        'accountName': '',
      };
      await _prefs.setString(_kConnectorsConfig, jsonEncode(_connectorsConfig));
      notifyListeners();
    }
  }

  // SMTP Settings
  Future<void> saveSmtpConfig({
    required String email,
    required String password,
    required String senderName,
    required String signature,
    required String host,
    required int port,
    required bool configured,
  }) async {
    _smtpEmail = email.trim();
    _smtpPassword = password.trim();
    _smtpSenderName = senderName.trim();
    _smtpSignature = signature.trim();
    _smtpHost = host.trim();
    _smtpPort = port;
    _smtpConfigured = configured;

    await _prefs.setString(_kSmtpEmail, _smtpEmail);
    await _prefs.setString(_kSmtpPassword, _smtpPassword);
    await _prefs.setString(_kSmtpSenderName, _smtpSenderName);
    await _prefs.setString(_kSmtpSignature, _smtpSignature);
    await _prefs.setString(_kSmtpHost, _smtpHost);
    await _prefs.setInt(_kSmtpPort, _smtpPort);
    await _prefs.setBool(_kSmtpConfigured, _smtpConfigured);
    notifyListeners();
  }
}
