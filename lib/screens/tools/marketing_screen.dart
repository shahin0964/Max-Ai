import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/ai_engine_service.dart';
import '../../services/skill_registry_service.dart';
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
  String _selectedTone = 'Viral & Punchy';
  bool _isGenerating = false;
  String? _generatedContent;

  final List<String> _contentTypes = [
    'Instagram Viral Reel / Post',
    'YouTube High-CTR Title & Script',
    'LinkedIn Thought Leadership Hook',
    'Facebook / Meta High-Conversion Ad',
    'TikTok Short 3-Second Viral Hook',
    'Email Newsletter Pitch & Call-to-Action',
    'Brand Slogan & Positioning Matrix',
  ];

  final List<String> _tones = [
    'Viral & Punchy',
    'Authoritative & Professional',
    'Casual & Storytelling',
    'Urgent & Scarcity',
    'Humorous & Relatable',
  ];

  final List<String> _quickPrompts = [
    'AI Mobile Assistant Launch',
    'Fitness Transformation Challenge',
    'Tech Startup SaaS Growth',
    'E-commerce Flash Sale 50% Off',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateMarketingCopy() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedContent = null;
    });

    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: '''
You are Max AI Elite Growth Marketer and Copywriting Strategist.
Create world-class, production-ready content.

Topic: "$topic"
Format: "$_selectedContentType"
Tone: "$_selectedTone"

Structure your response into:
1. 🎯 PRIMARY HOOKS (Give 3 compelling variations)
2. 📝 MAIN CONTENT BODY / SCRIPT (Pacing, scene cues, value delivery)
3. ⚡ CALL TO ACTION (CTA) (High friction-removal)
4. 🏷️ OPTIMAL VIRAL HASHTAGS (High volume & niche blend)

Make it immediately postable and impactful.
''',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MARKETING & CONTENT STUDIO'),
        actions: [
          if (_generatedContent != null)
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.amber),
              tooltip: 'Copy Generated Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _generatedContent!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copy copied to clipboard!'), backgroundColor: AppTheme.surfaceElevated),
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
            final isSkillInstalled = SkillRegistryService.instance.isSkillInstalled('marketing_studio');

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Skill check banner
                if (!isSkillInstalled)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.amber, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.amber, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Marketing & Viral Copywriter skill is uninstalled. Content generator is restricted.',
                            style: TextStyle(color: AppTheme.amber, fontSize: 11),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => SkillRegistryService.instance.installSkill('marketing_studio'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                          child: const Text('INSTALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                // Controls Panel
                GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content Type Dropdown
                      const Text('Target Platform / Channel', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
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

                      // Tone Dropdown
                      const Text('Copywriting Tone', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTone,
                            isExpanded: true,
                            dropdownColor: AppTheme.surfaceElevated,
                            items: _tones.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedTone = val);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Topic Input
                      const Text('Product, Campaign, or Hook Idea', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _topicController,
                        maxLines: 2,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'e.g. Next-gen autonomous AI coding app that runs on Android Termux',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Quick Prompt Chips
                      SizedBox(
                        height: 30,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickPrompts.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (ctx, i) {
                            final p = _quickPrompts[i];
                            return ActionChip(
                              label: Text(p, style: const TextStyle(fontSize: 10, color: AppTheme.cyan)),
                              backgroundColor: AppTheme.surface,
                              side: const BorderSide(color: AppTheme.surfaceGlassBorder),
                              onPressed: () {
                                _topicController.text = p;
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateMarketingCopy,
                          icon: _isGenerating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.bolt, size: 18),
                          label: Text(_isGenerating ? 'GENERATING WITH MAX AI...' : 'GENERATE HIGH-CONVERTING COPY', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Generated Output
                if (_generatedContent != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppTheme.amber, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'GENERATED PRODUCTION CAMPAIGN',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.amber),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 18, color: AppTheme.textMuted),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedContent!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Content copied for publishing!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassPanel(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppTheme.amber.withValues(alpha: 0.3),
                    child: SelectableText(
                      _generatedContent!,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12.5, height: 1.5),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
