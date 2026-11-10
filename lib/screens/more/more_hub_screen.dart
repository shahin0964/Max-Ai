import 'package:flutter/material.dart';
import '../../services/diagnostics_logger_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';
import '../../widgets/model_selector_sheet.dart';
import '../agent/agent_screen.dart';
import '../backup/backup_restore_screen.dart';
import '../connectors/connectors_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../integrations/email_integration_screen.dart';
import '../memory/memory_screen.dart';
import '../settings/assistant_persona_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/subagents_screen.dart';
import '../tools/browser_screen.dart';
import '../tools/coding_studio_screen.dart';
import '../tools/documents_screen.dart';
import '../tools/marketing_screen.dart';
import '../tools/markets_screen.dart';
import '../tools/skills_store_screen.dart';
import '../tools/terminal_screen.dart';

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
            // 1. INTELLIGENT AGENTS & CORES
            _buildCategoryHeader('INTELLIGENT AGENTS & ROUTER', AppTheme.amber),
            _buildModuleCard(
              context: context,
              icon: Icons.hub,
              iconColor: AppTheme.amber,
              title: 'Autonomous Agent Hub',
              subtitle: 'ReAct agent loop, tool orchestration & execution timeline',
              badge: 'CORE AGENT',
              badgeColor: AppTheme.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgentScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.alt_route,
              iconColor: AppTheme.cyan,
              title: 'Sub-Agents & Dispatch Router',
              subtitle: 'Multi-LLM load-balancer, fallback chain & custom Ollama providers',
              badge: 'ROUTER',
              badgeColor: AppTheme.cyan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubAgentsScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.bolt,
              iconColor: AppTheme.emerald,
              title: 'Skill Store & Playbooks',
              subtitle: 'Extend Max AI agents with modular function playbooks',
              badge: 'EXTENSIONS',
              badgeColor: AppTheme.emerald,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillsStoreScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.swap_horiz,
              iconColor: AppTheme.violet,
              title: 'Switch Active AI Model',
              subtitle: 'Select between Gemini 3.8 Flash, Claude 3.5, GPT-4o, Local Ollama',
              badge: 'MODEL',
              badgeColor: AppTheme.violet,
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const ModelSelectorSheet(),
              ),
            ),

            const SizedBox(height: 20),

            // 2. WORKSPACE & PRODUCTION TOOLS (KAAM-KAAJ)
            _buildCategoryHeader('WORKSPACE & PRODUCTION TOOLS', AppTheme.cyan),
            _buildModuleCard(
              context: context,
              icon: Icons.trending_up,
              iconColor: AppTheme.emerald,
              title: 'Markets & Financial Intelligence',
              subtitle: 'Live crypto, tech stock metrics & macro sentiment analysis',
              badge: 'MARKETS',
              badgeColor: AppTheme.emerald,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketsScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.campaign_outlined,
              iconColor: AppTheme.amber,
              title: 'Marketing & Content Studio',
              subtitle: 'Viral Instagram reels, YouTube titles, ad copy & hashtags',
              badge: 'STUDIO',
              badgeColor: AppTheme.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketingScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.description_outlined,
              iconColor: AppTheme.cyan,
              title: 'Documents & Knowledge Hub',
              subtitle: 'Summarize documents, contracts, PDFs & extract action items',
              badge: 'DOCS',
              badgeColor: AppTheme.cyan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentsScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.code,
              iconColor: AppTheme.violet,
              title: 'Website & Coding Studio',
              subtitle: 'Architect Flutter apps, Python APIs, HTML websites & debug syntax',
              badge: 'CODING',
              badgeColor: AppTheme.violet,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CodingStudioScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.terminal,
              iconColor: AppTheme.cyan,
              title: 'Terminal & Shell Runner',
              subtitle: 'Local Android bash console, system diagnostics & shell commands',
              badge: 'TERMINAL',
              badgeColor: AppTheme.cyan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.travel_explore,
              iconColor: AppTheme.emerald,
              title: 'Autonomous AI Browser',
              subtitle: 'Live web scraping, real-time research agent & page summarizer',
              badge: 'BROWSER',
              badgeColor: AppTheme.emerald,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrowserScreen())),
            ),

            const SizedBox(height: 20),

            // 3. PERSONALIZATION & INTEGRATIONS
            _buildCategoryHeader('PERSONALIZATION & INTEGRATIONS', AppTheme.emerald),
            _buildModuleCard(
              context: context,
              icon: Icons.face_retouching_natural,
              iconColor: AppTheme.cyan,
              title: 'Assistant & Persona Customization',
              subtitle: 'Tone, voice engine styles, companion mode, driving mode, call announcer',
              badge: 'PERSONA',
              badgeColor: AppTheme.cyan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssistantPersonaScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.link,
              iconColor: AppTheme.amber,
              title: 'Cloud & Developer Connectors',
              subtitle: 'Integrate Google Drive, GitHub, Vercel, Notion, Telegram, Todoist',
              badge: 'CONNECTORS',
              badgeColor: AppTheme.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectorsScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.mail_outline,
              iconColor: AppTheme.emerald,
              title: 'Email Dispatch Engine',
              subtitle: 'Configure SMTP host, app passwords & dispatch emails via agent',
              badge: 'EMAIL',
              badgeColor: AppTheme.emerald,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailIntegrationScreen())),
            ),

            const SizedBox(height: 20),

            // 4. MEMORY, DATA & SYSTEM
            _buildCategoryHeader('MEMORY, DATA & SYSTEM', AppTheme.violet),
            _buildModuleCard(
              context: context,
              icon: Icons.psychology,
              iconColor: AppTheme.violet,
              title: 'OpenJarvis Memory Stack',
              subtitle: 'Long-term semantic storage, episodic user facts & persona vector DB',
              badge: 'MEMORY',
              badgeColor: AppTheme.violet,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.speed,
              iconColor: AppTheme.cyan,
              title: 'Telemetry & Bug Monitor',
              subtitle: 'Real-time agent latency, memory usage & diagnostic logs',
              badge: 'DIAGNOSTICS',
              badgeColor: AppTheme.cyan,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.backup_outlined,
              iconColor: AppTheme.amber,
              title: 'Backup & Restore',
              subtitle: 'Export encrypted memory archives to storage & restore backups',
              badge: 'BACKUP',
              badgeColor: AppTheme.amber,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupRestoreScreen())),
            ),
            const SizedBox(height: 8),
            _buildModuleCard(
              context: context,
              icon: Icons.settings,
              iconColor: AppTheme.textPrimary,
              title: 'Settings & Parameters',
              subtitle: 'API Keys (Gemini, Claude, ElevenLabs Voice ID), Prompts & TTS',
              badge: 'CONFIG',
              badgeColor: AppTheme.textSecondary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),

            const SizedBox(height: 20),

            // Quick Diagnostic Export Action
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.download, color: AppTheme.cyan, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Export Diagnostics Log File', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        Text('Save log to /storage/emulated/0/Download/', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final path = await DiagnosticsLoggerService.instance.exportLogsToDownloads();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(path != null ? 'Diagnostics exported to: $path' : 'Export failed'),
                            backgroundColor: path != null ? AppTheme.surfaceElevated : AppTheme.rose,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('EXPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: color,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 14,
      borderColor: iconColor.withValues(alpha: 0.25),
      backgroundColor: AppTheme.surfaceElevated,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppTheme.textMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.cyan),
        ],
      ),
    );
  }
}
