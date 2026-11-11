import 'package:flutter/material.dart';
import '../../services/update_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.instance.checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SYSTEM & APP UPDATE',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.cyan),
            tooltip: 'Check Now',
            onPressed: () => UpdateService.instance.checkForUpdates(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: UpdateService.instance,
          builder: (context, _) {
            final service = UpdateService.instance;
            final update = service.latestUpdate;
            final isChecking = service.isChecking;
            final isDownloading = service.isDownloading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Current Installed Version Header
                  GlassPanel(
                    borderColor: AppTheme.cyan.withValues(alpha: 0.35),
                    backgroundColor: const Color(0xFF0A0F1D),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cyan.withValues(alpha: 0.15),
                            border: Border.all(color: AppTheme.cyan, width: 1.5),
                          ),
                          child: const Icon(Icons.system_update_rounded, color: AppTheme.cyan, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MAX AI COCKPIT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textMuted,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Current Version: ${UpdateService.currentVersion}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isChecking
                                    ? 'Checking repository for updates...'
                                    : (update != null && update.hasUpdate)
                                        ? '⚠️ New update available!'
                                        : '✓ App is currently up to date.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: (update != null && update.hasUpdate)
                                      ? AppTheme.amber
                                      : AppTheme.emerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2. Checking Spinner
                  if (isChecking) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(AppTheme.cyan),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Querying GitHub Releases...',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (update != null) ...[
                    // 3. Update Card
                    GlassPanel(
                      borderColor: update.hasUpdate
                          ? AppTheme.amber.withValues(alpha: 0.5)
                          : AppTheme.emerald.withValues(alpha: 0.3),
                      backgroundColor: const Color(0xFF060913),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    update.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Release Tag: ${update.tagName}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: AppTheme.cyan,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (update.hasUpdate ? AppTheme.amber : AppTheme.emerald)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: update.hasUpdate ? AppTheme.amber : AppTheme.emerald,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  update.hasUpdate ? 'UPDATE READY' : 'LATEST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: update.hasUpdate ? AppTheme.amber : AppTheme.emerald,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // File Size & Metadata
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                'File: ${update.apkFileName} (${update.formattedSize})',
                                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 8),

                          const Text(
                            'WHAT\'S NEW IN THIS UPDATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: AppTheme.cyan,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              update.releaseNotes.trim().isEmpty
                                  ? 'No detailed release notes provided.'
                                  : update.releaseNotes.trim(),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Download progress bar
                          if (isDownloading) ...[
                            LinearProgressIndicator(
                              value: service.downloadProgress,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(AppTheme.cyan),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                service.statusMessage,
                                style: const TextStyle(fontSize: 11, color: AppTheme.cyan),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Action Buttons
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () async {
                                      if (update.hasUpdate || update.apkDownloadUrl.isNotEmpty) {
                                        await service.downloadAndInstallUpdate(update);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('App is already on the latest build!')),
                                        );
                                      }
                                    },
                              icon: Icon(
                                isDownloading ? Icons.downloading : Icons.system_update_alt_rounded,
                                color: Colors.black,
                              ),
                              label: Text(
                                isDownloading
                                    ? 'DOWNLOADING UPDATE...'
                                    : (update.hasUpdate ? 'DOWNLOAD & INSTALL UPDATE' : 'RE-INSTALL LATEST BUILD'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: update.hasUpdate ? AppTheme.amber : AppTheme.cyan,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 4. Autonomous AI Update Info
                  GlassPanel(
                    borderColor: AppTheme.violet.withValues(alpha: 0.3),
                    backgroundColor: AppTheme.violet.withValues(alpha: 0.05),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, size: 18, color: AppTheme.violet),
                            SizedBox(width: 8),
                            Text(
                              'AUTONOMOUS AGENT UPDATE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: AppTheme.violet,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You can also command Max AI directly in Chat or Voice:\n'
                          '• "Max, check for updates"\n'
                          '• "আনার কোনো নতুন আপডেট আছে কিনা চেক করো"\n'
                          '• "Download and install latest update"\n\n'
                          'Max AI will automatically query GitHub, download the signed APK in the background, and open the system installer popup.',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.45),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Manual Check Button
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: isChecking ? null : () => service.checkForUpdates(),
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('RE-CHECK GITHUB RELEASES'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.cyan,
                        side: BorderSide(color: AppTheme.cyan.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
