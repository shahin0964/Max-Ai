import 'package:flutter/material.dart';
import '../../services/ai_engine_service.dart';
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
  bool _isProcessing = false;
  String? _documentSummary;

  Future<void> _analyzeDocument() async {
    final text = _docTextController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _documentSummary = null;
    });

    final question = _questionController.text.trim();
    final prompt = question.isNotEmpty
        ? 'Based on this document, answer the question: "$question"\n\nDocument Content:\n$text'
        : 'Analyze and summarize this document thoroughly. Extract key findings, action items, critical metrics, and executive summary:\n\n$text';

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
  void dispose() {
    _docTextController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCUMENTS & KNOWLEDGE HUB'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Paste Text / Document Excerpt', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      TextButton.icon(
                        onPressed: () {
                          _docTextController.text =
                              'OpenJarvis Autonomous System Specification v2.4\n'
                              'Key Capabilities:\n'
                              '1. Autonomous Task ReAct Execution Loop\n'
                              '2. Long-term Episodic Vector Memory\n'
                              '3. Multimodal Vision Inspection & OCR\n'
                              '4. Offline LAN Edge Daemon Support';
                        },
                        icon: const Icon(Icons.insert_drive_file, size: 14, color: AppTheme.cyan),
                        label: const Text('Sample Doc', style: TextStyle(fontSize: 11, color: AppTheme.cyan)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _docTextController,
                    maxLines: 5,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      hintText: 'Paste document, contract, study notes or technical paper text here...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ask Specific Question (Optional)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _questionController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      hintText: 'e.g. What are the key deliverables and deadlines?',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _analyzeDocument,
                    icon: _isProcessing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.document_scanner, size: 18),
                    label: Text(_isProcessing ? 'ANALYZING DOCUMENT...' : 'PROCESS & SUMMARIZE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            if (_documentSummary != null) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text('DOCUMENT SYNTHESIS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.cyan)),
              ),
              GlassPanel(
                borderColor: AppTheme.cyan.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  _documentSummary!,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.45),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
