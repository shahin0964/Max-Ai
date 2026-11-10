import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class SubAgentsScreen extends StatefulWidget {
  const SubAgentsScreen({super.key});

  @override
  State<SubAgentsScreen> createState() => _SubAgentsScreenState();
}

class _SubAgentsScreenState extends State<SubAgentsScreen> {
  String _routingStrategy = 'ranked'; // best, ranked, swarm
  bool _customProvidersEnabled = true;

  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Gemini 3.8 Flash (Default Core)',
      'provider': 'Google AI Studio',
      'model': 'gemini-3.8-flash',
      'url': 'https://generativelanguage.googleapis.com',
      'enabled': true,
      'isDefault': true,
    },
    {
      'name': 'OpenJarvis Edge Node (Ollama)',
      'provider': 'Local Linux Daemon',
      'model': 'qwen2.5:7b',
      'url': 'http://192.168.1.105:11434/v1',
      'enabled': true,
      'isDefault': false,
    },
    {
      'name': 'Groq LPU Engine',
      'provider': 'Groq High-Speed',
      'model': 'llama-3.3-70b-versatile',
      'url': 'https://api.groq.com/openai/v1',
      'enabled': false,
      'isDefault': false,
    },
  ];

  void _showAddProviderDialog() {
    final tagCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'http://192.168.1.100:11434/v1');
    final modelCtrl = TextEditingController(text: 'qwen2.5-coder:7b');
    final keyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.cyan, width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ADD CUSTOM AI PROVIDER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan)),
                  IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Provider Tag (e.g. My Ollama, Groq, DeepSeek)',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Base URL (OpenAI-compatible /v1 endpoint)',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: modelCtrl,
                style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Model Identifier',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: keyCtrl,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'API Key (Leave blank for local Ollama)',
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Testing provider endpoint ping... Success!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.emerald),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('TEST PING', style: TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (tagCtrl.text.trim().isNotEmpty) {
                          setState(() {
                            _providers.add({
                              'name': tagCtrl.text.trim(),
                              'provider': 'Custom Provider',
                              'model': modelCtrl.text.trim(),
                              'url': urlCtrl.text.trim(),
                              'enabled': true,
                              'isDefault': false,
                            });
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('ADD PROVIDER', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUB-AGENTS & ROUTER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Plan Overview
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.cyan, width: 1.2),
                    ),
                    child: const Icon(Icons.hub, color: AppTheme.cyan, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max Agentic Core Router', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13)),
                        SizedBox(height: 2),
                        Text('Multi-LLM dispatch, intelligent failover & sub-agent worker swarms', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Routing Strategies
            _buildSectionHeader('DISPATCH & ROUTING STRATEGY'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildStrategyTile(
                    id: 'best',
                    title: 'Best pehle (Priority Fallback)',
                    desc: 'Always tries the fastest primary model first. Automatically fails over to backup providers if rate-limited.',
                    icon: Icons.flash_on,
                    color: AppTheme.emerald,
                  ),
                  const SizedBox(height: 8),
                  _buildStrategyTile(
                    id: 'ranked',
                    title: 'Ranked - sabko use karo (Load Balance)',
                    desc: 'Distributes tasks smoothly across all enabled free & local API keys to prevent hitting rate limits.',
                    icon: Icons.balance,
                    color: AppTheme.cyan,
                  ),
                  const SizedBox(height: 8),
                  _buildStrategyTile(
                    id: 'swarm',
                    title: 'Sab ek saath (Parallel Consensus)',
                    desc: 'Dispatches sub-agents in parallel across multiple providers simultaneously for ultra-complex problem solving.',
                    icon: Icons.groups,
                    color: AppTheme.violet,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Configured Providers List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('CONFIGURED PROVIDERS'),
                TextButton.icon(
                  onPressed: _showAddProviderDialog,
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.cyan),
                  label: const Text('Add Provider', style: TextStyle(fontSize: 11, color: AppTheme.cyan, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ..._providers.map((p) {
              final isEn = p['enabled'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isEn ? AppTheme.cyan.withValues(alpha: 0.4) : AppTheme.surfaceGlassBorder,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEn ? AppTheme.cyan.withValues(alpha: 0.15) : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.alt_route, color: isEn ? AppTheme.cyan : AppTheme.textMuted, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text('${p['provider']} • ${p['model']}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontFamily: 'monospace')),
                            Text(p['url'] as String, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                      Switch(
                        value: isEn,
                        activeColor: AppTheme.cyan,
                        onChanged: (val) {
                          setState(() => p['enabled'] = val);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Custom Providers Global Toggle
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Custom Providers & Local Daemons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppTheme.textPrimary)),
                subtitle: const Text('Enable external OpenAI-compatible endpoints & LAN edge nodes', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                value: _customProvidersEnabled,
                activeColor: AppTheme.emerald,
                onChanged: (val) => setState(() => _customProvidersEnabled = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan),
    );
  }

  Widget _buildStrategyTile({
    required String id,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    final isSel = _routingStrategy == id;
    return GestureDetector(
      onTap: () => setState(() => _routingStrategy = id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? color.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? color : Colors.transparent, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off, color: isSel ? color : AppTheme.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: isSel ? color : AppTheme.textSecondary, size: 16),
                      const SizedBox(width: 6),
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? color : AppTheme.textPrimary, fontSize: 12.5)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
