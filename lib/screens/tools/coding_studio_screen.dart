import 'package:flutter/material.dart';
import '../../services/ai_engine_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class CodingStudioScreen extends StatefulWidget {
  const CodingStudioScreen({super.key});

  @override
  State<CodingStudioScreen> createState() => _CodingStudioScreenState();
}

class _CodingStudioScreenState extends State<CodingStudioScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _selectedLanguage = 'Flutter (Dart)';
  bool _isGenerating = false;
  String? _generatedCode;

  final List<String> _languages = [
    'Flutter (Dart)',
    'Python (FastAPI / PyTorch)',
    'Full-Stack Web (HTML/CSS/JS)',
    'Node.js / TypeScript',
    'Shell Script (Bash)',
    'Rust / C++',
  ];

  Future<void> _generateCode() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedCode = null;
    });

    try {
      final reply = await AIEngineService.instance.sendMessage(
        prompt: 'You are Max AI Principal Software Architect and Coding Engine. Write clean, production-grade, bug-free code for: "$prompt" using language: "$_selectedLanguage". Include architectural comments and implementation details.',
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedCode = reply;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedCode = 'Coding Engine Error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WEBSITE & CODING STUDIO'),
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
                  const Text('Target Tech Stack & Language', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceElevated,
                        items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLanguage = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Coding Goal / Specification', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _promptController,
                    maxLines: 4,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      hintText: 'e.g. Build a futuristic cyberpunk glowing audio visualizer widget with smooth 60fps animations...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateCode,
                    icon: _isGenerating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.code, size: 18),
                    label: Text(_isGenerating ? 'GENERATING ARCHITECTURE...' : 'GENERATE CODE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emerald,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            if (_generatedCode != null) ...[
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text('GENERATED CODE & ARCHITECTURE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.emerald)),
              ),
              GlassPanel(
                borderColor: AppTheme.emerald.withValues(alpha: 0.4),
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  _generatedCode!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppTheme.textPrimary, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
