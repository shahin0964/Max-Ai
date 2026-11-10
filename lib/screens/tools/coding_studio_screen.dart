import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/ai_engine_service.dart';
import '../../services/skill_registry_service.dart';
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
  String? _statusMessage;

  final Map<String, String> _extensions = {
    'Flutter (Dart)': 'dart',
    'Python (FastAPI / Script)': 'py',
    'Full-Stack Web (HTML/JS)': 'html',
    'Node.js / TypeScript': 'ts',
    'Shell Script (Bash)': 'sh',
    'Rust / Systems': 'rs',
  };

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateCode({String? specificInstruction}) async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedCode = null;
      _statusMessage = null;
    });

    final ext = _extensions[_selectedLanguage] ?? 'txt';
    final fullPrompt = '''
You are Max AI Principal Software Architect and Coding Engine.
Generate production-grade, bug-free, fully implemented code.

Language / Tech Stack: $_selectedLanguage
Requirement: "$prompt"
${specificInstruction != null ? "Directive: $specificInstruction" : ""}

Rules:
1. Provide complete code without placeholders or "// TODO: implement".
2. Include brief architectural comments at the top.
3. Follow the idiomatic style and modern conventions for $_selectedLanguage.
''';

    try {
      final reply = await AIEngineService.instance.sendMessage(prompt: fullPrompt);

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

  Future<void> _saveCodeToFile() async {
    if (_generatedCode == null || _generatedCode!.isEmpty) return;

    try {
      final ext = _extensions[_selectedLanguage] ?? 'txt';
      final fileName = 'maxai_code_${DateTime.now().millisecondsSinceEpoch}.$ext';

      // Prefer public Downloads if possible
      Directory? dir;
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (downloadDir.existsSync()) {
        dir = downloadDir;
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsString(_generatedCode!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path}'),
            backgroundColor: AppTheme.emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e'), backgroundColor: AppTheme.rose),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WEBSITE & CODING STUDIO'),
        actions: [
          if (_generatedCode != null) ...[
            IconButton(
              icon: const Icon(Icons.save_alt, color: AppTheme.violet),
              tooltip: 'Save Code to File',
              onPressed: _saveCodeToFile,
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: AppTheme.violet),
              tooltip: 'Copy Code',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _generatedCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied to clipboard!')),
                );
              },
            ),
          ],
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
            final isSkillInstalled = SkillRegistryService.instance.isSkillInstalled('code_refactorer');

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
                            'Code Architect & AST Debugger skill is uninstalled. Code generation operates in baseline mode.',
                            style: TextStyle(color: AppTheme.amber, fontSize: 11),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => SkillRegistryService.instance.installSkill('code_refactorer'),
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
                      // Target Stack
                      const Text('Target Tech Stack & Language', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            isExpanded: true,
                            dropdownColor: AppTheme.surfaceElevated,
                            items: _extensions.keys.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedLanguage = val);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Code Specification
                      const Text('What would you like to build?', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _promptController,
                        maxLines: 4,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'e.g. Build an animated custom cyber slider widget with glowing neon border and haptic feedback',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          filled: true,
                          fillColor: AppTheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Generate Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : () => _generateCode(),
                          icon: _isGenerating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.code, size: 18),
                          label: Text(_isGenerating ? 'ARCHITECTING WITH MAX AI...' : 'GENERATE PRODUCTION CODE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.violet,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Code Viewport
                if (_generatedCode != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, color: AppTheme.violet, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'MAX AI CODE OUTPUT',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.violet),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => _generateCode(specificInstruction: 'Analyze the code above for performance bottlenecks, memory leaks, and add unit test assertions.'),
                            icon: const Icon(Icons.bug_report, size: 14, color: AppTheme.cyan),
                            label: const Text('Refactor AST', style: TextStyle(fontSize: 11, color: AppTheme.cyan)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF04060C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.violet.withValues(alpha: 0.3)),
                    ),
                    child: SelectableText(
                      _generatedCode!,
                      style: const TextStyle(color: Color(0xFF80FFEA), fontSize: 12, fontFamily: 'monospace', height: 1.45),
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
