import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../../data/services/gemini_api_service.dart';
import 'yaadein_screen.dart';
import 'tools_manager_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _geminiKeysController;
  late TextEditingController _groqKeyController;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final chatProvider = context.read<ChatProvider>();
    _geminiKeysController = TextEditingController(text: chatProvider.apiKey);
    _groqKeyController = TextEditingController(text: chatProvider.groqApiKey ?? '');
  }

  @override
  void dispose() {
    _geminiKeysController.dispose();
    _groqKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final key = _geminiKeysController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one Gemini API key!')),
      );
      return;
    }

    setState(() => _isTesting = true);
    context.read<ChatProvider>().setApiKey(key);
    context.read<ChatProvider>().setGroqApiKey(_groqKeyController.text.trim());

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
            backgroundColor: const Color(0xFF101422),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFF1E293B)),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
                SizedBox(width: 8),
                Text('Key Pool Verified ✅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: Text(
              'Active Model: ${res.usedModel}\nLatency: ${res.durationSeconds.toStringAsFixed(2)}s\nKeys in Pool: ${service.keyPool.length}\nWaterfall Cascading: Active (7 Models + Groq) ⚡',
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Awesome', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: const Color(0xFF101422),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: Color(0xFF1E293B)),
            ),
            title: const Text('Notice ℹ️', style: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
            content: Text(
              'Key saved! ${e.toString().replaceAll("Exception: ", "")}',
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  void _showVoiceModal(BuildContext context, ChatProvider chatProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101422),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Voice Persona',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 14),
            _voiceTile('Maya (Warm & Natural)', 'maya', chatProvider),
            _voiceTile('Friday (Tactical & Sharp)', 'friday', chatProvider),
            _voiceTile('Venom (Deep & Bold)', 'venom', chatProvider),
            _voiceTile('Default AI Speech', 'default', chatProvider),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _voiceTile(String title, String key, ChatProvider chatProvider) {
    final isSelected = chatProvider.voiceModel == key;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00F2FE) : const Color(0xFFE2E8F0),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF00F2FE), size: 20),
            onPressed: () => chatProvider.previewVoice(key),
          ),
          if (isSelected) const Icon(Icons.check_rounded, color: Color(0xFF00F2FE), size: 20),
        ],
      ),
      onTap: () {
        chatProvider.setVoiceModel(key);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111624),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Settings & Engine',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // User Profile Capsule
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111624),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F2FE), Color(0xFF7C4DFF)],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'MS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Md Shahin',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Max AI Master Account · VIP Unlocked',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('PRO', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _sectionHeader('AI ENGINE & WATERFALL'),

                  // 7-Model Waterfall Engine Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111624),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.bolt_rounded, color: Color(0xFF00F2FE), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Gemini Waterfall Active',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F2FE).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chatProvider.activeModel.isNotEmpty ? chatProvider.activeModel : 'gemini-3.8-flash',
                                style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '7 Models Cascaded: gemini-3.8-flash ➔ gemini-2.0-flash ➔ gemini-2.0-flash-lite ➔ gemini-1.5-flash ➔ 8B ➔ Pro ➔ Groq',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _sectionHeader('ANTI-RATE-LIMIT KEY POOL'),

                  // Key Pool Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111624),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Separate multiple Gemini API keys with commas to never run out of quota:',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _geminiKeysController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Gemini API Keys (key1, key2, key3...)',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0B0E18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _groqKeyController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Groq API Key (Optional · 14,400 free requests/day)',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0B0E18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: _isTesting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.bolt_rounded, size: 18),
                            label: Text(_isTesting ? 'Verifying Pool...' : 'Save & Verify Key Pool', style: const TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: _isTesting ? null : _testConnection,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  _sectionHeader('PREFERENCES & VOICE'),

                  // Preferences Group
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111624),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.record_voice_over_rounded, color: Color(0xFF00F2FE)),
                          title: const Text('Voice Persona', style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: Text(chatProvider.voiceModel, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                          onTap: () => _showVoiceModal(context, chatProvider),
                        ),
                        const Divider(color: Color(0xFF1E293B), height: 1),
                        ListTile(
                          leading: const Icon(Icons.psychology_rounded, color: Color(0xFF7C4DFF)),
                          title: const Text('Continuous Yaadein Vault', style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: const Text('Long-term memory facts', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YaadeinScreen())),
                        ),
                        const Divider(color: Color(0xFF1E293B), height: 1),
                        ListTile(
                          leading: const Icon(Icons.grid_view_rounded, color: Color(0xFF10B981)),
                          title: const Text('19 Active Tools & Automations', style: TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: const Text('Termux, WhatsApp, Torch, Volume', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
