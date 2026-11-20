import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/voice_orb.dart';
import '../widgets/custom_drawer.dart';
import 'chat_screen.dart';
import 'scanner_screen.dart';
import 'yaadein_screen.dart';
import 'settings_screen.dart';
import 'tools_manager_screen.dart';
import 'terminal_reel_screen.dart';
import '../../data/services/tool_registry_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ToolRegistryService _toolRegistry = ToolRegistryService();
  VoiceOrbState _orbState = VoiceOrbState.idle;
  String _coreStatus = 'Ready · Tap orb to speak';
  bool _isTorchOn = false;

  void _onOrbTap() {
    setState(() {
      if (_orbState == VoiceOrbState.idle) {
        _orbState = VoiceOrbState.listening;
        _coreStatus = 'Listening to your voice...';
      } else if (_orbState == VoiceOrbState.listening) {
        _orbState = VoiceOrbState.thinking;
        _coreStatus = 'Processing with Gemini 3.8 Flash...';
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) {
            setState(() {
              _orbState = VoiceOrbState.speaking;
              _coreStatus = 'Max AI is active. How can I assist you, Shahin?';
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _orbState = VoiceOrbState.idle;
                  _coreStatus = 'Ready · Tap orb to speak';
                });
              }
            });
          }
        });
      } else {
        _orbState = VoiceOrbState.idle;
        _coreStatus = 'Ready · Tap orb to speak';
      }
    });
  }

  void _sendPrompt([String? preset]) {
    final text = preset ?? _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    context.read<ChatProvider>().sendMessage(text);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  void _toggleTorch() async {
    setState(() => _isTorchOn = !_isTorchOn);
    await _toolRegistry.executeTool('set_torch', {'enabled': _isTorchOn});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isTorchOn ? 'Flashlight ON 🔦' : 'Flashlight OFF'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showModelWaterfallDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101422),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: Row(
          children: const [
            Icon(Icons.bolt_rounded, color: Color(0xFF00F2FE), size: 22),
            SizedBox(width: 8),
            Text(
              'Gemini Waterfall Engine',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When 429 quota or 503 high-demand occurs, the engine automatically cascades down without interruption:',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 14),
            _waterfallStep('1. gemini-3.8-flash', 'Primary Turbo (Latest)', true),
            _waterfallStep('2. gemini-2.0-flash', '1,500 req/day free', false),
            _waterfallStep('3. gemini-2.0-flash-lite', '1,500 req/day free · Ultra Fast', false),
            _waterfallStep('4. gemini-1.5-flash', '1,500 req/day free · Stable', false),
            _waterfallStep('5. gemini-1.5-flash-8b', '1,500 req/day · Lowest Tokens', false),
            _waterfallStep('6. gemini-2.0-pro-exp', 'Deep Reasoning Fallback', false),
            _waterfallStep('7. Groq Llama 3.3', '14,400 req/day free fallback', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _waterfallStep(String title, String desc, bool isPrimary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isPrimary ? Icons.stars_rounded : Icons.arrow_downward_rounded,
            size: 15,
            color: isPrimary ? const Color(0xFF00F2FE) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF00F2FE) : const Color(0xFFF1F5F9),
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  void _showActionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Actions & Tools',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _modalIconBtn(
                  icon: Icons.camera_alt_rounded,
                  label: 'Vision Scan',
                  color: const Color(0xFF00F2FE),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
                  },
                ),
                _modalIconBtn(
                  icon: Icons.psychology_rounded,
                  label: 'Yaadein',
                  color: const Color(0xFF7C4DFF),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const YaadeinScreen()));
                  },
                ),
                _modalIconBtn(
                  icon: Icons.terminal_rounded,
                  label: 'Terminal',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen()));
                  },
                ),
                _modalIconBtn(
                  icon: _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  label: 'Torch',
                  color: const Color(0xFFFBBF24),
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleTorch();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _modalIconBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF07090E),
      drawer: CustomDrawer(selectedIndex: 0, onSelectIndex: (_) {}),
      body: Stack(
        children: [
          // Ambient Neon Glow Highlights
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F2FE).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C4DFF).withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Cyber-Glow Floating Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111624),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Brand Logo & Live Pulse Beacon
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(color: Color(0xFF10B981), blurRadius: 8, spreadRadius: 1),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFF7C4DFF)],
                            ).createShader(bounds),
                            child: const Text(
                              'MAX AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Model Waterfall Badge (Interactive)
                      GestureDetector(
                        onTap: _showModelWaterfallDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F2FE).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF00F2FE)),
                              const SizedBox(width: 4),
                              Text(
                                chatProvider.activeModel.isNotEmpty ? chatProvider.activeModel : 'Gemini 3.8',
                                style: const TextStyle(
                                  color: Color(0xFF00F2FE),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111624),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // 2. Centerpiece: The Quantum Voice Core (Living Audio-Visual Sphere)
                Center(
                  child: Column(
                    children: [
                      VoiceOrb(
                        state: _orbState,
                        size: 210,
                        onTap: _onOrbTap,
                      ),
                      const SizedBox(height: 20),
                      // Core Dynamic Status Text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111624).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_orbState == VoiceOrbState.listening) ...[
                              const Icon(Icons.mic_rounded, size: 14, color: Color(0xFF00F2FE)),
                              const SizedBox(width: 6),
                            ] else if (_orbState == VoiceOrbState.thinking) ...[
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C4DFF)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _coreStatus,
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // 3. Capability Horizon (Horizontal Glass Chips)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _horizonChip(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Chat Now',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                      ),
                      _horizonChip(
                        icon: Icons.camera_alt_outlined,
                        label: 'Vision AI',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
                      ),
                      _horizonChip(
                        icon: Icons.psychology_outlined,
                        label: 'Yaadein Memory',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YaadeinScreen())),
                      ),
                      _horizonChip(
                        icon: Icons.terminal_rounded,
                        label: 'Termux Console',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen())),
                      ),
                      _horizonChip(
                        icon: Icons.grid_view_rounded,
                        label: '19 Tools',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Floating Command Deck (Input & Actions)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111624),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF1E293B)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF94A3B8), size: 22),
                          onPressed: _showActionModal,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Message or command Max AI...',
                              hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                            ),
                            onSubmitted: (_) => _sendPrompt(),
                          ),
                        ),
                        GestureDetector(
                          onTap: _onOrbTap,
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E293B),
                              border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.mic_rounded, color: Color(0xFF00F2FE), size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _sendPrompt(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF00F2FE), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 5. Sleek 4-Tab Floating Bottom Navigation Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D111D),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _dockTab(0, Icons.blur_on_rounded, 'Core', true, () {}),
                      _dockTab(1, Icons.chat_bubble_outline_rounded, 'Chat', false, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                      }),
                      _dockTab(2, Icons.grid_view_rounded, 'Studio', false, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen()));
                      }),
                      _dockTab(3, Icons.tune_rounded, 'Settings', false, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizonChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF111624),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF00F2FE)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dockTab(int index, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? const Color(0xFF00F2FE) : const Color(0xFF64748B),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFF00F2FE) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
