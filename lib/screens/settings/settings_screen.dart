import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _geminiController;
  late TextEditingController _claudeController;
  late TextEditingController _openAiController;
  late TextEditingController _localServerController;
  late TextEditingController _systemPromptController;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService.instance;
    _geminiController = TextEditingController(text: settings.geminiApiKey);
    _claudeController = TextEditingController(text: settings.claudeApiKey);
    _openAiController = TextEditingController(text: settings.openAiApiKey);
    _localServerController = TextEditingController(text: settings.localServerUrl);
    _systemPromptController = TextEditingController(text: settings.systemPrompt);
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _claudeController.dispose();
    _openAiController.dispose();
    _localServerController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _saveAll() async {
    final settings = SettingsService.instance;
    await settings.setGeminiApiKey(_geminiController.text);
    await settings.setClaudeApiKey(_claudeController.text);
    await settings.setOpenAiApiKey(_openAiController.text);
    await settings.setLocalServerUrl(_localServerController.text);
    await settings.setSystemPrompt(_systemPromptController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Configuration parameters stored successfully.'),
          backgroundColor: AppTheme.surfaceElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS & MODEL CONFIG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.cyan),
            onPressed: _saveAll,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. API Keys & Providers
              const Text(
                'AI COGNITIVE PROVIDERS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.cyan,
                ),
              ),
              const SizedBox(height: 8),

              GlassPanel(
                child: Column(
                  children: [
                    TextField(
                      controller: _geminiController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Google Gemini API Key',
                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.auto_awesome, size: 18, color: AppTheme.cyan),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _claudeController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Anthropic Claude API Key',
                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.psychology, size: 18, color: AppTheme.violet),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _openAiController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'OpenAI API Key',
                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.token, size: 18, color: AppTheme.emerald),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _localServerController,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'OpenJarvis / Ollama Local Server URL',
                        hintText: 'http://127.0.0.1:8000 or http://10.0.2.2:8000',
                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.memory, size: 18, color: AppTheme.amber),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. System Prompt
              const Text(
                'AGENT PERSONA & SYSTEM INSTRUCTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.cyan,
                ),
              ),
              const SizedBox(height: 8),

              GlassPanel(
                child: TextField(
                  controller: _systemPromptController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter custom system instructions...',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. Inference & Voice Sliders
              const Text(
                'HYPERPARAMETERS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.cyan,
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
                        const Text('Creativity (Temperature)', style: TextStyle(fontSize: 12)),
                        Text(settings.temperature.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.cyan)),
                      ],
                    ),
                    Slider(
                      value: settings.temperature,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: AppTheme.cyan,
                      onChanged: (val) {
                        settings.setTemperature(val);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Voice Speed (TTS Rate)', style: TextStyle(fontSize: 12)),
                        Text(settings.ttsRate.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.violet)),
                      ],
                    ),
                    Slider(
                      value: settings.ttsRate,
                      min: 0.3,
                      max: 1.0,
                      divisions: 14,
                      activeColor: AppTheme.violet,
                      onChanged: (val) {
                        settings.setTtsRate(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveAll,
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE SETTINGS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // About card
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Max AI • v1.0.0 (OpenJarvis Core)',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Package: com.max.ai',
                      style: TextStyle(fontSize: 10, color: AppTheme.cyan.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
