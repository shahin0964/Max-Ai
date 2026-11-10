import 'package:flutter/material.dart';
import '../../services/diagnostics_logger_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/model_selector_sheet.dart';
import '../agent/agent_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../memory/memory_screen.dart';
import '../settings/settings_screen.dart';

class MoreHubScreen extends StatelessWidget {
  const MoreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.amber),
          tooltip: 'Open Slidebar',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view, color: AppTheme.amber, size: 20),
            SizedBox(width: 8),
            Text(
              'COCKPIT MODULES & HUB',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: AppTheme.amber,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'OPENJARVIS EXPANSION MODULES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
            ),

            // 1. Autonomous Agent Hub
            _buildModuleCard(
              context: context,
              icon: Icons.hub,
              iconColor: AppTheme.amber,
              title: 'Autonomous Agent Hub',
              subtitle: 'ReAct agent loop, tool orchestration & live execution timeline',
              badge: 'CORE AGENT',
              badgeColor: AppTheme.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const AgentScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            // 2. OpenJarvis Memory Stack
            _buildModuleCard(
              context: context,
              icon: Icons.psychology,
              iconColor: AppTheme.violet,
              title: 'OpenJarvis Memory Stack',
              subtitle: 'Long-term semantic storage, episodic user facts & persona',
              badge: 'MEMORY',
              badgeColor: AppTheme.violet,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const MemoryScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            // 3. Telemetry & Bug Monitor
            _buildModuleCard(
              context: context,
              icon: Icons.speed,
              iconColor: AppTheme.cyan,
              title: 'Telemetry & Bug Monitor',
              subtitle: 'Hardware vitals, latency metrics, and autonomous crash recorder',
              badge: 'DIAGNOSTICS',
              badgeColor: AppTheme.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const DashboardScreen()),
                );
              },
            ),

            const SizedBox(height: 10),

            // 4. Settings & Parameters
            _buildModuleCard(
              context: context,
              icon: Icons.settings,
              iconColor: AppTheme.emerald,
              title: 'Settings & Parameters',
              subtitle: 'API keys, ElevenLabs Voice ID (wDsJlOXPqcvIUKdLXjDs), prompt rules',
              badge: 'CONFIG',
              badgeColor: AppTheme.emerald,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'QUICK ACTIONS & TOOLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
            ),

            // 5. Switch AI Model Sheet
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: 14,
              borderColor: AppTheme.surfaceGlassBorder,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (ctx) => const ModelSelectorSheet(),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.swap_horiz, color: AppTheme.cyan, size: 22),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch Active AI Model',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'Gemini 3.8 Flash, 3.7 Flash, 3.1 Pro, Claude, GPT, Ollama',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 6. Export Diagnostics to Phone Storage
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: 14,
              borderColor: AppTheme.surfaceGlassBorder,
              onTap: () async {
                await DiagnosticsLoggerService.instance.dumpFullLogs();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Diagnostics saved to Download/max_ai_diagnostics.log'),
                    ),
                  );
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.file_download, color: AppTheme.emerald, size: 22),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Diagnostic Log Dump',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'Write all live session logs & errors to Download folder',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      borderRadius: 16,
      borderColor: iconColor.withValues(alpha: 0.3),
      backgroundColor: AppTheme.surfaceElevated,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.4), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 0.6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios, size: 14, color: iconColor),
        ],
      ),
    );
  }
}
