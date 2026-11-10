import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class SubAgentsScreen extends StatefulWidget {
  const SubAgentsScreen({super.key});

  @override
  State<SubAgentsScreen> createState() => _SubAgentsScreenState();
}

class _SubAgentsScreenState extends State<SubAgentsScreen> {
  late String _routingStrategy;
  late bool _customProvidersEnabled;
  final Map<int, String> _providerPingStatus = {};
  final Map<int, bool> _isPinging = {};

  @override
  void initState() {
    super.initState();
    final s = SettingsService.instance;
    _routingStrategy = s.routerStrategy;
    _customProvidersEnabled = s.customProvidersEnabled;
  }

  Future<void> _pingProvider(int index, String url, String apiKey) async {
    setState(() {
      _isPinging[index] = true;
      _providerPingStatus[index] = 'Pinging...';
    });

    final stopwatch = Stopwatch()..start();
    try {
      var targetUrl = url.trim();
      if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
        targetUrl = 'http://$targetUrl';
      }
      
      // Attempt endpoint check (/models or base)
      Uri checkUri;
      if (targetUrl.endsWith('/v1')) {
        checkUri = Uri.parse('$targetUrl/models');
      } else {
        checkUri = Uri.parse(targetUrl);
      }

      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (apiKey.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${apiKey.trim()}';
      }

      final res = await http.get(checkUri, headers: headers).timeout(const Duration(seconds: 5));
      stopwatch.stop();

      final latency = stopwatch.elapsedMilliseconds;
      setState(() {
        _isPinging[index] = false;
        if (res.statusCode >= 200 && res.statusCode < 300) {
          _providerPingStatus[index] = 'Online (${latency}ms • HTTP ${res.statusCode})';
        } else if (res.statusCode == 401 || res.statusCode == 403) {
          _providerPingStatus[index] = 'Reachable (${latency}ms • Auth Error)';
        } else {
          _providerPingStatus[index] = 'HTTP ${res.statusCode} (${latency}ms)';
        }
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isPinging[index] = false;
        _providerPingStatus[index] = 'Offline: ${e.toString().split(':').last.trim()}';
      });
    }
  }

  void _showAddProviderDialog() {
    final tagCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'http://127.0.0.1:11434/v1');
    final modelCtrl = TextEditingController(text: 'qwen2.5:7b');
    final keyCtrl = TextEditingController();
    String? pingResult;
    bool pinging = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                    labelText: 'Provider Tag (e.g. My Local Ollama, Groq, DeepSeek)',
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
                    labelText: 'Model Identifier (e.g. llama-3.3, qwen2.5-coder)',
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
                if (pingResult != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: pingResult!.startsWith('Online') ? AppTheme.emerald.withValues(alpha: 0.15) : AppTheme.rose.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: pingResult!.startsWith('Online') ? AppTheme.emerald : AppTheme.rose,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          pingResult!.startsWith('Online') ? Icons.check_circle : Icons.error_outline,
                          color: pingResult!.startsWith('Online') ? AppTheme.emerald : AppTheme.rose,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pingResult!,
                            style: TextStyle(
                              fontSize: 11,
                              color: pingResult!.startsWith('Online') ? AppTheme.emerald : AppTheme.rose,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: pinging
                            ? null
                            : () async {
                                setSheetState(() {
                                  pinging = true;
                                  pingResult = 'Testing endpoint ping...';
                                });
                                final sw = Stopwatch()..start();
                                try {
                                  var u = urlCtrl.text.trim();
                                  if (!u.startsWith('http://') && !u.startsWith('https://')) {
                                    u = 'http://$u';
                                  }
                                  final uri = u.endsWith('/v1') ? Uri.parse('$u/models') : Uri.parse(u);
                                  final headers = <String, String>{'Accept': 'application/json'};
                                  if (keyCtrl.text.trim().isNotEmpty) {
                                    headers['Authorization'] = 'Bearer ${keyCtrl.text.trim()}';
                                  }
                                  final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 4));
                                  sw.stop();
                                  setSheetState(() {
                                    pinging = false;
                                    pingResult = 'Online (${sw.elapsedMilliseconds}ms • HTTP ${res.statusCode})';
                                  });
                                } catch (e) {
                                  sw.stop();
                                  setSheetState(() {
                                    pinging = false;
                                    pingResult = 'Ping Failed: ${e.toString().split(':').last.trim()}';
                                  });
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.emerald),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          pinging ? 'TESTING...' : 'TEST PING',
                          style: const TextStyle(color: AppTheme.emerald, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final tag = tagCtrl.text.trim();
                          if (tag.isNotEmpty) {
                            final newProvider = {
                              'name': tag,
                              'provider': 'Custom Provider',
                              'model': modelCtrl.text.trim().isEmpty ? 'default' : modelCtrl.text.trim(),
                              'url': urlCtrl.text.trim(),
                              'apiKey': keyCtrl.text.trim(),
                              'enabled': true,
                              'isDefault': false,
                            };
                            SettingsService.instance.addCustomProvider(newProvider);
                            Navigator.pop(ctx);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Provider "$tag" registered & saved successfully!'),
                                backgroundColor: AppTheme.emerald,
                              ),
                            );
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providers = SettingsService.instance.customProviders;

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
                _buildSectionHeader('CONFIGURED PROVIDERS (${providers.length})'),
                TextButton.icon(
                  onPressed: _showAddProviderDialog,
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.cyan),
                  label: const Text('Add Provider', style: TextStyle(fontSize: 11, color: AppTheme.cyan, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            for (int i = 0; i < providers.length; i++) ...[
              _buildProviderCard(i, providers[i]),
            ],

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
                onChanged: (val) {
                  setState(() => _customProvidersEnabled = val);
                  SettingsService.instance.setCustomProvidersEnabled(val);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(int index, Map<String, dynamic> p) {
    final isEn = (p['enabled'] as bool?) ?? true;
    final isDefault = (p['isDefault'] as bool?) ?? false;
    final pingStatus = _providerPingStatus[index];
    final isPingingNow = _isPinging[index] ?? false;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.cyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('CORE', style: TextStyle(fontSize: 8, color: AppTheme.cyan, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
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
                    setState(() {
                      SettingsService.instance.toggleCustomProvider(index, val);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: isPingingNow
                      ? null
                      : () => _pingProvider(index, p['url'] as String, (p['apiKey'] as String?) ?? ''),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.surfaceGlassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPingingNow)
                          const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.cyan))
                        else
                          const Icon(Icons.wifi_tethering, size: 12, color: AppTheme.cyan),
                        const SizedBox(width: 4),
                        Text(
                          isPingingNow ? 'PINGING...' : 'PING TEST',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.cyan),
                        ),
                      ],
                    ),
                  ),
                ),
                if (pingStatus != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pingStatus,
                      style: TextStyle(
                        fontSize: 10,
                        color: pingStatus.startsWith('Online')
                            ? AppTheme.emerald
                            : pingStatus.startsWith('Reachable')
                                ? AppTheme.amber
                                : AppTheme.rose,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                if (!isDefault) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.rose),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      SettingsService.instance.removeCustomProvider(index);
                      setState(() {});
                    },
                  ),
                ],
              ],
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
      onTap: () {
        setState(() => _routingStrategy = id);
        SettingsService.instance.setRouterStrategy(id);
      },
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
