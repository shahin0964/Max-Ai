import 'package:flutter/material.dart';
import '../models/model_provider.dart';
import '../services/ai_engine_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';

class ModelSelectorSheet extends StatefulWidget {
  const ModelSelectorSheet({super.key});

  @override
  State<ModelSelectorSheet> createState() => _ModelSelectorSheetState();
}

class _ModelSelectorSheetState extends State<ModelSelectorSheet> {
  bool _isTesting = false;
  String? _testStatus;

  Future<void> _runPing(AIProvider provider) async {
    setState(() {
      _isTesting = true;
      _testStatus = 'Pinging ${provider.label}...';
    });

    final ok = await AIEngineService.instance.testConnection(provider);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testStatus = ok
            ? '✅ ${provider.label} is online and operational.'
            : '⚠️ ${provider.label} connection failed. Check API key / Server URL.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.surfaceGlassBorder, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI COGNITIVE ENGINE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.cyan,
                ),
              ),
              if (_testStatus != null)
                Expanded(
                  child: Text(
                    _testStatus!,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: _testStatus!.startsWith('✅')
                          ? AppTheme.emerald
                          : AppTheme.rose,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Provider Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AIProvider.values.map((prov) {
                final isSelected = settings.activeProvider == prov;
                Color chipColor = AppTheme.cyan;
                if (prov == AIProvider.claude) chipColor = AppTheme.violet;
                if (prov == AIProvider.openai) chipColor = AppTheme.emerald;
                if (prov == AIProvider.openjarvisLocal) chipColor = AppTheme.amber;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(prov.label),
                    selected: isSelected,
                    selectedColor: chipColor.withValues(alpha: 0.25),
                    backgroundColor: AppTheme.surface,
                    side: BorderSide(
                      color: isSelected ? chipColor : Colors.white12,
                      width: 1,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? chipColor : AppTheme.textSecondary,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        settings.setActiveProvider(prov);
                        setState(() {});
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'SELECT MODEL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          // Models List for current provider
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView(
              shrinkWrap: true,
              children: AIModelInfo.availableModels
                  .where((m) => m.provider == settings.activeProvider)
                  .map((model) {
                final isCurrent = settings.activeModelId == model.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    borderColor: isCurrent ? AppTheme.cyan : AppTheme.surfaceGlassBorder,
                    backgroundColor: isCurrent
                        ? AppTheme.cyan.withValues(alpha: 0.08)
                        : AppTheme.surface,
                    onTap: () {
                      settings.setActiveModelId(model.id);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(
                          isCurrent
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 18,
                          color: isCurrent ? AppTheme.cyan : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? AppTheme.cyan
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                model.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),
          // Test Connection Button
          Center(
            child: OutlinedButton.icon(
              onPressed: _isTesting ? null : () => _runPing(settings.activeProvider),
              icon: _isTesting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_ping, size: 16),
              label: Text(_isTesting ? 'Testing Link...' : 'Test Connection Ping'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.cyan,
                side: const BorderSide(color: AppTheme.cyan, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
