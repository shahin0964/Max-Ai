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
  static const _kLocalServerUrl = 'local_server_url';
  static const _kActiveProvider = 'active_provider';
  static const _kActiveModelId = 'active_model_id';
  static const _kSystemPrompt = 'system_prompt';
  static const _kTemperature = 'temperature';
  static const _kTtsRate = 'tts_rate';

  String _geminiApiKey = '';
  String _claudeApiKey = '';
  String _openAiApiKey = '';
  String _localServerUrl = 'http://127.0.0.1:8000';
  AIProvider _activeProvider = AIProvider.gemini;
  String _activeModelId = 'gemini-2.5-flash';
  String _systemPrompt =
      'You are Max AI, an advanced, ultra-responsive autonomous AI assistant powered by the OpenJarvis framework. You provide clear, concise, highly intelligent answers and invoke tools proactively when needed.';
  double _temperature = 0.7;
  double _ttsRate = 0.55;

  String get geminiApiKey => _geminiApiKey;
  String get claudeApiKey => _claudeApiKey;
  String get openAiApiKey => _openAiApiKey;
  String get localServerUrl => _localServerUrl;
  AIProvider get activeProvider => _activeProvider;
  String get activeModelId => _activeModelId;
  String get systemPrompt => _systemPrompt;
  double get temperature => _temperature;
  double get ttsRate => _ttsRate;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _geminiApiKey = _prefs.getString(_kGeminiKey) ?? '';
    _claudeApiKey = _prefs.getString(_kClaudeKey) ?? '';
    _openAiApiKey = _prefs.getString(_kOpenAiKey) ?? '';
    _localServerUrl = _prefs.getString(_kLocalServerUrl) ?? 'http://127.0.0.1:8000';
    
    final provStr = _prefs.getString(_kActiveProvider);
    if (provStr != null) {
      _activeProvider = AIProvider.values.firstWhere(
        (p) => p.name == provStr,
        orElse: () => AIProvider.gemini,
      );
    }

    _activeModelId = _prefs.getString(_kActiveModelId) ?? 'gemini-2.5-flash';
    _systemPrompt = _prefs.getString(_kSystemPrompt) ?? _systemPrompt;
    _temperature = _prefs.getDouble(_kTemperature) ?? 0.7;
    _ttsRate = _prefs.getDouble(_kTtsRate) ?? 0.55;
    notifyListeners();
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

  Future<void> setLocalServerUrl(String url) async {
    _localServerUrl = url.trim();
    await _prefs.setString(_kLocalServerUrl, _localServerUrl);
    notifyListeners();
  }

  Future<void> setActiveProvider(AIProvider provider) async {
    _activeProvider = provider;
    await _prefs.setString(_kActiveProvider, provider.name);

    // Auto set appropriate default model for provider
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
}
