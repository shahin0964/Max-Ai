import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/ai_engine_service.dart';
import '../../services/skill_registry_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _docTextController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  String _analysisMode = 'Executive Summary & Action Items';
  bool _isProcessing = false;
  String? _documentSummary;

  final List<String> _modes = [
    'Executive Summary & Action Items',
    'Deep Q&A Chat Over Document',
    'Contract, Clauses & Legal Risk Review',
    'Technical Architecture & Code Extraction',
  ];

  @override
  void dispose() {
    _docTextController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _pasteClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _docTextController.text = data.text!;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pasted ${data.text!.length} characters from clipboard.'), backgroundColor: AppTheme.surfaceElevated),
        );
      }
    }
  }

  Future<void> _analyzeDocument() async {
    final text = _docTextController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _documentSummary = null;
    });

    final question = _questionController.text.trim();
    final prompt = '''
You are Max AI Elite Document & Knowledge Intelligence Specialist.

Mode: "$_analysisMode"
${question.isNotEmpty ? "Specific User Question: \"$question\"\n" : ""}
Document Content (${text.length} characters):
\"\"\"
$text
\"\"\"

Provide an institutional, well-structured analysis adhering to the selected Mode:
- Highlight critical takeaways
- Extract actionable steps and dependencies
- Identify ambiguities, risks, or key metrics
''';

    try {
      final reply = await AIEngineService.instance.sendMessage(prompt: prompt);
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _documentSummary = reply;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _documentSummary = 'Document Analysis Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCUMENTS & KNOWLEDGE HUB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.paste, color: AppTheme.cyan),
            tooltip: 'Paste from Clipboard',
            onPressed: _pasteClipboard,
          ),
          if (_documentSummary != null)
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.cyan),
              tooltip: 'Copy Analysis',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _documentSummary!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analysis copied to clipboard!')),
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
            final isSkillInstalled = SkillRegistryService.instance.isSkillInstalled('docs_intelligence');

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
                            'Document & PDF Intelligence skill is uninstalled. Deep document reasoning is restricted.',
                            style: TextStyle(color: AppTheme.amber, fontSize: 11),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => SkillRegistryService.instance.installSkill('docs_intelligence'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                          child: const Text('INSTALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mode Selector
                      const Text('Intelligence Mode', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _analysisMode,
                            isExpanded: true,
                            dropdownColor: AppTheme.surfaceElevated,
                            items: _modes.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12.5, color: AppTheme.textPrimary)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _analysisMode = val);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Document Input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Paste Document / Contract Text', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text(
                            '${_docTextController.text.length} chars',
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.cyan),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _docTextController,
                        maxLines: 7,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12.5),
                        decoration: InputDecoration(
                          hintText: 'Paste contract clauses, technical specifications, scientific articles or project briefs here...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 12),

                      // Optional Specific Question
                      const Text('Specific Question / Inquiry (Optional)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _questionController,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12.5),
                        decoration: InputDecoration(
                          hintText: 'e.g. What are the termination clauses or payment terms?',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Analyze Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing || _docTextController.text.trim().isEmpty ? null : _analyzeDocument,
                          icon: _isProcessing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.psychology, size: 18),
                          label: Text(_isProcessing ? 'ANALYZING WITH MAX AI...' : 'PROCESS DOCUMENT WITH MAX AI', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Output Viewport
                if (_documentSummary != null) ...[
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppTheme.cyan, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'DOCUMENT INTELLIGENCE SYNTHESIS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassPanel(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppTheme.cyan.withValues(alpha: 0.3),
                    child: SelectableText(
                      _documentSummary!,
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
