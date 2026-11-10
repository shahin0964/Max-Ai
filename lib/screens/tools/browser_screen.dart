import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../services/ai_engine_service.dart';
import '../../services/skill_registry_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final TextEditingController _urlController = TextEditingController(text: 'https://news.ycombinator.com');
  final TextEditingController _questionController = TextEditingController();

  bool _isLoading = false;
  String? _scrapedRawText;
  String? _browserResult;
  String? _httpStatus;
  bool _showRawText = false;

  @override
  void dispose() {
    _urlController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  String _cleanHtml(String html) {
    // Strip scripts and styles
    String text = html.replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ');
    text = text.replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ');
    text = text.replaceAll(RegExp(r'<nav[\s\S]*?</nav>', caseSensitive: false), ' ');
    text = text.replaceAll(RegExp(r'<header[\s\S]*?</header>', caseSensitive: false), ' ');
    text = text.replaceAll(RegExp(r'<footer[\s\S]*?</footer>', caseSensitive: false), ' ');

    // Strip HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');

    // Decode basic HTML entities
    text = text.replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // Clean whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  Future<void> _browseAndResearch() async {
    String input = _urlController.text.trim();
    if (input.isEmpty) return;

    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }

    setState(() {
      _isLoading = true;
      _scrapedRawText = null;
      _browserResult = null;
      _httpStatus = 'Connecting to $input...';
    });

    try {
      final uri = Uri.parse(input);
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 14; MaxAI/2.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Mobile Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 15));

      final cleanContent = _cleanHtml(response.body);
      final truncatedForPrompt = cleanContent.length > 8000 ? cleanContent.substring(0, 8000) : cleanContent;

      setState(() {
        _httpStatus = 'HTTP ${response.statusCode} (${response.bodyBytes.length} bytes received)';
        _scrapedRawText = cleanContent;
      });

      final question = _questionController.text.trim();
      final aiPrompt = '''
You are Max AI Autonomous Web Agent and Research Browser.
You just scraped a live webpage via HTTP client.

Target URL: "$input"
HTTP Status: ${response.statusCode}
${question.isNotEmpty ? "User Question: \"$question\"\n" : ""}
Scraped Content Excerpt:
\"\"\"
$truncatedForPrompt
\"\"\"

Task:
1. Provide an executive summary of this webpage.
2. Extract the primary news headlines, key facts, data figures, or links.
3. Highlight actionable takeaways or insights.
''';

      final reply = await AIEngineService.instance.sendMessage(prompt: aiPrompt);

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
          _httpStatus = 'Error connecting to $input';
          _browserResult = 'Browser scraping failed: $e\n\nCheck the URL or internet connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTONOMOUS AI BROWSER'),
        actions: [
          if (_browserResult != null)
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.emerald),
              tooltip: 'Copy Research Findings',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _browserResult!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Research findings copied!')),
                );
              },
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SkillRegistryService.instance,
          builder: (context, _) {
            final isSkillInstalled = SkillRegistryService.instance.isSkillInstalled('web_scraper');

            return Column(
              children: [
                // Skill check banner
                if (!isSkillInstalled)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.amber, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.amber, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Web Search & Deep Page Scraper skill is uninstalled.',
                            style: TextStyle(color: AppTheme.amber, fontSize: 11),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => SkillRegistryService.instance.installSkill('web_scraper'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                          child: const Text('INSTALL', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // URL Navigation Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
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
                            hintText: 'Enter URL (e.g. news.ycombinator.com)...',
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
                        onPressed: _isLoading ? null : _browseAndResearch,
                      ),
                    ],
                  ),
                ),

                // Status Strip
                if (_httpStatus != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: AppTheme.surface,
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _httpStatus!.contains('200') ? AppTheme.emerald : AppTheme.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_httpStatus!, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.textSecondary)),
                        ),
                        if (_scrapedRawText != null)
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
                            onPressed: () => setState(() => _showRawText = !_showRawText),
                            child: Text(
                              _showRawText ? 'Hide HTML' : 'View Text',
                              style: const TextStyle(fontSize: 10, color: AppTheme.cyan),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Content Viewport
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Raw Scraped Text Viewport (Optional Toggle)
                      if (_showRawText && _scrapedRawText != null) ...[
                        const Text('RAW SCRAPED CLEAN TEXT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.cyan, letterSpacing: 1.2)),
                        const SizedBox(height: 6),
                        Container(
                          maxHeight: 180,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.surfaceGlassBorder),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _scrapedRawText!,
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppTheme.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Max AI Synthesis
                      if (_browserResult != null) ...[
                        const Row(
                          children: [
                            Icon(Icons.travel_explore, color: AppTheme.emerald, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'AUTONOMOUS AGENT SYNTHESIS',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.emerald),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GlassPanel(
                          padding: const EdgeInsets.all(14),
                          borderColor: AppTheme.emerald.withValues(alpha: 0.3),
                          child: SelectableText(
                            _browserResult!,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.5),
                          ),
                        ),
                      ] else if (!_isLoading)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.language, size: 48, color: AppTheme.cyan.withValues(alpha: 0.3)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Enter any website URL to autonomously scrape and research',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
