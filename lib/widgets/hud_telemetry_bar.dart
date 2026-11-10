import 'package:flutter/material.dart';
import '../models/model_provider.dart';
import '../services/hardware_telemetry_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'model_selector_sheet.dart';

class HudTelemetryBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const HudTelemetryBar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        SettingsService.instance,
        HardwareTelemetryService.instance,
      ]),
      builder: (context, _) {
        final settings = SettingsService.instance;
        final telemetry = HardwareTelemetryService.instance.currentData;

        // Provider styling
        Color providerColor = AppTheme.cyan;
        IconData providerIcon = Icons.bolt;

        switch (settings.activeProvider) {
          case AIProvider.gemini:
            providerColor = AppTheme.cyan;
            providerIcon = Icons.auto_awesome;
            break;
          case AIProvider.claude:
            providerColor = AppTheme.violet;
            providerIcon = Icons.psychology;
            break;
          case AIProvider.openai:
            providerColor = AppTheme.emerald;
            providerIcon = Icons.token;
            break;
          case AIProvider.openjarvisLocal:
            providerColor = AppTheme.amber;
            providerIcon = Icons.memory;
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: providerColor.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: providerColor.withValues(alpha: 0.08),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Model Selector Tap
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) => const ModelSelectorSheet(),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: providerColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(providerIcon, size: 12, color: providerColor),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              settings.activeModelId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              settings.activeProvider.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: providerColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: AppTheme.textMuted.withValues(alpha: 0.3)),
              const SizedBox(width: 8),

              // 2. Latency
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.speed,
                    size: 12,
                    color: telemetry.lastLatencyMs > 0 ? AppTheme.emerald : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    telemetry.lastLatencyMs > 0 ? '${telemetry.lastLatencyMs}ms' : 'Ready',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: telemetry.lastLatencyMs > 0 ? AppTheme.emerald : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: AppTheme.textMuted.withValues(alpha: 0.3)),
              const SizedBox(width: 8),

              // 3. Battery
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    telemetry.batteryLevel > 20
                        ? Icons.battery_charging_full
                        : Icons.battery_alert,
                    size: 13,
                    color: telemetry.batteryLevel > 20 ? AppTheme.cyan : AppTheme.rose,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${telemetry.batteryLevel}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
