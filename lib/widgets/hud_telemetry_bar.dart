import 'package:flutter/material.dart';
import '../models/model_provider.dart';
import '../services/hardware_telemetry_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'model_selector_sheet.dart';

class HudTelemetryBar extends StatelessWidget {
  const HudTelemetryBar({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: providerColor.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: providerColor.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 1,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Model Selector Tap
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (ctx) => const ModelSelectorSheet(),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: providerColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(providerIcon, size: 14, color: providerColor),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          settings.activeModelId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          settings.activeProvider.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: providerColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.textMuted),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              Container(width: 1, height: 22, color: AppTheme.textMuted.withValues(alpha: 0.3)),
              const SizedBox(width: 12),

              // 2. Latency
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 13,
                    color: telemetry.lastLatencyMs > 0 ? AppTheme.emerald : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    telemetry.lastLatencyMs > 0 ? '${telemetry.lastLatencyMs}ms' : 'Ready',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: telemetry.lastLatencyMs > 0 ? AppTheme.emerald : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),
              Container(width: 1, height: 22, color: AppTheme.textMuted.withValues(alpha: 0.3)),
              const SizedBox(width: 12),

              // 3. Battery / RAM
              Row(
                children: [
                  Icon(
                    telemetry.batteryLevel > 20
                        ? Icons.battery_charging_full
                        : Icons.battery_alert,
                    size: 14,
                    color: telemetry.batteryLevel > 20 ? AppTheme.cyan : AppTheme.rose,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${telemetry.batteryLevel}%',
                    style: const TextStyle(
                      fontSize: 11,
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
