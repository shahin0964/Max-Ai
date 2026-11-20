import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/voice_orb.dart';
import '../widgets/gradient_logo.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'vision_screen.dart';
import 'memory_screen.dart';
import 'tools_manager_screen.dart';
import 'terminal_reel_screen.dart';
import 'settings_screen.dart';
import '../../data/services/tool_registry_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ToolRegistryService _toolRegistry = ToolRegistryService();
  int _navIndex = 0;
  VoiceOrbState _orbState = VoiceOrbState.idle;
  String _voiceStatusText = "Tap orb or say 'Hey Max'";
  bool _isTorchOn = false;
  int _volumeLevel = 75;

  final List<Map<String, dynamic>> _quickPrompts = [
    {'title': '☀️ Weather Today', 'cmd': 'What is the weather today?'},
    {'title': '💬 Send WhatsApp', 'cmd': 'whatsapp_send_message'},
    {'title': '⚡ Termux Check', 'cmd': 'termux uname -a'},
    {'title': '🔦 Toggle Torch', 'cmd': 'torch'},
    {'title': '🎵 Play Spotify', 'cmd': 'spotify_play Synthwave'},
    {'title': '🤖 Macro: Gemini Image', 'cmd': 'run macro gemini image'},
  ];

  Future<void> _handleQuickPrompt(String cmd) async {
    if (cmd == 'torch') {
      _toggleTorch();
      return;
    }
    if (cmd == 'whatsapp_send_message') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen()));
      return;
    }

    setState(() {
      _orbState = VoiceOrbState.listening;
      _voiceStatusText = 'Listening to "$cmd"...';
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _orbState = VoiceOrbState.thinking;
      _voiceStatusText = 'Reasoning & Executing Tools...';
    });

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendMessage(cmd);

    if (mounted) {
      final reply = chatProvider.messages.last.text;
      setState(() {
        _orbState = VoiceOrbState.speaking;
        _voiceStatusText = reply.length > 80 ? '${reply.substring(0, 80)}...' : reply;
      });

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _orbState = VoiceOrbState.idle;
            _voiceStatusText = "Tap orb or say 'Hey Max'";
          });
        }
      });
    }
  }

  void _onOrbTap() {
    setState(() {
      if (_orbState == VoiceOrbState.idle) {
        _orbState = VoiceOrbState.listening;
        _voiceStatusText = 'Listening to your voice...';
      } else if (_orbState == VoiceOrbState.listening) {
        _orbState = VoiceOrbState.thinking;
        _voiceStatusText = 'Thinking with Gemini 3.8 Flash...';
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _orbState = VoiceOrbState.speaking;
              _voiceStatusText = 'Max AI is active. How can I help you, Shahin?';
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _orbState = VoiceOrbState.idle;
                  _voiceStatusText = "Tap orb or say 'Hey Max'";
                });
              }
            });
          }
        });
      } else {
        _orbState = VoiceOrbState.idle;
        _voiceStatusText = "Tap orb or say 'Hey Max'";
      }
    });
  }

  Future<void> _toggleTorch() async {
    setState(() => _isTorchOn = !_isTorchOn);
    await _toolRegistry.executeTool('set_torch', {'enabled': _isTorchOn});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Flashlight turned ${_isTorchOn ? "ON" : "OFF"}')),
    );
  }

  Future<void> _setVolume(int level) async {
    setState(() => _volumeLevel = level);
    await _toolRegistry.executeTool('set_volume', {'level_percent': _volumeLevel});
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.mayaSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: AppColors.mayaAccentCyan, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'System Notifications',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: AppColors.mayaBorder),
            _notifItem('• Termux RUN_COMMAND Bridge: Active', 'Ready to dispatch bash commands.'),
            _notifItem('• Voice Guardian (Speaker Lock): Armed', 'ReDimNet2-B6 model verifying Shahin\'s voiceprint.'),
            _notifItem('• Accessibility Screen Control: Supported', 'OCR and touch dispatch active.'),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.mayaAccentCyan, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mayaBackground,
      drawer: CustomDrawer(
        selectedIndex: _navIndex,
        onSelectIndex: (index) => setState(() => _navIndex = index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Maya Top Bar (Logo + Voice Guardian Status Capsule + Terminal + Settings)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const SizedBox(width: 4),
                      const GradientLogo(size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Max AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  // Voice Guardian Status Capsule matching Maya APK
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showNotificationSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.mayaSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.mayaAccentCyan.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.online,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Voice Guardian Ready',
                                style: TextStyle(
                                  color: AppColors.mayaAccentCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.terminal_rounded, color: AppColors.terminalGreen, size: 22),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen())),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  const SizedBox(height: 16),

                  // Centerpiece: The Authentic VoiceOrb from Maya APK
                  Center(
                    child: Column(
                      children: [
                        VoiceOrb(
                          state: _orbState,
                          size: 190,
                          onTap: _onOrbTap,
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _voiceStatusText,
                            key: ValueKey(_voiceStatusText),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _orbState == VoiceOrbState.listening
                                  ? AppColors.mayaAccentCyan
                                  : _orbState == VoiceOrbState.thinking
                                      ? AppColors.mayaAccentPink
                                      : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Prompts Carousel (Horizontal scrolling chips)
                  const Text(
                    'Quick Prompts',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickPrompts.length,
                      itemBuilder: (context, index) {
                        final q = _quickPrompts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            backgroundColor: AppColors.mayaSurface,
                            side: const BorderSide(color: AppColors.mayaBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            label: Text(
                              q['title']!,
                              style: const TextStyle(color: AppColors.mayaAccentCyan, fontSize: 12),
                            ),
                            onPressed: () => _handleQuickPrompt(q['cmd']!),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Futuristic AI Engine & Status Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.mayaSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.mayaBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.online,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Gemini 3.8 Flash High Turbo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.mayaAccentCyan.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.mayaAccentCyan.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: AppColors.mayaAccentCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.security_rounded, color: AppColors.mayaAccentCyan, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Voice Guardian Biometric Lock Active',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.terminal_rounded, color: AppColors.terminalGreen, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Termux Rootless Bridge & 19 Tools Ready',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                          ],
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

      // Clean 3-Tab Bottom Navigation Bar (Voice, Chat, Settings)
      bottomNavigationBar: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.mayaSurface,
          border: const Border(top: BorderSide(color: AppColors.mayaBorder, width: 0.8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navTab(Icons.mic_rounded, 'Voice', 0, () => setState(() => _navIndex = 0)),
            _navTab(Icons.chat_bubble_outline_rounded, 'Chat', 1, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            }),
            _navTab(Icons.settings_outlined, 'Settings', 2, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _navTab(IconData icon, String label, int index, VoidCallback onTap) {
    final isSel = _navIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSel ? AppColors.mayaAccentCyan : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSel ? AppColors.mayaAccentCyan : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
