import 'package:flutter/material.dart';
import '../../services/ai_engine_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key});

  @override
  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedContentType = 'Instagram Viral Reel / Post';
  bool _isGenerating = false;
  String? _generatedContent;

  final List<String> _contentTypes = [
    'Instagram Viral Reel / Post',
    'YouTube High-CTR Title & Script',
    'LinkedIn Thought Leadership Hook',
    'Facebook Ad Copy with High Conversion',
    'TikTok Short Viral Hook',
    'Brand Tagline & Slogans',
  ];

  Future<void> _generateMarketingCopy() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedContent = null;
    });

    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: 'You are Max AI Elite Growth Marketer and Copywriter. Create world-class, punchy, high-converting content for: "$topic" in format: "$_selectedContentType". Include attention-grabbing hooks, compelling value, call-to-action (CTA), and relevant viral hashtags.',
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedContent = reply;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedContent = 'Generation error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKETING & CONTENT STUDIO'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Content Type & Channel', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedContentType,
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceElevated,
                        items: _contentTypes.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedContentType = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Topic, Product or Campaign Focus', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _topicController,
                    maxLines: 3,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      hintText: 'e.g., Launch of new high-tech autonomous AI robot, 50% discount, targeting developers...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateMarketingCopy,
                    icon: _isGenerating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(_isGenerating ? 'GENERATING COPY...' : 'GENERATE VIRAL CONTENT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            if (_generatedContent != null) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text('AI MARKETING DRAFT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.amber)),
              ),
              GlassPanel(
                borderColor: AppTheme.amber.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  _generatedContent!,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
