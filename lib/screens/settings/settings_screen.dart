import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/local_daemon_service.dart';
import '../../services/settings_service.dart';
import '../../services/voice_service.dart';
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
  late TextEditingController _elevenController;
  late TextEditingController _voiceIdController;
  late TextEditingController _localServerController;
  late TextEditingController _systemPromptController;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService.instance;
    _geminiController = TextEditingController(text: settings.geminiApiKey);
    _claudeController = TextEditingController(text: settings.claudeApiKey);
    _openAiController = TextEditingController(text: settings.openAiApiKey);
    _elevenController = TextEditingController(text: settings.elevenLabsApiKey);
    _voiceIdController = TextEditingController(text: settings.voiceId);
    _localServerController = TextEditingController(text: settings.localServerUrl);
    _systemPromptController = TextEditingController(text: settings.systemPrompt);
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _claudeController.dispose();
    _openAiController.dispose();
    _elevenController.dispose();
    _voiceIdController.dispose();
    _localServerController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _saveAll() async {
    final settings = SettingsService.instance;
    await settings.setGeminiApiKey(_geminiController.text);
    await settings.setClaudeApiKey(_claudeController.text);
    await settings.setOpenAiApiKey(_openAiController.text);
    await settings.setElevenLabsApiKey(_elevenController.text);
    await settings.setVoiceId(_voiceIdController.text);
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

  void _testVoice() {
    VoiceService.instance.speak(
      'Greetings! This is Max AI speaking with neural voice ID ${_voiceIdController.text}. Systems are fully operational.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('SETTINGS & CONFIG'),
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
                    const SizedBox(height: 10),
                    // In-App On-Device Local Daemon Controller
                    ListenableBuilder(
                      listenable: LocalDaemonService.instance,
                      builder: (context, _) {
                        final daemon = LocalDaemonService.instance;
                        final isRunning = daemon.isRunning;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isRunning
                                  ? AppTheme.emerald.withValues(alpha: 0.4)
                                  : AppTheme.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isRunning ? Icons.check_circle : Icons.pause_circle_outline,
                                    size: 16,
                                    color: isRunning ? AppTheme.emerald : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      isRunning
                                          ? 'On-Device Local AI Daemon: ACTIVE'
                                          : 'On-Device Local AI Daemon: STOPPED',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isRunning ? AppTheme.emerald : AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (isRunning) {
                                        await daemon.stopServer();
                                      } else {
                                        await daemon.startServer(port: 8000);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      isRunning ? 'STOP' : 'START',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isRunning ? Colors.redAccent : AppTheme.cyan,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Loopback: http://127.0.0.1:${daemon.port} • Model: ${daemon.activeModel}',
                                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      _localServerController.text = 'http://127.0.0.1:8000';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Configured to on-device loopback (http://127.0.0.1:8000)'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.link, size: 12),
                                    label: const Text('Use 127.0.0.1:8000', style: TextStyle(fontSize: 10)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.amber,
                                      side: BorderSide(color: AppTheme.amber.withValues(alpha: 0.5)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final url = _localServerController.text.trim();
                                      if (url.isEmpty) return;
                                      try {
                                        final pingUri = Uri.parse(url.endsWith('/') ? '${url}health' : '$url/health');
                                        final sw = Stopwatch()..start();
                                        final res = await http.get(pingUri).timeout(const Duration(seconds: 3));
                                        sw.stop();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(res.statusCode == 200
                                                  ? '✓ Local Daemon Healthy! Latency: ${sw.elapsedMilliseconds}ms'
                                                  : 'Response status: ${res.statusCode}'),
                                              backgroundColor: res.statusCode == 200 ? AppTheme.emerald : Colors.red,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Connection failed: $e'),
                                              backgroundColor: Colors.redAccent,
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.speed, size: 12),
                                    label: const Text('Test Ping', style: TextStyle(fontSize: 10)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.cyan,
                                      side: BorderSide(color: AppTheme.cyan.withValues(alpha: 0.5)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                                ],
                              ),
                              if (daemon.isDownloading) ...[
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: daemon.downloadProgress,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation(AppTheme.cyan),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  daemon.downloadStatusText,
                                  style: const TextStyle(fontSize: 10, color: AppTheme.cyan),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. High-Fidelity Voice Synthesis (ElevenLabs)
              const Text(
                'NEURAL VOICE SYNTHESIS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.violet,
                ),
              ),
              const SizedBox(height: 8),

              GlassPanel(
                borderColor: AppTheme.violet.withValues(alpha: 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _voiceIdController,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        labelText: 'Active Voice ID',
                        hintText: 'wDsJlOXPqcvIUKdLXjDs',
                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.record_voice_over, size: 18, color: AppTheme.violet),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _elevenController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'ElevenLabs API Key (Optional for Neural Voice)',
                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        prefixIcon: Icon(Icons.key, size: 18, color: AppTheme.violet),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _testVoice,
                        icon: const Icon(Icons.volume_up, size: 16),
                        label: const Text('Test Voice Output'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.violet,
                          side: const BorderSide(color: AppTheme.violet, width: 0.8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. System Prompt
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

              // 4. Sliders
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
                        const Text('Speech Speed (Rate)', style: TextStyle(fontSize: 12)),
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

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Max AI • v1.0.0 (OpenJarvis Core)',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Package: com.max.ai | Voice ID: ${settings.voiceId}',
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
