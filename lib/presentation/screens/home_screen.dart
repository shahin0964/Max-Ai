import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/voice_orb.dart';
import '../widgets/rainbow_edge_glow.dart';
import 'chat_screen.dart';
import 'scanner_screen.dart';
import 'yaadein_screen.dart';
import 'settings_screen.dart';
import 'tools_manager_screen.dart';
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
  int _navIndex = 0;
  VoiceOrbState _orbState = VoiceOrbState.idle;
  String _listeningStatus = 'Sun rahi hai...';
  late AnimationController _characterFloatController;

  @override
  void initState() {
    super.initState();
    _characterFloatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _characterFloatController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onCenterMicTap() {
    setState(() {
      if (_orbState == VoiceOrbState.idle) {
        _orbState = VoiceOrbState.listening;
        _listeningStatus = 'Listening to your voice...';
      } else if (_orbState == VoiceOrbState.listening) {
        _orbState = VoiceOrbState.thinking;
        _listeningStatus = 'Reasoning with Gemini...';
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _orbState = VoiceOrbState.speaking;
              _listeningStatus = 'Max AI is active. How can I help you, Shahin?';
            });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _orbState = VoiceOrbState.idle;
                  _listeningStatus = 'Sun rahi hai...';
                });
              }
            });
          }
        });
      } else {
        _orbState = VoiceOrbState.idle;
        _listeningStatus = 'Sun rahi hai...';
      }
    });
  }

  void _sendHomeMessage([String? preset]) {
    final text = preset ?? _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(text);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: Color(0xFF2563EB), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'System Notifications',
                      style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Color(0xFF64748B)), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: Color(0xFFE2E8F0)),
            _notifItem('• Max AI Pro Active: Unlimited Access', 'All 19 autonomous tools unlocked.'),
            _notifItem('• Termux Rootless Bridge: Connected', 'Ready to dispatch background scripts.'),
            _notifItem('• Multi-Key Pool & Groq Fallback: Armed', 'Immune to Gemini 429 daily rate limits.'),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final edgeGlow = chatProvider.edgeGlowEnabled;
    final isCharacterMode = chatProvider.characterMode;

    return RainbowEdgeGlow(
      enabled: edgeGlow,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFEBF3FB),
        drawer: CustomDrawer(selectedIndex: 0, onSelectIndex: (_) {}),
        body: SafeArea(
          child: Column(
            children: [
              // Top AppBar matching frame_015.jpg
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Hamburger menu pill
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x123060A0), blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B), size: 22),
                      ),
                    ),

                    // Center: App title
                    const Text(
                      'Maya',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.3,
                      ),
                    ),

                    // Right: Notification Bell pill
                    GestureDetector(
                      onTap: _showNotificationSheet,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x123060A0), blurRadius: 10, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 22),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // 100% UNLOCKED Banner (Replacing Maya's locked activation banner)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEBFA),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Max AI Pro • Unlimited Active',
                                  style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'All tools, vision scanner & voice models unlocked',
                                  style: TextStyle(color: Color(0xFF3B82F6), fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'UNLOCKED',
                              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Greeting and Energy Pill Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Abhi tak jaag rahe ho,',
                              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const Text(
                              'dost',
                              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _listeningStatus,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),

                        // Energy Badge & Orb Mode Switcher
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x103060A0), blurRadius: 8, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 16),
                                  SizedBox(width: 4),
                                  Text('∞ Energy', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => chatProvider.setCharacterMode(!isCharacterMode),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF93C5FD)),
                                ),
                                child: Text(
                                  isCharacterMode ? 'Switch to Orb 🔮' : 'Switch to Girl 👗',
                                  style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Centerpiece: Maya Character (Red Dress) OR Holographic Glowing Orb!
                    Center(
                      child: isCharacterMode
                          ? AnimatedBuilder(
                              animation: _characterFloatController,
                              builder: (context, child) {
                                final float = (_characterFloatController.value - 0.5) * 8;
                                return Transform.translate(
                                  offset: Offset(0, float),
                                  child: GestureDetector(
                                    onTap: _onCenterMicTap,
                                    child: Image.asset(
                                      'assets/characters/maya_red.png',
                                      height: 280,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => VoiceOrb(
                                        state: _orbState,
                                        size: 190,
                                        onTap: _onCenterMicTap,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : VoiceOrb(
                              state: _orbState,
                              size: 190,
                              onTap: _onCenterMicTap,
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Quick Pills Row (Gaane, Padhai, Journal) matching frame_015.jpg
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _quickPill('♪ Gaane', () => _sendHomeMessage('Play my favorite music playlist')),
                        _quickPill('📖 Padhai', () => _sendHomeMessage('Help me learn something new today')),
                        _quickPill('✏️ Journal', () => _sendHomeMessage('Record this thought in my journal')),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 3 Live Status Cards Grid matching frame_015.jpg
                    Row(
                      children: [
                        // Card 1: Mausam
                        Expanded(
                          child: _clayStatusCard(
                            icon: Icons.water_drop_rounded,
                            iconColor: const Color(0xFF38BDF8),
                            title: 'Mausam',
                            value: '22°',
                            subtitle: 'Showers · 96%',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Card 2: Aaj
                        Expanded(
                          child: _clayStatusCard(
                            icon: Icons.calendar_today_rounded,
                            iconColor: const Color(0xFF6366F1),
                            title: 'Aaj',
                            value: DateFormat('d').format(DateTime.now()),
                            subtitle: DateFormat('E, MMM').format(DateTime.now()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Card 3: Mood
                        Expanded(
                          child: _clayStatusCard(
                            icon: Icons.favorite_rounded,
                            iconColor: const Color(0xFFEC4899),
                            title: 'Mood',
                            value: 'Pyaar bh...',
                            subtitle: 'Sab badhiya',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Bottom Chat Input Pill matching frame_015.jpg
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(color: Color(0x153060A0), blurRadius: 14, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF64748B), size: 22),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13.5),
                              decoration: const InputDecoration(
                                hintText: 'Maya se kuch bhi poochho...',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (t) => _sendHomeMessage(t),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _sendHomeMessage(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2563EB),
                              ),
                              child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // 5-Tab Clay Bottom Navigation Bar matching frame_015.jpg & frame_010.jpg
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(color: Color(0x183060A0), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bottomTab(Icons.home_rounded, 'Home', 0, () => setState(() => _navIndex = 0)),
                    _bottomTab(Icons.crop_free_rounded, 'Scan', 1, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
                    }),

                    // Center Elevated Floating Blue Mic Orb
                    GestureDetector(
                      onTap: _onCenterMicTap,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _orbState == VoiceOrbState.listening ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    _bottomTab(Icons.psychology_rounded, 'Yaadein', 3, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const YaadeinScreen()));
                    }),
                    _bottomTab(Icons.chat_bubble_rounded, 'Chat', 4, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickPill(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x103060A0), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  Widget _clayStatusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x103060A0), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 17),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _bottomTab(IconData icon, String label, int index, VoidCallback onTap) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
