import 'package:flutter/material.dart';
import '../../services/ai_engine_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _urlController = TextEditingController(text: 'https://news.ycombinator.com');
  bool _isLoading = false;
  String? _browserResult;

  Future<void> _browseAndResearch() async {
    final target = _urlController.text.trim();
    if (target.isEmpty) return;

    setState(() {
      _isLoading = true;
      _browserResult = null;
    });

    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: 'You are Max AI Autonomous Web Agent and Research Browser. Browse, search, and extract key information regarding: "$target". Summarize headlines, essential insights, links, and actionable data.',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _browserResult = reply;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _browserResult = 'Browser Research Error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTONOMOUS AI BROWSER'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // URL / Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: AppTheme.surfaceElevated,
              child: Row(
                children: [
                  const Icon(Icons.public, color: AppTheme.cyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        hintText: 'Enter URL or search topic...',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _browseAndResearch(),
                    ),
                  ),
                  IconButton(
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyan))
                        : const Icon(Icons.arrow_forward, color: AppTheme.cyan),
                    onPressed: _browseAndResearch,
                  ),
                ],
              ),
            ),

            // Browser Content Viewport
            Expanded(
              child: _browserResult != null
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'LIVE RESEARCH & EXTRACTED DATA',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.emerald),
                          ),
                        ),
                        GlassPanel(
                          borderColor: AppTheme.emerald.withValues(alpha: 0.3),
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            _browserResult!,
                            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.45),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.travel_explore, size: 48, color: AppTheme.cyan.withValues(alpha: 0.4)),
                          const SizedBox(height: 14),
                          const Text(
                            'Autonomous Web Research Engine',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter any topic or website URL to let Max AI\nscrape, summarize, and extract live intelligence.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
