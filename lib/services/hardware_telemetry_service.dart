import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/telemetry_data.dart';

class HardwareTelemetryService extends ChangeNotifier {
  static final HardwareTelemetryService instance =
      HardwareTelemetryService._internal();
  HardwareTelemetryService._internal();

  static const _channel = MethodChannel('com.max.ai/system');

  TelemetryData _currentData = TelemetryData.initial();
  Timer? _pollingTimer;

  TelemetryData get currentData => _currentData;

  void init() {
    refreshTelemetry();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshTelemetry();
    });
  }

  Future<void> refreshTelemetry() async {
    int battery = _currentData.batteryLevel;
    int totalRam = _currentData.totalRamMb;
    int availRam = _currentData.availRamMb;
    bool isLow = false;
    String model = _currentData.deviceModel;
    String androidVer = _currentData.androidVersion;

    try {
      final int? b = await _channel.invokeMethod<int>('getBatteryLevel');
      if (b != null && b >= 0) battery = b;

      final mem = await _channel.invokeMapMethod<String, dynamic>('getMemoryInfo');
      if (mem != null) {
        totalRam = (mem['totalMemMb'] as num?)?.toInt() ?? totalRam;
        availRam = (mem['availMemMb'] as num?)?.toInt() ?? availRam;
        isLow = ((mem['isLowMem'] as num?)?.toInt() ?? 0) == 1;
      }

      final dev = await _channel.invokeMapMethod<String, dynamic>('getDeviceInfo');
      if (dev != null) {
        model = "${dev['brand'] ?? ''} ${dev['model'] ?? ''}".trim();
        androidVer = "Android ${dev['androidVersion'] ?? '14'} (API ${dev['sdkInt'] ?? 34})";
      }
    } catch (e) {
      // Fallback in dev/desktop environments
      debugPrint("Telemetry native channel exception: $e");
    }

    _currentData = TelemetryData(
      batteryLevel: battery,
      totalRamMb: totalRam,
      availRamMb: availRam,
      isLowMem: isLow,
      deviceModel: model.isEmpty ? 'Android Host' : model,
      androidVersion: androidVer,
      lastLatencyMs: _currentData.lastLatencyMs,
      activeBackend: _currentData.activeBackend,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void updateLatency(int ms, String backend) {
    _currentData = TelemetryData(
      batteryLevel: _currentData.batteryLevel,
      totalRamMb: _currentData.totalRamMb,
      availRamMb: _currentData.availRamMb,
      isLowMem: _currentData.isLowMem,
      deviceModel: _currentData.deviceModel,
      androidVersion: _currentData.androidVersion,
      lastLatencyMs: ms,
      activeBackend: backend,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
