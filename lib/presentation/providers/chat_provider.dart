import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/gemini_api_service.dart';
import '../../data/services/offline_task_service.dart';
import '../../data/services/connectivity_service.dart';

class ChatProvider extends ChangeNotifier {
  final OfflineTaskService _offlineTaskService = OfflineTaskService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final _uuid = const Uuid();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String _apiKey = '';

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String get apiKey => _apiKey;

  ChatProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('gemini_api_key') ?? '';
    _isOnline = await _connectivityService.checkIsConnected();

    _connectivityService.onConnectivityChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
    });

    // Welcome message
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: 'Hello! I am Max AI, your hybrid personal assistant. '
              'I can work online with Gemini AI and offline for your local tasks.',
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
      // 1. If Offline: Use Offline Task Engine
      if (!_isOnline) {
        final offlineReply = await _offlineTaskService.processOfflineInput(text);
        _messages.add(
          ChatMessage(
            id: _uuid.v4(),
            text: offlineReply ?? 'Offline Mode: Task executed.',
            sender: MessageSender.assistant,
            timestamp: DateTime.now(),
            isOffline: true,
          ),
        );
      } 
      // 2. If Online: Check if user specifically gave an offline task command
      else {
        final textLower = text.trim().toLowerCase();
        if (textLower.startsWith('add task ') || textLower.startsWith('task: ')) {
          final taskReply = await _offlineTaskService.processOfflineInput(text);
          _messages.add(
            ChatMessage(
              id: _uuid.v4(),
              text: taskReply ?? 'Task added locally.',
              sender: MessageSender.assistant,
              timestamp: DateTime.now(),
              isOffline: true,
            ),
          );
        } else {
          // Send to Gemini Cloud
          final geminiService = GeminiApiService(apiKey: _apiKey);
          final reply = await geminiService.sendMessage(
            prompt: text,
            history: _messages,
          );

          _messages.add(
            ChatMessage(
              id: _uuid.v4(),
              text: reply,
              sender: MessageSender.assistant,
              timestamp: DateTime.now(),
              isOffline: false,
            ),
          );
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

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
