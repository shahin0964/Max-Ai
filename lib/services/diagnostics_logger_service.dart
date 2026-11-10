import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

enum LogLevel { info, warn, error, success }

class DiagnosticLogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final String? details;

  DiagnosticLogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.details,
  });

  String toFormattedString() {
    final timeStr = timestamp.toIso8601String().substring(11, 19);
    final lvl = level.name.toUpperCase().padRight(7);
    final det = details != null && details!.isNotEmpty ? '\n       Details: $details' : '';
    return '[$timeStr] [$lvl] [$tag] $message$det';
  }
}

class DiagnosticsLoggerService extends ChangeNotifier {
  static final DiagnosticsLoggerService instance = DiagnosticsLoggerService._internal();
  DiagnosticsLoggerService._internal();

  final List<DiagnosticLogEntry> _logs = [];
  File? _primaryLogFile;
  File? _fallbackLogFile;
  bool _initialized = false;

  List<DiagnosticLogEntry> get logs => List.unmodifiable(_logs);

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Primary path in Download directory so Termux agent can read directly:
      // /storage/emulated/0/Download/max_ai_diagnostics.log
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        _primaryLogFile = File('${downloadDir.path}/max_ai_diagnostics.log');
      }
    } catch (_) {}

    try {
      final appDir = await getApplicationDocumentsDirectory();
      _fallbackLogFile = File('${appDir.path}/max_ai_diagnostics.log');
    } catch (_) {}

    final header = '\n========================================\n'
        '  MAX AI LIVE DIAGNOSTICS & BUG MONITOR\n'
        '  Started: ${DateTime.now().toIso8601String()}\n'
        '========================================\n';

    await _writeToFile(header);
    logInfo('SYSTEM', 'Diagnostics monitor initialized successfully');
  }

  void log(LogLevel level, String tag, String message, [String? details]) {
    final entry = DiagnosticLogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      details: details,
    );

    _logs.add(entry);
    if (_logs.length > 500) {
      _logs.removeAt(0);
    }

    notifyListeners();

    // Persist asynchronously
    _writeToFile('${entry.toFormattedString()}\n');
  }

  void logInfo(String tag, String message, [String? details]) =>
      log(LogLevel.info, tag, message, details);

  void logWarn(String tag, String message, [String? details]) =>
      log(LogLevel.warn, tag, message, details);

  void logError(String tag, String message, [String? details]) =>
      log(LogLevel.error, tag, message, details);

  void logSuccess(String tag, String message, [String? details]) =>
      log(LogLevel.success, tag, message, details);

  Future<void> _writeToFile(String text) async {
    try {
      if (_primaryLogFile != null) {
        await _primaryLogFile!.writeAsString(text, mode: FileMode.append, flush: true);
      }
    } catch (_) {}

    try {
      if (_fallbackLogFile != null) {
        await _fallbackLogFile!.writeAsString(text, mode: FileMode.append, flush: true);
      }
    } catch (_) {}
  }

  Future<String> dumpFullLogs() async {
    final buffer = StringBuffer();
    buffer.writeln('=== MAX AI FULL DIAGNOSTIC LOG DUMP ===');
    buffer.writeln('Generated at: ${DateTime.now()}');
    buffer.writeln('Total entries: ${_logs.length}');
    buffer.writeln('----------------------------------------');
    for (final e in _logs) {
      buffer.writeln(e.toFormattedString());
    }
    buffer.writeln('----------------------------------------');

    final content = buffer.toString();
    await _writeToFile(content);
    return content;
  }

  Future<void> clearLogs() async {
    _logs.clear();
    notifyListeners();
    try {
      if (_primaryLogFile != null && await _primaryLogFile!.exists()) {
        await _primaryLogFile!.writeAsString('=== LOGS CLEARED ===\n');
      }
      if (_fallbackLogFile != null && await _fallbackLogFile!.exists()) {
        await _fallbackLogFile!.writeAsString('=== LOGS CLEARED ===\n');
      }
    } catch (_) {}
  }

  Future<String?> exportLogsToDownloads() async {
    try {
      final dump = await dumpFullLogs();
      const path = '/storage/emulated/0/Download/max_ai_diagnostics.log';
      final file = File(path);
      await file.writeAsString(dump);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
