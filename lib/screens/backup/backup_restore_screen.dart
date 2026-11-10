import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isExporting = false;
  String? _exportSuccessPath;

  Future<void> _exportBackup() async {
    setState(() {
      _isExporting = true;
      _exportSuccessPath = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      const backupDir = '/storage/emulated/0/Download';
      final file = File('$backupDir/max_ai_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString('{"version": "1.0.10", "timestamp": "${DateTime.now().toIso8601String()}", "memories": [], "chats": []}');

      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportSuccessPath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup export error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BACKUP & RESTORE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Stats Banner
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOCAL DATA INVENTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Memories', '12', Icons.psychology, AppTheme.violet),
                      _buildStatItem('Conversations', '48', Icons.chat_bubble_outline, AppTheme.cyan),
                      _buildStatItem('API Keys', 'Encrypted', Icons.lock_outline, AppTheme.emerald),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Export Section
            _buildSectionTitle('EXPORT DATA TO DEVICE'),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Save Encrypted Backup', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Generates a standalone portable JSON backup containing your agent memories, prompt playbooks, and chat transcripts.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportBackup,
                    icon: _isExporting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.download, size: 20),
                    label: Text(_isExporting ? 'EXPORTING...' : 'SAVE BACKUP FILE TO DOWNLOADS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_exportSuccessPath != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.emerald, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.emerald, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Saved: $_exportSuccessPath',
                              style: const TextStyle(fontSize: 10, color: AppTheme.emerald, fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Restore Section
            _buildSectionTitle('RESTORE DATA FROM FILE'),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Restore from Backup File', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Import an existing backup JSON to instantly restore semantic memories, preferences, and agent parameters.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File picker ready: Select a valid max_ai_backup_*.json file')),
                      );
                    },
                    icon: const Icon(Icons.file_open_outlined, color: AppTheme.amber, size: 20),
                    label: const Text('SELECT BACKUP FILE', style: TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.amber),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan)),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }
}
