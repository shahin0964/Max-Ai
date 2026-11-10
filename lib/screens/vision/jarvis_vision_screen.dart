import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/ai_engine_service.dart';
import '../../services/voice_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class JarvisVisionScreen extends StatefulWidget {
  const JarvisVisionScreen({super.key});

  @override
  State<JarvisVisionScreen> createState() => _JarvisVisionScreenState();
}

class _JarvisVisionScreenState extends State<JarvisVisionScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptController = TextEditingController();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysisResult;
  String _selectedPreset = 'General Scene Analysis';

  final List<String> _presets = [
    'General Scene Analysis',
    'Extract & Debug Code',
    'OCR & Text Transcribe',
    'Object & Detail Inspect',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to acquire image: $e')),
        );
      }
    }
  }

  Future<void> _runVisionScan() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    final prompt = _promptController.text.trim().isNotEmpty
        ? _promptController.text.trim()
        : 'Analyze this image in detail from an autonomous high-tech Jarvis perspective based on mode: $_selectedPreset. Provide key observations, structural details, and actionable insights.';

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final reply = await AIEngineService.instance.analyzeImage(
        imageBytes: bytes,
        mimeType: 'image/jpeg',
        prompt: prompt,
      );

      if (mounted) {
        setState(() {
          _analysisResult = reply;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisResult = 'Vision Scan Failed: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.emerald),
          tooltip: 'Open Slidebar',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.center_focus_strong, color: AppTheme.emerald, size: 20),
            SizedBox(width: 8),
            Text(
              'JARVIS VISION COCKPIT',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: AppTheme.emerald,
              ),
            ),
          ],
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.cyan),
              tooltip: 'Reset Scanner',
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _analysisResult = null;
                  _promptController.clear();
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Futuristic Cyber Viewfinder
              _buildViewfinder(),

              const SizedBox(height: 16),

              // 2. Scan Mode Presets
              const Text(
                'VISION SCAN PROTOCOL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _presets.map((preset) {
                    final isSel = _selectedPreset == preset;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          preset,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            color: isSel ? Colors.black : AppTheme.textSecondary,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppTheme.emerald,
                        backgroundColor: AppTheme.surfaceElevated,
                        side: BorderSide(
                          color: isSel ? AppTheme.emerald : AppTheme.surfaceGlassBorder,
                          width: 0.8,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedPreset = preset);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // 3. Custom Query Input
              TextField(
                controller: _promptController,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask Jarvis Vision anything about the frame...',
                  hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceElevated,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.emerald, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.surfaceGlassBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.surfaceGlassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.emerald, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 4. Action Trigger
              if (_selectedImage != null)
                ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _runVisionScan,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.flash_on, color: Colors.black, size: 18),
                  label: Text(
                    _isAnalyzing ? 'SCANNING VISUAL SPECTRUM...' : 'EXECUTE JARVIS VISION SCAN',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

              const SizedBox(height: 16),

              // 5. Analysis Output
              if (_analysisResult != null) _buildAnalysisOutput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emerald.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image or placeholder
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.emerald, width: 1.5),
                          color: AppTheme.emerald.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong,
                          size: 38,
                          color: AppTheme.emerald,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'JARVIS OPTICAL SENSOR READY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppTheme.emerald,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Capture real-time photo or load image target',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                            label: const Text('Camera', style: TextStyle(fontSize: 11, color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.emerald,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 16, color: AppTheme.cyan),
                            label: const Text('Gallery', style: TextStyle(fontSize: 11, color: AppTheme.cyan)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.cyan, width: 0.8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Holographic HUD Reticle Overlay
            Positioned(
              top: 10,
              left: 10,
              child: _buildReticleCorner(),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Transform.rotate(angle: 1.5708, child: _buildReticleCorner()),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Transform.rotate(angle: 4.71239, child: _buildReticleCorner()),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Transform.rotate(angle: 3.14159, child: _buildReticleCorner()),
            ),

            // Top Status Bar in Viewfinder
            Positioned(
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.4), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedImage != null ? 'TARGET ACQUIRED • READY' : 'HUD CALIBRATED • STANDBY',
                      style: const TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emerald,
                        letterSpacing: 0.8,
                      ),
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

  Widget _buildReticleCorner() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.emerald, width: 2),
          left: BorderSide(color: AppTheme.emerald, width: 2),
        ),
      ),
    );
  }

  Widget _buildAnalysisOutput() {
    return GlassPanel(
      borderColor: AppTheme.emerald.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology, color: AppTheme.emerald, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'JARVIS COGNITIVE DECRYPT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.emerald,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppTheme.cyan, size: 20),
                tooltip: 'Speak Analysis',
                onPressed: () {
                  if (_analysisResult != null) {
                    VoiceService.instance.speak(_analysisResult!);
                  }
                },
              ),
            ],
          ),
          const Divider(height: 16),
          MarkdownBody(
            data: _analysisResult ?? '',
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.5),
              h1: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.cyan),
              h2: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.emerald),
              code: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                backgroundColor: AppTheme.surfaceElevated,
                color: AppTheme.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
