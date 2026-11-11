import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AppUpdateInfo {
  final String tagName;
  final String name;
  final String releaseNotes;
  final String publishedAt;
  final String apkDownloadUrl;
  final String apkFileName;
  final int apkSizeBytes;
  final bool hasUpdate;

  const AppUpdateInfo({
    required this.tagName,
    required this.name,
    required this.releaseNotes,
    required this.publishedAt,
    required this.apkDownloadUrl,
    required this.apkFileName,
    required this.apkSizeBytes,
    required this.hasUpdate,
  });

  String get formattedSize {
    if (apkSizeBytes <= 0) return 'Unknown size';
    final mb = apkSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get sizeFormatted => formattedSize;
}

class UpdateService extends ChangeNotifier {
  static final UpdateService instance = UpdateService._internal();
  UpdateService._internal();

  static const String currentVersion = 'v1.0.23';
  static const String githubRepo = 'shahin0964/Max-Ai';
  static const MethodChannel _systemChannel = MethodChannel('com.max.ai/system');

  String get appVersion => currentVersion;
  String get currentVersion => UpdateService.currentVersion;

  bool _isChecking = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = 'System is ready.';
  AppUpdateInfo? _latestUpdate;

  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String get statusMessage => _statusMessage;
  AppUpdateInfo? get latestUpdate => _latestUpdate;

  /// Check GitHub releases for the latest published APK
  Future<AppUpdateInfo?> checkForUpdates() async {
    _isChecking = true;
    _statusMessage = 'Checking GitHub releases for latest Max AI build...';
    notifyListeners();

    try {
      final uri = Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest');
      final res = await http.get(
        uri,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        _isChecking = false;
        _statusMessage = 'GitHub release check returned status: ${res.statusCode}';
        notifyListeners();
        return null;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final releaseName = data['name'] as String? ?? 'Max AI Release';
      final body = data['body'] as String? ?? 'New release build with enhancements and fixes.';
      final publishedAt = data['published_at'] as String? ?? '';

      final assets = data['assets'] as List<dynamic>? ?? [];
      String apkUrl = '';
      String apkName = 'MaxAI-release-$tagName.apk';
      int apkSize = 0;

      for (final a in assets) {
        final name = a['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          apkName = name;
          apkUrl = a['browser_download_url'] as String? ?? '';
          apkSize = (a['size'] as num?)?.toInt() ?? 0;
          break;
        }
      }

      final hasUpdate = _isNewerVersion(tagName, currentVersion);

      _latestUpdate = AppUpdateInfo(
        tagName: tagName,
        name: releaseName,
        releaseNotes: body,
        publishedAt: publishedAt,
        apkDownloadUrl: apkUrl,
        apkFileName: apkName,
        apkSizeBytes: apkSize,
        hasUpdate: hasUpdate,
      );

      _isChecking = false;
      _statusMessage = hasUpdate
          ? 'New version $tagName is ready for installation!'
          : 'You are on the latest build ($currentVersion).';
      notifyListeners();
      return _latestUpdate;
    } catch (e) {
      _isChecking = false;
      _statusMessage = 'Update check error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Compare two version tags (e.g. v1.0.23 vs v1.0.22)
  bool _isNewerVersion(String latest, String current) {
    if (latest.isEmpty) return false;
    if (latest == current) return false;

    try {
      final cleanLatest = latest.replaceFirst(RegExp(r'^[vV]'), '');
      final cleanCurrent = current.replaceFirst(RegExp(r'^[vV]'), '');

      final latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return latestParts.length > currentParts.length;
    } catch (_) {
      return latest != current;
    }
  }

  /// Download the APK and trigger the native Android installer sheet
  Future<bool> downloadAndInstallUpdate(
    AppUpdateInfo update, {
    Function(double progress, String status)? onProgress,
  }) async {
    if (_isDownloading) return false;
    if (update.apkDownloadUrl.isEmpty) {
      _statusMessage = 'Error: No APK asset URL found for this release.';
      notifyListeners();
      return false;
    }

    _isDownloading = true;
    _downloadProgress = 0.0;
    _statusMessage = 'Starting download for ${update.apkFileName}...';
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final updatesDir = Directory('${dir.path}/updates');
      if (!await updatesDir.exists()) {
        await updatesDir.create(recursive: true);
      }

      final targetFile = File('${updatesDir.path}/${update.apkFileName}');

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(update.apkDownloadUrl));
      final response = await request.close();

      final totalBytes = response.contentLength;
      int receivedBytes = 0;

      final sink = targetFile.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _downloadProgress = receivedBytes / totalBytes;
          _statusMessage =
              '${(receivedBytes / (1024 * 1024)).toStringAsFixed(1)} MB / ${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB (${(_downloadProgress * 100).toStringAsFixed(0)}%)';
          onProgress?.call(_downloadProgress, _statusMessage);
          notifyListeners();
        }
      }
      await sink.flush();
      await sink.close();
      client.close();

      _downloadProgress = 1.0;
      _statusMessage = 'Download complete! Launching package installer...';
      notifyListeners();

      // Trigger Android native package installer
      final installed = await triggerNativeInstall(targetFile.path);
      _isDownloading = false;
      notifyListeners();
      return installed;
    } catch (e) {
      _isDownloading = false;
      _statusMessage = 'Download or install failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Invoke Android system package installer Intent via MethodChannel
  Future<bool> triggerNativeInstall(String apkFilePath) async {
    try {
      final res = await _systemChannel.invokeMethod('installApk', {'filePath': apkFilePath});
      return res == true;
    } catch (e) {
      debugPrint('Native installApk error: $e');
      return false;
    }
  }

  /// Autonomous AI update handler: checks and installs in one go
  Future<String> autonomousCheckAndAutoUpdate() async {
    final update = await checkForUpdates();
    if (update == null) {
      return 'Could not reach GitHub update server. Please verify your internet connection.';
    }

    if (!update.hasUpdate) {
      return 'Your Max AI app is currently up to date (Version: $currentVersion). No new release is available.';
    }

    // Has update -> Trigger background download and installer
    final success = await downloadAndInstallUpdate(update);
    if (success) {
      return '✓ New version ${update.tagName} was downloaded successfully! The Android package installer modal has been triggered. Please tap "Install" on your screen to complete the update.';
    } else {
      return 'Found update ${update.tagName}, but failed to complete the installation automatically: $_statusMessage. You can also open the Update screen from the slidebar to install manually.';
    }
  }
}
