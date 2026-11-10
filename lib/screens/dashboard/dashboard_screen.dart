import 'package:flutter/material.dart';
import '../../services/ai_engine_service.dart';
import '../../services/hardware_telemetry_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENGINE & HARDWARE TELEMETRY'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: ListenableBuilder(
            listenable: Listenable.merge([
              HardwareTelemetryService.instance,
              SettingsService.instance,
            ]),
            builder: (context, _) {
              final telemetry = HardwareTelemetryService.instance.currentData;
              final settings = SettingsService.instance;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Engine Status Glass Panel
                  GlassPanel(
                    borderColor: AppTheme.cyan.withValues(alpha: 0.4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.speed, size: 18, color: AppTheme.cyan),
                                SizedBox(width: 8),
                                Text(
                                  'ACTIVE COGNITIVE BACKEND',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AppTheme.cyan,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.emerald.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.emerald, width: 0.8),
                              ),
                              child: const Text(
                                'ONLINE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.emerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          settings.activeModelId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Provider: ${settings.activeProvider.label}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildMiniMetric(
                              'LATENCY',
                              telemetry.lastLatencyMs > 0
                                  ? '${telemetry.lastLatencyMs} ms'
                                  : '--',
                              AppTheme.cyan,
                            ),
                            const SizedBox(width: 12),
                            _buildMiniMetric(
                              'ENDPOINT',
                              settings.activeProvider.id == 'openjarvis_local'
                                  ? settings.localServerUrl
                                  : 'Cloud SSL Direct',
                              AppTheme.violet,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Hardware RAM & Memory
                  const Text(
                    'ON-DEVICE SYSTEM MEMORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RAM Usage: ${(telemetry.ramUsagePercent * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${((telemetry.totalRamMb - telemetry.availRamMb) / 1024).toStringAsFixed(1)} GB / ${(telemetry.totalRamMb / 1024).toStringAsFixed(1)} GB',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: telemetry.ramUsagePercent,
                            minHeight: 8,
                            backgroundColor: AppTheme.surfaceElevated,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              telemetry.ramUsagePercent > 0.85
                                  ? AppTheme.rose
                                  : AppTheme.cyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Free Memory: ${(telemetry.availRamMb / 1024).toStringAsFixed(2)} GB',
                              style: const TextStyle(fontSize: 12, color: AppTheme.emerald),
                            ),
                            if (telemetry.isLowMem)
                              const Text(
                                '⚠️ Low RAM Alert',
                                style: TextStyle(fontSize: 12, color: AppTheme.rose),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Device Specs & Battery
                  const Text(
                    'PHYSICAL HARDWARE SPECS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  GlassPanel(
                    child: Column(
                      children: [
                        _buildHardwareRow('Device Model', telemetry.deviceModel),
                        const Divider(height: 16),
                        _buildHardwareRow('Operating System', telemetry.androidVersion),
                        const Divider(height: 16),
                        _buildHardwareRow('Battery Level', '${telemetry.batteryLevel}%'),
                        const Divider(height: 16),
                        _buildHardwareRow('Architecture', 'arm64-v8a / OpenJarvis Core'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Manual Refresh Button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HardwareTelemetryService.instance.refreshTelemetry();
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh Diagnostics'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.cyan,
                        side: const BorderSide(color: AppTheme.cyan, width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
