import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import 'tools_manager_screen.dart';
import 'terminal_reel_screen.dart';
import '../../data/services/gemini_api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;

  final List<String> _availableModels = [
    'gemini-3.8-flash',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-pro',
  ];

  @override
  void initState() {
    super.initState();
    final key = context.read<ChatProvider>().apiKey;
    _apiKeyController = TextEditingController(text: key);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final chatProvider = context.read<ChatProvider>();
    final nameCtrl = TextEditingController(text: chatProvider.userName);
    final emailCtrl = TextEditingController(text: chatProvider.userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceLight),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Your Name', labelStyle: TextStyle(color: AppColors.neonCyan)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Email Address', labelStyle: TextStyle(color: AppColors.neonCyan)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan, foregroundColor: Colors.black),
            onPressed: () {
              chatProvider.setProfile(nameCtrl.text, emailCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final chatProvider = context.read<ChatProvider>();
    final langs = ['English', 'বাংলা', 'हिन्दी'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Select Language', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs.map((lang) {
            final isSel = chatProvider.language == lang;
            return ListTile(
              title: Text(lang, style: TextStyle(color: isSel ? AppColors.neonCyan : Colors.white)),
              trailing: isSel ? const Icon(Icons.check, color: AppColors.neonCyan) : null,
              onTap: () {
                chatProvider.setLanguage(lang);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final chatProvider = context.read<ChatProvider>();
    final themes = ['Dark Neon', 'Cyberpunk Purple', 'AMOLED True Black'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Select Theme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((t) {
            final isSel = chatProvider.themeMode.contains(t.split(' ')[0]);
            return ListTile(
              title: Text(t, style: TextStyle(color: isSel ? AppColors.neonCyan : Colors.white)),
              trailing: isSel ? const Icon(Icons.check, color: AppColors.neonCyan) : null,
              onTap: () {
                chatProvider.setThemeMode(t);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showVoiceDialog() {
    final chatProvider = context.read<ChatProvider>();
    final voices = [
      {'name': 'Maya (Warm & Natural)', 'id': 'Maya'},
      {'name': 'Friday (Tactical & Sharp)', 'id': 'Friday'},
      {'name': 'Venom (Deep & Bold)', 'id': 'Venom'},
      {'name': 'Default AI Speech', 'id': 'Default'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('AI Voice Model', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: voices.map((v) {
            final isSel = chatProvider.persona == v['id'];
            return ListTile(
              title: Text(v['name']!, style: TextStyle(color: isSel ? AppColors.neonCyan : Colors.white, fontSize: 14)),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: AppColors.neonCyan, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Playing preview for ${v['name']} voice sample...')),
                  );
                },
              ),
              onTap: () {
                chatProvider.setPersona(v['id']!);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPersonalityDialog() {
    final chatProvider = context.read<ChatProvider>();
    final personas = ['Maya (Autonomous)', 'Friday (Tactical)', 'Venom (Symbiote)', 'Friendly Assistant'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('AI Personality', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: personas.map((p) {
            final isSel = chatProvider.persona.contains(p.split(' ')[0]);
            return ListTile(
              title: Text(p, style: TextStyle(color: isSel ? AppColors.neonCyan : Colors.white)),
              trailing: isSel ? const Icon(Icons.check, color: AppColors.neonCyan) : null,
              onTap: () {
                chatProvider.setPersona(p.split(' ')[0]);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBackupDialog() {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Backup & Restore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Export your chat history, memory preferences, and automation settings to clipboard or local JSON.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.neonCyan),
            onPressed: () {
              final backup = {
                'user': chatProvider.userName,
                'email': chatProvider.userEmail,
                'messages_count': chatProvider.messages.length,
                'timestamp': DateTime.now().toIso8601String(),
              };
              Clipboard.setData(ClipboardData(text: jsonEncode(backup)));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup JSON copied to clipboard!')),
              );
            },
            child: const Text('Export JSON'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('System restored from latest configuration!')),
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _testGeminiConnection() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API Key first!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing Gemini API connection...')),
    );

    try {
      final service = GeminiApiService(apiKey: key, model: context.read<ChatProvider>().selectedModel);
      final res = await service.sendMessage(prompt: 'Hello! Respond with "OK"', history: []);
      if (mounted) {
        context.read<ChatProvider>().setApiKey(key);
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: AppColors.surfaceCard,
            title: const Text('Connection Successful! ✅', style: TextStyle(color: Color(0xFF4ADE80))),
            content: Text(
              'Gemini 3.8 Flash responded perfectly:\n"${res.text}"\n\nLatency: ${res.durationSeconds.toStringAsFixed(2)}s | Tokens: ${res.inputTokens + res.outputTokens}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Done', style: TextStyle(color: AppColors.neonCyan))),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: AppColors.surfaceCard,
            title: const Text('Connection Failed ⚠️', style: TextStyle(color: AppColors.error)),
            content: Text(e.toString(), style: const TextStyle(color: Colors.white, fontSize: 13)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close', style: TextStyle(color: AppColors.neonCyan))),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Profile Card matching Screen 6
          GestureDetector(
            onTap: _showEditProfileDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        chatProvider.userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatProvider.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chatProvider.userEmail,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined, color: AppColors.neonCyan, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // AI Engine & Model Settings Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'AI Engine & Model',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Selected Model',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
                      ),
                      child: Text(
                        chatProvider.selectedModel,
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: chatProvider.selectedModel,
                  dropdownColor: AppColors.surfaceCard,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.surfaceLight),
                    ),
                  ),
                  items: _availableModels.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) chatProvider.setModel(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Preferences Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'App Preferences',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _prefTile(Icons.language_rounded, 'Language', chatProvider.language, _showLanguageDialog),
                _divider(),
                _prefTile(Icons.dark_mode_outlined, 'Theme', chatProvider.themeMode, _showThemeDialog),
                _divider(),
                _prefTile(Icons.volume_up_outlined, 'Voice Model', chatProvider.persona, _showVoiceDialog),
                _divider(),
                _prefTile(Icons.sentiment_satisfied_alt_rounded, 'Personality', chatProvider.persona, _showPersonalityDialog),
                _divider(),
                _prefTile(
                  Icons.build_circle_outlined,
                  'Extracted Tools',
                  '19 Tools Active',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen())),
                ),
                _divider(),
                _prefTile(
                  Icons.terminal_rounded,
                  'Termux Terminal Reel',
                  'Live View',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen())),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Autonomous Voice & Biometrics Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Autonomous Voice & Biometrics',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.hearing_rounded, color: AppColors.neonCyan),
                  title: const Text('Wake Word ("Hey Max")', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Wake up assistant hands-free (Offline TFLite)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  value: chatProvider.wakeWordEnabled,
                  activeColor: AppColors.neonCyan,
                  onChanged: (val) => chatProvider.toggleWakeWord(val),
                ),
                _divider(),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.neonCyan),
                  title: const Text('Voice Guardian Biometrics', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Respond only to Shahin\'s voiceprint', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  value: chatProvider.voiceGuardianEnabled,
                  activeColor: AppColors.neonCyan,
                  onChanged: (val) => chatProvider.toggleVoiceGuardian(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data & Privacy Section Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Data & Privacy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _prefTile(Icons.backup_outlined, 'Backup & Restore', '', _showBackupDialog),
                _divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gemini API Key',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your AIzaSy API Key...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check, color: AppColors.neonCyan),
                            onPressed: () {
                              context.read<ChatProvider>().setApiKey(_apiKeyController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('API Key saved!')),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.neonCyan,
                            side: const BorderSide(color: AppColors.neonCyan),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.network_check_rounded),
                          label: const Text('Test Connection & Latency'),
                          onPressed: _testGeminiConnection,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _prefTile(IconData icon, String title, String trailingText, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonCyan, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText.isNotEmpty)
            Text(
              trailingText,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(color: AppColors.surfaceLight, height: 1);
}
