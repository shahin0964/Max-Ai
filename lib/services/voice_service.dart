import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'settings_service.dart';

enum VoiceState { idle, listening, thinking, speaking }

class VoiceService extends ChangeNotifier {
  static final VoiceService instance = VoiceService._internal();
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  VoiceState _state = VoiceState.idle;
  String _lastWords = '';
  bool _speechAvailable = false;

  VoiceState get state => _state;
  String get lastWords => _lastWords;
  bool get isListening => _state == VoiceState.listening;
  bool get isSpeaking => _state == VoiceState.speaking;

  Future<void> init() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (err) {
          debugPrint('STT Error: $err');
          setState(VoiceState.idle);
        },
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_state == VoiceState.listening) {
              setState(VoiceState.idle);
            }
          }
        },
      );

      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(SettingsService.instance.ttsRate);
      _tts.setCompletionHandler(() {
        setState(VoiceState.idle);
      });
      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        setState(VoiceState.idle);
      });
    } catch (e) {
      debugPrint('VoiceService initialization error: $e');
    }
  }

  void setState(VoiceState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> startListening({required Function(String text) onResult}) async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize();
      if (!_speechAvailable) return;
    }

    if (_state == VoiceState.speaking) {
      await stopSpeaking();
    }

    _lastWords = '';
    setState(VoiceState.listening);

    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        notifyListeners();
        if (result.finalResult) {
          onResult(_lastWords);
          setState(VoiceState.idle);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    setState(VoiceState.idle);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await stopListening();
    setState(VoiceState.speaking);
    await _tts.setSpeechRate(SettingsService.instance.ttsRate);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    setState(VoiceState.idle);
  }
}
