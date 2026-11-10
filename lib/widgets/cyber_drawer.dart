import 'package:flutter/material.dart';
import '../screens/agent/agent_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/memory/memory_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/ai_engine_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';
import 'model_selector_sheet.dart';

class CyberDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;

  const CyberDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Futuristic Glowing Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceElevated,
                border: Border(
                  bottom: BorderSide(color: AppTheme.surfaceGlassBorder, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cyan, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cyan.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/icons/app_logo.png',
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.psychology,
                              color: AppTheme.cyan,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MAX AI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppTheme.cyan,
                              ),
                            ),
                            const Text(
                              'OpenJarvis Hybrid Core',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Active Voice Badge
                  ListenableBuilder(
                    listenable: SettingsService.instance,
                    builder: (context, _) {
                      final settings = SettingsService.instance;
                      return GlassPanel(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        borderRadius: 10,
                        borderColor: AppTheme.violet.withValues(alpha: 0.4),
                        backgroundColor: AppTheme.violet.withValues(alpha: 0.1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.record_voice_over, size: 14, color: AppTheme.violet),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Voice: ${settings.voiceId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Navigation Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'NAVIGATION COCKPIT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Chat Cockpit',
                    index: 0,
                    color: AppTheme.cyan,
                    context: context,
                  ),
                  _buildNavItem(
                    icon: Icons.center_focus_strong_outlined,
                    activeIcon: Icons.center_focus_strong,
                    label: 'Jarvis Vision',
                    index: 1,
                    color: AppTheme.emerald,
                    context: context,
                  ),
                  _buildNavItem(
                    icon: Icons.graphic_eq,
                    activeIcon: Icons.graphic_eq,
                    label: 'Holographic Voice',
                    index: 2,
                    color: AppTheme.violet,
                    context: context,
                  ),
                  _buildNavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view,
                    label: 'More Cockpit Hub',
                    index: 3,
                    color: AppTheme.amber,
                    context: context,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'SPECIALIZED MODULES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),

                  _buildModuleItem(
                    icon: Icons.hub,
                    label: 'Autonomous Agent Hub',
                    color: AppTheme.amber,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AgentScreen()),
                      );
                    },
                  ),
                  _buildModuleItem(
                    icon: Icons.psychology,
                    label: 'OpenJarvis Memory Stack',
                    color: AppTheme.violet,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MemoryScreen()),
                      );
                    },
                  ),
                  _buildModuleItem(
                    icon: Icons.speed,
                    label: 'Telemetry & Bug Monitor',
                    color: AppTheme.cyan,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'SYSTEM CONFIGURATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),

                  // ⚙️ MAIN SETTINGS BUTTON (Opens Detailed Options inside)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: 12,
                      borderColor: AppTheme.cyan.withValues(alpha: 0.3),
                      backgroundColor: AppTheme.surfaceElevated,
                      onTap: () {
                        Navigator.pop(context); // Close Drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.settings, color: AppTheme.cyan, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings & Parameters',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'API Keys, Neural Voice, Prompts',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.cyan),
                        ],
                      ),
                    ),
                  ),

                  // Quick Model Switcher in Sidebar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: 12,
                      borderColor: AppTheme.surfaceGlassBorder,
                      backgroundColor: AppTheme.surface,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (ctx) => const ModelSelectorSheet(),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.swap_horiz, color: AppTheme.emerald, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Switch AI Model',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Gemini, Claude, GPT, Local Ollama',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.surfaceGlassBorder, width: 0.8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Max AI • Production Release',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      Text(
                        'Package: com.max.ai',
                        style: TextStyle(fontSize: 9, color: AppTheme.cyan),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.emerald, width: 0.8),
                    ),
                    child: const Text(
                      'ONLINE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color color,
    required BuildContext context,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? color : AppTheme.textSecondary,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? color : AppTheme.textPrimary,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              )
            : null,
        onTap: () {
          Navigator.pop(context); // Close Drawer
          onSelectTab(index);
        },
      ),
    );
  }

  Widget _buildModuleItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: color.withValues(alpha: 0.6)),
        onTap: onTap,
      ),
    );
  }
}
