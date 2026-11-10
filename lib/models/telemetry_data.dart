class TelemetryData {
  final int batteryLevel;
  final int totalRamMb;
  final int availRamMb;
  final bool isLowMem;
  final String deviceModel;
  final String androidVersion;
  final int lastLatencyMs;
  final String activeBackend;
  final DateTime lastUpdated;

  TelemetryData({
    required this.batteryLevel,
    required this.totalRamMb,
    required this.availRamMb,
    required this.isLowMem,
    required this.deviceModel,
    required this.androidVersion,
    required this.lastLatencyMs,
    required this.activeBackend,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  double get ramUsagePercent {
    if (totalRamMb <= 0) return 0.0;
    final used = totalRamMb - availRamMb;
    return (used / totalRamMb).clamp(0.0, 1.0);
  }

  factory TelemetryData.initial() => TelemetryData(
        batteryLevel: 85,
        totalRamMb: 6144,
        availRamMb: 2450,
        isLowMem: false,
        deviceModel: 'Android Device',
        androidVersion: 'Android 14',
        lastLatencyMs: 0,
        activeBackend: 'Gemini 2.5 Flash',
      );
}
