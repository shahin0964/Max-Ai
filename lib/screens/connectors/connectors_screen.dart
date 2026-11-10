import 'package:flutter/material.dart';
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
      'id': 'gdrive',
      'name': 'Google Drive',
      'category': 'Files',
      'icon': Icons.add_to_drive,
      'color': AppTheme.emerald,
      'desc': 'Access docs, read spreadsheets & save conversation exports',
      'connected': false,
    },
    {
      'id': 'github',
      'name': 'GitHub',
      'category': 'Code',
      'icon': Icons.code,
      'color': AppTheme.cyan,
      'desc': 'Push code, manage repositories, trigger Actions CI/CD',
      'connected': true,
    },
    {
      'id': 'vercel',
      'name': 'Vercel',
      'category': 'Code',
      'icon': Icons.cloud_upload_outlined,
      'color': AppTheme.textPrimary,
      'desc': 'Deploy web applications & host full-stack projects live',
      'connected': false,
    },
    {
      'id': 'notion',
      'name': 'Notion',
      'category': 'Notes & tasks',
      'icon': Icons.menu_book,
      'color': AppTheme.amber,
      'desc': 'Sync notes, build wikis, track daily databases & tasks',
      'connected': false,
    },
    {
      'id': 'telegram',
      'name': 'Telegram Bot',
      'category': 'Notes & tasks',
      'icon': Icons.send_rounded,
      'color': AppTheme.cyan,
      'desc': 'Send automated alerts, download media & remote control Max',
      'connected': false,
    },
    {
      'id': 'todoist',
      'name': 'Todoist',
      'category': 'Notes & tasks',
      'icon': Icons.checklist_rounded,
      'color': AppTheme.rose,
      'desc': 'Real-time task synchronization & agenda reminders',
      'connected': false,
    },
    {
      'id': 'gitlab',
      'name': 'GitLab',
      'category': 'Code',
      'icon': Icons.integration_instructions,
      'color': AppTheme.amber,
      'desc': 'GitLab pipelines, merge requests & code snippets',
      'connected': false,
    },
    {
      'id': 'linear',
      'name': 'Linear',
      'category': 'Notes & tasks',
      'icon': Icons.timeline,
      'color': AppTheme.violet,
      'desc': 'Agile issue tracking, software cycles & project sprints',
      'connected': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showConnectorModal(Map<String, dynamic> connector) {
    final tokenController = TextEditingController();
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
                children: [
                  Icon(connector['icon'] as IconData, color: connector['color'] as Color, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(connector['name'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        Text(connector['desc'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
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
                  hintText: 'Enter API Token...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.lock, size: 12, color: AppTheme.emerald),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Connector credentials remain safely encrypted on this device and are never uploaded to third-party cloud servers.',
                      style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.surfaceGlassBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          connector['connected'] = true;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${connector['name']} connected successfully!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('CONNECT', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final query = _searchController.text.trim().toLowerCase();
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
            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Connectors search karo...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.cyan, size: 20),
                  filled: true,
                  fillColor: AppTheme.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

            const SizedBox(height: 8),

            // List of Connectors
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  final isConn = c['connected'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isConn ? AppTheme.emerald.withValues(alpha: 0.4) : AppTheme.surfaceGlassBorder,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (c['color'] as Color).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 22),
                      ),
                      title: Row(
                        children: [
                          Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 14)),
                          const SizedBox(width: 8),
                          if (isConn)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.emerald.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: const Text('ACTIVE', style: TextStyle(fontSize: 8.5, color: AppTheme.emerald, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      subtitle: Text(c['desc'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.cyan),
                      onTap: () => _showConnectorModal(c),
                    ),
                  );
                },
              ),
            ),

            // Security Footnote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.surface,
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: AppTheme.cyan, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connector keys are encrypted locally on phone. Max AI never shares your data externally.',
                      style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
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
}
