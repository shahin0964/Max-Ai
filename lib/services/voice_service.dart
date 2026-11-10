import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'settings_service.dart';

enum VoiceState { idle, listening, thinking, speaking }

class VoiceService extends ChangeNotifier {
  static final VoiceService instance = VoiceService._internal();
  VoiceService._internal();

  static const _channel = MethodChannel('com.max.ai/system');
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  VoiceState _state = VoiceState.idle;
  String _lastWords = '';
  bool _speechAvailable = false;
  int _speechSeq = 0;

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

      // Listen for native completion callback
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onAudioCompleted') {
          setState(VoiceState.idle);
        }
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
    final clean = text.trim();
    if (clean.isEmpty) return;

    final currentSeq = ++_speechSeq;
    await stopListening();
    setState(VoiceState.speaking);

    final settings = SettingsService.instance;
    final elevenKey = settings.elevenLabsApiKey.trim();
    final voiceId = settings.voiceId.trim();

    // 1. If ElevenLabs Key is configured, synthesize via high-fidelity Voice ID
    if (elevenKey.isNotEmpty && voiceId.isNotEmpty) {
      try {
        final audioFile = await _synthesizeElevenLabs(clean, voiceId, elevenKey);
        if (currentSeq != _speechSeq) return; // Interrupted

        if (audioFile != null && await audioFile.exists()) {
          final res = await _channel.invokeMethod<bool>('playAudioFile', {
            'path': audioFile.path,
          });
          if (res == true) return;
        }
      } catch (e) {
        debugPrint('ElevenLabs synthesis failed: $e, falling back to TTS');
      }
    }

    // 2. Fallback to System TTS Engine
    if (currentSeq == _speechSeq) {
      await _tts.setSpeechRate(settings.ttsRate);
      await _tts.speak(clean);
    }
  }

  Future<File?> _synthesizeElevenLabs(
    String text,
    String voiceId,
    String apiKey,
  ) async {
    final hash = md5.convert(utf8.encode('$voiceId:$text')).toString();
    final tempDir = await getTemporaryDirectory();
    final cacheFile = File('${tempDir.path}/eleven_$hash.mp3');

    if (await cacheFile.exists() && await cacheFile.length() > 100) {
      return cacheFile;
    }

    final url = Uri.parse(
        'https://api.elevenlabs.io/v1/text-to-speech/$voiceId?output_format=mp3_44100_128');

    final payload = {
      'text': text,
      'model_id': 'eleven_multilingual_v2',
      'voice_settings': {
        'stability': 0.5,
        'similarity_boost': 0.75,
        'style': 0.0,
        'use_speaker_boost': true,
      }
    };

    final res = await http.post(
      url,
      headers: {
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
        'Accept': 'audio/mpeg',
      },
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
      await cacheFile.writeAsBytes(res.bodyBytes);
      return cacheFile;
    } else {
      debugPrint('ElevenLabs error ${res.statusCode}: ${res.body}');
      return null;
    }
  }

  Future<void> stopSpeaking() async {
    _speechSeq++;
    try {
      await _channel.invokeMethod('stopAudio');
    } catch (_) {}
    await _tts.stop();
    setState(VoiceState.idle);
  }
}
