import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'gradient_logo.dart';
import '../screens/chat_screen.dart';
import '../screens/vision_screen.dart';
import '../screens/memory_screen.dart';
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

  void _showProModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E142B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.goldPro),
        ),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, color: AppColors.goldPro, size: 28),
            SizedBox(width: 8),
            Text('Max AI Pro Active', style: TextStyle(color: AppColors.goldPro, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('👑 Unlocked Features:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Gemini 3.8 Flash High Turbo Engine\n• 19 Autonomous Tools & Termux Rootless Bridge\n• Multi-step App Macros Execution\n• Voice Guardian Speaker Biometrics\n• Infinite Long-Term Memory Vault',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPro, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A1024),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  const GradientLogo(size: 44),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Max AI',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Smarter. Simpler. Always with you.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceLight, height: 1),

            // Navigation Items - 100% Functional!
            const SizedBox(height: 12),
            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                onSelectIndex(0);
              },
            ),
            _drawerItem(
              icon: Icons.chat_bubble_rounded,
              title: 'Chat',
              isSelected: selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.camera_alt_rounded,
              title: 'Vision',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.grid_view_rounded,
              title: 'Tools (19 Active)',
              isSelected: selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.psychology_rounded,
              title: 'Memory Vault',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.terminal_rounded,
              title: 'Termux Terminal Reel',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen()));
              },
            ),
            _drawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              isSelected: selectedIndex == 3,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),

            const Spacer(),

            // Bottom Pro Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => _showProModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF261D4C), Color(0xFF131735)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neonPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.goldPro.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.goldPro,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Max AI Pro',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Unlock more features',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.electricBlue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
