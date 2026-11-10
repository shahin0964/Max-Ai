import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class ConnectorsScreen extends StatefulWidget {
  const ConnectorsScreen({super.key});

  @override
  State<ConnectorsScreen> createState() => _ConnectorsScreenState();
}

class _ConnectorsScreenState extends State<ConnectorsScreen> {
  String _activeFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Files', 'Code', 'Notes & tasks'];

  final List<Map<String, dynamic>> _connectors = [
    {
      'id': 'github',
      'name': 'GitHub',
      'category': 'Code',
      'icon': Icons.code,
      'color': AppTheme.cyan,
      'desc': 'Push code, manage repositories & trigger Actions CI/CD',
      'tokenPlaceholder': 'ghp_xxxxxxxxxxxxxxxxxxxx',
    },
    {
      'id': 'telegram',
      'name': 'Telegram Bot',
      'category': 'Notes & tasks',
      'icon': Icons.send_rounded,
      'color': AppTheme.cyan,
      'desc': 'Send automated alerts, download media & remote control Max',
      'tokenPlaceholder': '123456789:ABC-DEF1234ghIkl-zyx57W2v1u123ew11',
    },
    {
      'id': 'vercel',
      'name': 'Vercel',
      'category': 'Code',
      'icon': Icons.cloud_upload_outlined,
      'color': AppTheme.textPrimary,
      'desc': 'Deploy web applications & host full-stack projects live',
      'tokenPlaceholder': 'vercel_token_xxxxxxxxxxxx',
    },
    {
      'id': 'notion',
      'name': 'Notion',
      'category': 'Notes & tasks',
      'icon': Icons.menu_book,
      'color': AppTheme.amber,
      'desc': 'Sync notes, build wikis, track daily databases & tasks',
      'tokenPlaceholder': 'secret_xxxxxxxxxxxxxxxxxxxx',
    },
    {
      'id': 'gdrive',
      'name': 'Google Drive',
      'category': 'Files',
      'icon': Icons.add_to_drive,
      'color': AppTheme.emerald,
      'desc': 'Access docs, read spreadsheets & save conversation exports',
      'tokenPlaceholder': 'ya29.a0xxxxxxxxxxxxxxxxxxxx',
    },
    {
      'id': 'todoist',
      'name': 'Todoist',
      'category': 'Notes & tasks',
      'icon': Icons.checklist_rounded,
      'color': AppTheme.rose,
      'desc': 'Real-time task synchronization & agenda reminders',
      'tokenPlaceholder': 'todoist_api_token_xxxxxxxx',
    },
    {
      'id': 'gitlab',
      'name': 'GitLab',
      'category': 'Code',
      'icon': Icons.integration_instructions,
      'color': AppTheme.amber,
      'desc': 'GitLab pipelines, merge requests & code snippets',
      'tokenPlaceholder': 'glpat-xxxxxxxxxxxxxxxxxxxx',
    },
    {
      'id': 'linear',
      'name': 'Linear',
      'category': 'Notes & tasks',
      'icon': Icons.timeline,
      'color': AppTheme.violet,
      'desc': 'Agile issue tracking, software cycles & project sprints',
      'tokenPlaceholder': 'lin_api_xxxxxxxxxxxxxxxxxxxx',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _verifyTokenWithLiveApi(String id, String token) async {
    final clean = token.trim();
    if (clean.isEmpty) {
      return {'success': false, 'error': 'Token cannot be empty'};
    }

    try {
      if (id == 'github') {
        final res = await http.get(
          Uri.parse('https://api.github.com/user'),
          headers: {
            'Authorization': 'Bearer $clean',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'MaxAI-App',
          },
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final login = data['login'] ?? 'user';
          return {'success': true, 'account': '@$login'};
        } else {
          return {'success': false, 'error': 'GitHub HTTP ${res.statusCode}: Bad credentials'};
        }
      } else if (id == 'telegram') {
        final res = await http.get(
          Uri.parse('https://api.telegram.org/bot$clean/getMe'),
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          if (data['ok'] == true) {
            final user = data['result']?['username'] ?? 'bot';
            return {'success': true, 'account': '@$user'};
          }
        }
        return {'success': false, 'error': 'Invalid Telegram Bot Token'};
      } else if (id == 'notion') {
        final res = await http.get(
          Uri.parse('https://api.notion.com/v1/users/me'),
          headers: {
            'Authorization': 'Bearer $clean',
            'Notion-Version': '2022-06-28',
          },
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final name = data['name'] ?? 'Notion User';
          return {'success': true, 'account': name};
        } else {
          return {'success': false, 'error': 'Notion authentication failed (HTTP ${res.statusCode})'};
        }
      } else if (id == 'vercel') {
        final res = await http.get(
          Uri.parse('https://api.vercel.com/v2/user'),
          headers: {'Authorization': 'Bearer $clean'},
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final user = data['user']?['username'] ?? 'vercel_user';
          return {'success': true, 'account': '@$user'};
        } else {
          return {'success': false, 'error': 'Vercel HTTP ${res.statusCode}: Invalid token'};
        }
      } else if (id == 'gitlab') {
        final res = await http.get(
          Uri.parse('https://gitlab.com/api/v4/user'),
          headers: {'PRIVATE-TOKEN': clean},
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final user = data['username'] ?? 'gitlab_user';
          return {'success': true, 'account': '@$user'};
        } else {
          return {'success': false, 'error': 'GitLab HTTP ${res.statusCode}: Token unauthorized'};
        }
      } else if (id == 'todoist') {
        final res = await http.get(
          Uri.parse('https://api.todoist.com/rest/v2/projects'),
          headers: {'Authorization': 'Bearer $clean'},
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          return {'success': true, 'account': 'Verified User'};
        } else {
          return {'success': false, 'error': 'Todoist HTTP ${res.statusCode}'};
        }
      } else if (id == 'linear') {
        final res = await http.post(
          Uri.parse('https://api.linear.app/graphql'),
          headers: {
            'Authorization': clean,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'query': '{ viewer { id name } }'}),
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final name = data['data']?['viewer']?['name'] ?? 'Linear Developer';
          return {'success': true, 'account': name};
        } else {
          return {'success': false, 'error': 'Linear authentication failed'};
        }
      } else if (id == 'gdrive') {
        final res = await http.get(
          Uri.parse('https://www.googleapis.com/drive/v3/about?fields=user'),
          headers: {'Authorization': 'Bearer $clean'},
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final name = data['user']?['displayName'] ?? 'Google Account';
          return {'success': true, 'account': name};
        } else {
          return {'success': false, 'error': 'Google Drive OAuth token expired or invalid'};
        }
      } else {
        return {'success': true, 'account': 'Configured'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network connection failed: $e'};
    }
  }

  void _showConnectorModal(Map<String, dynamic> connector) {
    final id = connector['id'] as String;
    final config = SettingsService.instance.connectorsConfig[id] ?? {};
    final isConnected = (config['connected'] as bool?) ?? false;
    final currentToken = (config['token'] as String?) ?? '';
    final tokenController = TextEditingController(text: currentToken);

    String? statusMessage;
    bool isVerifying = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                  children: [
                    Icon(connector['icon'] as IconData, color: connector['color'] as Color, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(connector['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                              if (isConnected) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emerald.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('ACTIVE', style: TextStyle(fontSize: 9, color: AppTheme.emerald, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text(connector['desc'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: AppTheme.textMuted), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Personal Access Token / API Key', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: tokenController,
                  obscureText: true,
                  style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'monospace', fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surface,
                    hintText: connector['tokenPlaceholder'] as String? ?? 'Enter API Token...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                if (statusMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusMessage!.startsWith('Success') || statusMessage!.startsWith('Connected')
                          ? AppTheme.emerald.withValues(alpha: 0.15)
                          : AppTheme.rose.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusMessage!.startsWith('Success') || statusMessage!.startsWith('Connected')
                            ? AppTheme.emerald
                            : AppTheme.rose,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusMessage!.startsWith('Success') || statusMessage!.startsWith('Connected')
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: statusMessage!.startsWith('Success') || statusMessage!.startsWith('Connected')
                              ? AppTheme.emerald
                              : AppTheme.rose,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusMessage!,
                            style: TextStyle(
                              fontSize: 11,
                              color: statusMessage!.startsWith('Success') || statusMessage!.startsWith('Connected')
                                  ? AppTheme.emerald
                                  : AppTheme.rose,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.lock, size: 12, color: AppTheme.emerald),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Credentials remain encrypted on-device with hardware security keys and are never sent to third-party tracking servers.',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (isConnected) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            SettingsService.instance.disconnectConnector(id);
                            Navigator.pop(ctx);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${connector['name']} disconnected')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.rose),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('DISCONNECT', style: TextStyle(color: AppTheme.rose, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                final tok = tokenController.text.trim();
                                if (tok.isEmpty) {
                                  setModalState(() {
                                    statusMessage = 'Please enter an API Token or Access Key';
                                  });
                                  return;
                                }

                                setModalState(() {
                                  isVerifying = true;
                                  statusMessage = 'Connecting & verifying credentials...';
                                });

                                final res = await _verifyTokenWithLiveApi(id, tok);
                                if (res['success'] == true) {
                                  final account = res['account'] as String? ?? 'Verified';
                                  await SettingsService.instance.setConnectorToken(
                                    id,
                                    tok,
                                    accountName: account,
                                    connected: true,
                                  );
                                  setModalState(() {
                                    isVerifying = false;
                                    statusMessage = 'Connected successfully as $account!';
                                  });
                                  await Future.delayed(const Duration(milliseconds: 700));
                                  if (mounted) {
                                    Navigator.pop(ctx);
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${connector['name']} linked ($account)'),
                                        backgroundColor: AppTheme.emerald,
                                      ),
                                    );
                                  }
                                } else {
                                  setModalState(() {
                                    isVerifying = false;
                                    statusMessage = res['error'] as String? ?? 'Authentication failed';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isVerifying ? 'VERIFYING...' : (isConnected ? 'RE-VERIFY' : 'VERIFY & CONNECT'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
    final query = _searchController.text.trim().toLowerCase();
    final connectorsConfig = SettingsService.instance.connectorsConfig;

    final filtered = _connectors.where((c) {
      final matchesFilter = _activeFilter == 'All' || c['category'] == _activeFilter;
      final matchesQuery = query.isEmpty || (c['name'] as String).toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONNECTORS & ACCOUNTS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info & Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search Cloud & Dev Connectors...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.cyan, size: 20),
                      filled: true,
                      fillColor: AppTheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final isSel = _activeFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f, style: TextStyle(color: isSel ? Colors.black : AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                            selected: isSel,
                            selectedColor: AppTheme.cyan,
                            backgroundColor: AppTheme.surface,
                            onSelected: (_) => setState(() => _activeFilter = f),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  final id = c['id'] as String;
                  final conf = connectorsConfig[id] ?? {};
                  final isConn = (conf['connected'] as bool?) ?? false;
                  final accountName = (conf['accountName'] as String?) ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isConn ? AppTheme.cyan.withValues(alpha: 0.5) : AppTheme.surfaceGlassBorder,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (c['color'] as Color).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 22),
                      ),
                      title: Row(
                        children: [
                          Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppTheme.textPrimary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isConn ? AppTheme.emerald.withValues(alpha: 0.2) : AppTheme.surface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isConn ? 'CONNECTED' : 'DISCONNECTED',
                              style: TextStyle(
                                fontSize: 9,
                                color: isConn ? AppTheme.emerald : AppTheme.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(c['desc'] as String, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                          if (isConn && accountName.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text('Account: $accountName', style: const TextStyle(fontSize: 10, color: AppTheme.cyan, fontWeight: FontWeight.bold)),
                          ],
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isConn ? Icons.settings : Icons.link,
                          color: isConn ? AppTheme.cyan : AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => _showConnectorModal(c),
                      ),
                      onTap: () => _showConnectorModal(c),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
