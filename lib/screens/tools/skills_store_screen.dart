import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class SkillsStoreScreen extends StatefulWidget {
  const SkillsStoreScreen({super.key});

  @override
  State<SkillsStoreScreen> createState() => _SkillsStoreScreenState();
}

class _SkillsStoreScreenState extends State<SkillsStoreScreen> {
  final List<Map<String, dynamic>> _skills = [
    {
      'name': 'Web Search & Page Scraper',
      'desc': 'Fetches live website content and summarizes articles',
      'installed': true,
      'category': 'Research',
      'icon': Icons.public,
    },
    {
      'name': 'Code Debugger & Refactorer',
      'desc': 'Analyzes Dart, Python, and JS code for AST bugs',
      'installed': true,
      'category': 'Coding',
      'icon': Icons.bug_report,
    },
    {
      'name': 'Financial Markets Scanner',
      'desc': 'Pulls live crypto & stock metrics and evaluates volatility',
      'installed': true,
      'category': 'Finance',
      'icon': Icons.trending_up,
    },
    {
      'name': 'Smart Home IoT Controller',
      'desc': 'Controls Matter & Home Assistant lights and switches',
      'installed': false,
      'category': 'IoT',
      'icon': Icons.home_repair_service,
    },
    {
      'name': 'WhatsApp Auto-Responder Bot',
      'desc': 'Autonomous message filter and replies for customer inquiries',
      'installed': false,
      'category': 'Communication',
      'icon': Icons.mark_chat_read,
    },
    {
      'name': 'GitHub PR & Issue Triager',
      'desc': 'Reviews incoming pull requests and suggests diff revisions',
      'installed': false,
      'category': 'Coding',
      'icon': Icons.source,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKILL STORE & PLAYBOOKS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Header stats
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt, color: AppTheme.amber, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OpenJarvis Skill Extensions', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13.5)),
                        SizedBox(height: 2),
                        Text('Extend Max AI agents with modular function playbooks and community skills', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'AVAILABLE COMMUNITY SKILLS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan),
              ),
            ),

            ..._skills.map((s) {
              final isInst = s['installed'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isInst ? AppTheme.cyan.withValues(alpha: 0.3) : AppTheme.surfaceGlassBorder,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isInst ? AppTheme.cyan : AppTheme.textMuted).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(s['icon'] as IconData, color: isInst ? AppTheme.cyan : AppTheme.textMuted, size: 20),
                  ),
                  title: Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                  subtitle: Text(s['desc'] as String, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        s['installed'] = !isInst;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${s['name']} ${isInst ? "uninstalled" : "installed"} successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInst ? AppTheme.surface : AppTheme.cyan,
                      foregroundColor: isInst ? AppTheme.textMuted : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(60, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isInst ? 'INSTALLED' : 'GET', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
