import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../screens/chat_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/yaadein_screen.dart';
import '../screens/tools_manager_screen.dart';
import '../screens/terminal_reel_screen.dart';
import '../screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectIndex;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0D16),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00F2FE), Color(0xFF7C4DFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F2FE).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFF7C4DFF)],
                        ).createShader(bounds),
                        child: const Text(
                          'MAX AI',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Next-Gen Autonomous Intelligence',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF1E293B), height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  _sectionHeader('INTELLIGENCE & VISION'),
                  _drawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'AI Chat Thread',
                    color: const Color(0xFF00F2FE),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.camera_alt_outlined,
                    label: 'Vision AI Scanner',
                    color: const Color(0xFF38BDF8),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.psychology_rounded,
                    label: 'Yaadein (Continuous Memory)',
                    color: const Color(0xFF7C4DFF),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const YaadeinScreen()));
                    },
                  ),

                  const SizedBox(height: 14),
                  _sectionHeader('DEVELOPER & TOOLS'),
                  _drawerItem(
                    icon: Icons.terminal_rounded,
                    label: 'Termux Terminal Live Reel',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen()));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.grid_view_rounded,
                    label: '19 Active Automations',
                    color: const Color(0xFFFBBF24),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen()));
                    },
                  ),

                  const SizedBox(height: 14),
                  _sectionHeader('SYSTEM & PREFERENCES'),
                  _drawerItem(
                    icon: Icons.tune_rounded,
                    label: 'Engine & API Settings',
                    color: const Color(0xFFE2E8F0),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),

            // Bottom Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111624),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Max AI v1.0.6 · All Features Unlocked',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6, top: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(color: Color(0xFFF1F5F9), fontSize: 13.5, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF475569), size: 18),
        onTap: onTap,
      ),
    );
  }
}
