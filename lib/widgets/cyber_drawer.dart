import 'package:flutter/material.dart';
import '../screens/tools/browser_screen.dart';
import '../screens/tools/coding_studio_screen.dart';
import '../screens/tools/documents_screen.dart';
import '../screens/tools/marketing_screen.dart';
import '../screens/tools/markets_screen.dart';
import '../screens/tools/terminal_screen.dart';
import '../screens/update/update_screen.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'glass_panel.dart';

class CyberDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;

  const CyberDrawer({
    super.key,
    this.selectedIndex = 0,
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MAX AI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppTheme.cyan,
                              ),
                            ),
                            Text(
                              'OpenJarvis Slidebar Cockpit',
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

            // 2. Workspace & Production Tools List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.cyan,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'WORKSPACE & PRODUCTION TOOLS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildToolTile(
                    context: context,
                    icon: Icons.trending_up,
                    iconColor: AppTheme.emerald,
                    title: 'Markets & Financial Intelligence',
                    subtitle: 'Live crypto, tech stock metrics & macro sentiment analysis',
                    badge: 'MARKETS',
                    badgeColor: AppTheme.emerald,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketsScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildToolTile(
                    context: context,
                    icon: Icons.campaign_outlined,
                    iconColor: AppTheme.amber,
                    title: 'Marketing & Content Studio',
                    subtitle: 'Viral Instagram reels, YouTube titles, ad copy & hashtags',
                    badge: 'STUDIO',
                    badgeColor: AppTheme.amber,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketingScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildToolTile(
                    context: context,
                    icon: Icons.description_outlined,
                    iconColor: AppTheme.cyan,
                    title: 'Documents & Knowledge Hub',
                    subtitle: 'Summarize documents, contracts, PDFs & extract action items',
                    badge: 'DOCS',
                    badgeColor: AppTheme.cyan,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildToolTile(
                    context: context,
                    icon: Icons.code,
                    iconColor: AppTheme.violet,
                    title: 'Website & Coding Studio',
                    subtitle: 'Architect Flutter apps, Python APIs, HTML websites & debug syntax',
                    badge: 'CODING',
                    badgeColor: AppTheme.violet,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CodingStudioScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildToolTile(
                    context: context,
                    icon: Icons.terminal,
                    iconColor: AppTheme.cyan,
                    title: 'Terminal & Shell Runner',
                    subtitle: 'Local Android bash console, system diagnostics & shell commands',
                    badge: 'TERMINAL',
                    badgeColor: AppTheme.cyan,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildToolTile(
                    context: context,
                    icon: Icons.travel_explore,
                    iconColor: AppTheme.emerald,
                    title: 'Autonomous AI Browser',
                    subtitle: 'Live web scraping, real-time research agent & page summarizer',
                    badge: 'BROWSER',
                    badgeColor: AppTheme.emerald,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BrowserScreen()));
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildToolTile(
                    context: context,
                    icon: Icons.system_update_rounded,
                    iconColor: AppTheme.amber,
                    title: 'System & App Updates',
                    subtitle: 'Check latest GitHub releases, download APK & install auto-updates',
                    badge: 'UPDATE',
                    badgeColor: AppTheme.amber,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateScreen()));
                    },
                  ),
                  const SizedBox(height: 12),
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
                      'READY',
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

  Widget _buildToolTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 12,
      borderColor: iconColor.withValues(alpha: 0.25),
      backgroundColor: AppTheme.surfaceElevated,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 16, color: AppTheme.cyan),
        ],
      ),
    );
  }
}
