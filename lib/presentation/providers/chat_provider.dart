import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/gemini_api_service.dart';
import '../../data/services/offline_task_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/tool_registry_service.dart';

class ChatProvider extends ChangeNotifier {
  final OfflineTaskService _offlineTaskService = OfflineTaskService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final ToolRegistryService _toolRegistry = ToolRegistryService();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String _apiKey = '';
  String _selectedModel = 'gemini-3.8-flash';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get apiKey => _apiKey;
  String get selectedModel => _selectedModel;

  ChatProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key') ?? '';
    _selectedModel = prefs.getString('gemini_model') ?? 'gemini-3.8-flash';
    _isOnline = await _connectivityService.checkIsConnected();

    _connectivityService.onConnectivityChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
    });

    // Welcome message with 19 Tools active
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: 'Hello! I am Max AI, powered by $_selectedModel. '
              'Equipped with 19 automation tools (Termux, WhatsApp, Device Controls, Screen Automation, Memory & Macros).',
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

  Future<void> setModel(String model) async {
    _selectedModel = model.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_model', _selectedModel);
    notifyListeners();
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

      // Check if user gave an offline tool command
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

      // 1. If Offline: Use Offline Task Engine
      if (!_isOnline) {
        final offlineReply = await _offlineTaskService.processOfflineInput(text);
        _addReply(offlineReply ?? 'Offline Mode: Task executed.', isOffline: true);
      } 
      // 2. If Online: Query Gemini 3.8 Flash with full tools
      else {
        if (textLower.startsWith('add task ') || textLower.startsWith('task: ')) {
          final taskReply = await _offlineTaskService.processOfflineInput(text);
          _addReply(taskReply ?? 'Task added locally.', isOffline: true);
        } else {
          final geminiService = GeminiApiService(
            apiKey: _apiKey,
            model: _selectedModel,
          );
          final reply = await geminiService.sendMessage(
            prompt: text,
            history: _messages,
          );
          _addReply(reply, isOffline: false);
        }
      }
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: _uuid.v4(),
          text: 'Error: ${e.toString().replaceAll("Exception: ", "")}',
          sender: MessageSender.system,
          timestamp: DateTime.now(),
        ),
      );
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

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
