import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/rainbow_edge_glow.dart';
import 'tools_manager_screen.dart';
import 'terminal_reel_screen.dart';
import '../../data/services/gemini_api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _geminiKeysController;
  late TextEditingController _groqKeyController;
  static const MethodChannel _audioChannel = MethodChannel('com.max.ai/audio');

  @override
  void initState() {
    super.initState();
    final p = context.read<ChatProvider>();
    _geminiKeysController = TextEditingController(text: p.apiKey);
    _groqKeyController = TextEditingController(text: p.groqApiKey);
  }

  @override
  void dispose() {
    _geminiKeysController.dispose();
    _groqKeyController.dispose();
    super.dispose();
  }

  Future<void> _playVoice(String name) async {
    try {
      await _audioChannel.invokeMethod('playVoiceModel', {'voice': name});
    } catch (_) {}
  }

  void _showSecretSettingsDialog() {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) {
          final cur = chatProvider.personality;
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: const [
                Icon(Icons.lock_open_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 8),
                Text('Secret settings', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _personalityTile(
                    'Friendly',
                    'Ek pyaari, kareebi dost. Romance nahi — par adult sawaalon ka seedha jawab deti hai.',
                    cur == 'Friendly',
                    () {
                      chatProvider.setPersonality('Friendly');
                      setDState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  _personalityTile(
                    'Romantic',
                    'Pyaar ke naam, flirting, nakhre, jalan — dusri ladkiyon se bhi aur dusre AIs se bhi.',
                    cur == 'Romantic',
                    () {
                      chatProvider.setPersonality('Romantic');
                      setDState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  _personalityTile(
                    'Intense (18+)',
                    'Romantic ka sab kuch, upar se asli garmi, khul ke boli hui. [100% UNLOCKED IN MAX AI]',
                    cur == 'Intense (18+)',
                    () {
                      chatProvider.setPersonality('Intense (18+)');
                      setDState(() {});
                    },
                    isVip: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save & Done', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          );
        },
      ),
    );
  }

  Widget _personalityTile(String title, String desc, bool isSelected, VoidCallback onTap, {bool isVip = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(8)),
                        child: const Text('UNLOCKED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  void _showWallpapersDialog() {
    final chatProvider = context.read<ChatProvider>();
    final wallpapers = [
      'Maya red',
      'Asleep at her desk',
      'The reaching hand',
      'Jarvis',
      'Maya',
      'Maya green',
      'Maya saree',
      'Maya studio',
      'Maya violet',
      'Venom',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setWState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Appearance & Wallpapers', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: wallpapers.length,
                itemBuilder: (context, idx) {
                  final name = wallpapers[idx];
                  final isSel = chatProvider.activeWallpaper == name;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.image_rounded, color: Color(0xFF2563EB)),
                      title: Text(name, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13.5)),
                      subtitle: const Text('Unlocked VIP', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
                      trailing: isSel
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB))
                          : const Text('Select', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                      onTap: () {
                        chatProvider.setActiveWallpaper(name);
                        setWState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Activated "$name" wallpaper!')));
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          );
        },
      ),
    );
  }

  Future<void> _testConnection() async {
    final key = _geminiKeysController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter at least one Gemini API key!')));
      return;
    }

    context.read<ChatProvider>().setApiKey(key);
    context.read<ChatProvider>().setGroqApiKey(_groqKeyController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Testing connection & key pool...')));

    try {
      final service = GeminiApiService(
        apiKey: key,
        groqApiKey: _groqKeyController.text.trim(),
      );
      final res = await service.sendMessage(prompt: 'Hello! Respond with OK', history: []);
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Connection Successful! ✅', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
            content: Text(
              'Connected to ${res.usedModel}!\nLatency: ${res.durationSeconds.toStringAsFixed(2)}s\nKeys in Pool: ${service.keyPool.length}\nRate-Limit Cascading: Active ⚡',
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Awesome!')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Connection Notice ℹ️', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
            content: Text(
              'Key saved! ${e.toString().replaceAll("Exception: ", "")}',
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final edgeGlow = chatProvider.edgeGlowEnabled;

    return RainbowEdgeGlow(
      enabled: edgeGlow,
      child: Scaffold(
        backgroundColor: const Color(0xFFEBF3FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 19),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 20),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Group 1: Maya Core Options matching frame_031.jpg
            _clayGroupCard(
              children: [
                _settingsTile(Icons.headset_rounded, 'Maya', 'Persona: ${chatProvider.persona} · ${chatProvider.language}', () {
                  _showLanguageDialog(context);
                }),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                _settingsTile(Icons.record_voice_over_rounded, 'Voice engine', 'Advanced Agentic [Unlocked]', () {
                  _showVoiceEngineDialog(context);
                }),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                _settingsTile(Icons.lock_rounded, 'Secret settings', '${chatProvider.personality} Mode [Unlocked]', _showSecretSettingsDialog),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                _settingsTile(Icons.bolt_rounded, 'Skills', '19 Active Autonomous Tools', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen()));
                }),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                _settingsTile(Icons.smart_toy_rounded, 'Sub-agents & Providers', 'DeepSeek, Gemini & Groq Free Pool', () {
                  _showSubAgentsDialog(context);
                }),
              ],
            ),

            const SizedBox(height: 18),

            // Anti-Rate-Limit API Key Pool Section
            _clayGroupCard(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.vpn_key_rounded, color: Color(0xFF2563EB), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Anti-Rate-Limit Key Pool',
                            style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Separate multiple Gemini API keys with commas to never hit 429 daily rate limits!',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _geminiKeysController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Gemini API Keys (Key1, Key2, Key3...)',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _groqKeyController,
                        obscureText: true,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Groq API Key (Optional · 14,400 free requests/day)',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('Save & Test Connection Pool', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _testConnection,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _sectionTitle('APPEARANCE & BEHAVIOUR'),
            _clayGroupCard(
              children: [
                _settingsTile(Icons.wallpaper_rounded, 'Wallpapers & Characters', '${chatProvider.activeWallpaper} [All 10 Unlocked]', _showWallpapersDialog),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB)),
                  title: const Text('Edge glow (Rainbow Frame)', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13.5)),
                  subtitle: const Text('Maya live ho tab screen ke charon taraf chamakta frame', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  value: chatProvider.edgeGlowEnabled,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => chatProvider.setEdgeGlowEnabled(v),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.switch_access_shortcut_rounded, color: Color(0xFF2563EB)),
                  title: const Text('Character / Orb Mode', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13.5)),
                  subtitle: Text(chatProvider.characterMode ? 'Showing 3D Anime Maya Girl' : 'Showing Holographic Brain Orb', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  value: chatProvider.characterMode,
                  activeColor: const Color(0xFF2563EB),
                  onChanged: (v) => chatProvider.setCharacterMode(v),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _sectionTitle('KAAM AUR MESSAGES'),
            _clayGroupCard(
              children: [
                _settingsTile(Icons.mail_rounded, 'Email', 'Maya tumhare address se mail bhej sake', () {}),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                _settingsTile(Icons.chat_bubble_rounded, 'Messages aur WhatsApp', 'Message alerts, auto-reply, WhatsApp bridge', () {}),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                _settingsTile(Icons.share_rounded, 'Social media', 'Handle, captions, daily story generator', () {}),
              ],
            ),

            const SizedBox(height: 18),
            _sectionTitle('JUDE HUE ACCOUNTS'),
            _clayGroupCard(
              children: [
                _settingsTile(Icons.hub_rounded, 'Connectors', 'GitHub, Google Drive, Notion, Telegram, Vercel', () {
                  _showConnectorsDialog(context);
                }),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _clayGroupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x103060A0), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final p = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Language & Persona', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Hinglish (Hindi + English)'),
              trailing: p.language.contains('Hinglish') ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
              onTap: () {
                p.setLanguage('Hinglish (Hindi + English)');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('English (Default)'),
              trailing: p.language == 'English' ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
              onTap: () {
                p.setLanguage('English');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('বাংলা (Bengali)'),
              trailing: p.language == 'বাংলা' ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
              onTap: () {
                p.setLanguage('বাংলা');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceEngineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Voice Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(
              leading: Icon(Icons.flash_on_rounded, color: Color(0xFF2563EB)),
              title: Text('Maya Swift', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Sabse tez response'),
            ),
            ListTile(
              leading: Icon(Icons.favorite_rounded, color: Color(0xFFEC4899)),
              title: Text('Maya Soul', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Asli emotions (Thoda dheema)'),
            ),
            ListTile(
              leading: Icon(Icons.psychology_rounded, color: Color(0xFF8B5CF6)),
              title: Text('Advanced Agentic Engine', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('100% Unlocked in Max AI'),
              trailing: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showSubAgentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sub-agents & Multi-Model', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• Maya Agentic Plan — DeepSeek Flash (Built-in Active)'),
            SizedBox(height: 8),
            Text('• Gemini Free Models: Auto-switch on rate limit active'),
            SizedBox(height: 8),
            Text('• Groq 14,400 Free Daily Tokens Integration Active'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showConnectorsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Active Connectors', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ListTile(leading: Icon(Icons.folder_shared_rounded), title: Text('Google Drive'), subtitle: Text('Save reports and notes')),
            ListTile(leading: Icon(Icons.code_rounded), title: Text('GitHub'), subtitle: Text('Repos, commits & workflow triggers')),
            ListTile(leading: Icon(Icons.send_rounded), title: Text('Telegram & WhatsApp'), subtitle: Text('Auto-messages active')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }
}
