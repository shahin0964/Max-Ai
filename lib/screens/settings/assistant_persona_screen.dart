import 'package:flutter/material.dart';
import '../../services/settings_service.dart';
import '../../services/voice_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class AssistantPersonaScreen extends StatefulWidget {
  const AssistantPersonaScreen({super.key});

  @override
  State<AssistantPersonaScreen> createState() => _AssistantPersonaScreenState();
}

class _AssistantPersonaScreenState extends State<AssistantPersonaScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _drivingSmsController = TextEditingController();

  String _selectedPersona = 'Max AI';
  String _selectedVoiceEngine = 'Normal Swift';
  String _selectedLanguage = 'Bengali + English';
  String _selectedSleepTimer = '10 min';
  String _activeVoiceStyle = 'Damdaar';
  String _secretMode = 'Friendly';

  bool _memoryAutoLearn = true;
  bool _secretModeEnabled = false;
  bool _reelsAutoScroll = false;
  bool _callAnnouncement = true;
  bool _callLoudspeaker = false;
  bool _drivingMode = false;
  bool _bgAutoUpdate = true;

  final List<String> _personas = [
    'Max AI',
    'OpenJarvis Core',
    'Maya',
    'Friday',
    'Venom',
    'Cyber Sentry',
  ];

  final List<String> _languages = [
    'Bengali + English (default)',
    'English (Global)',
    'Hinglish (Hindi + English)',
    'বাংলা (Bengali Pure)',
    'Hindi (हिंदी)',
    'Arabic / Persian',
    'Urdu (اردو)',
  ];

  final List<String> _sleepTimers = [
    'Kabhi nahi',
    '5 min',
    '10 min',
    '20 min',
    '45 min',
  ];

  final List<Map<String, String>> _voiceStyles = [
    {'title': 'Damdaar', 'sub': 'Kore • Bold & Authoritative'},
    {'title': 'Halki-phulki', 'sub': 'Aoede • Gentle & Relaxed'},
    {'title': 'Jawaan', 'sub': 'Leda • Energetic & Youthful'},
    {'title': 'Chamakdaar', 'sub': 'Zephyr • Crisp & Brilliant'},
    {'title': 'Josheeli', 'sub': 'Laomedeia • Passionate'},
    {'title': 'Mulaayam', 'sub': 'Despina • Soft & Warm'},
    {'title': 'Mature', 'sub': 'Gacrux • Experienced Mentor'},
    {'title': 'Komal', 'sub': 'Vindemiatrix • Sweet & Calming'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Max AI';
    _drivingSmsController.text =
        'Max AI Auto-Reply: Shahin is currently driving and cannot attend your call right now. Will call back soon.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _drivingSmsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASSISTANT & PERSONA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Assistant Identity
            _buildSectionHeader('IDENTITY & PERSONA'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Assistant Name', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surface,
                      prefixIcon: const Icon(Icons.psychology, color: AppTheme.cyan, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Personality Tone', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPersona,
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceElevated,
                        items: _personas.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: AppTheme.textPrimary)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPersona = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Neural Voice Engine & Voice Styles
            _buildSectionHeader('NEURAL VOICE ENGINE'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildEngineOption(
                          title: 'Normal Swift',
                          desc: 'Ultra-low latency',
                          icon: Icons.bolt,
                          selected: _selectedVoiceEngine == 'Normal Swift',
                          color: AppTheme.cyan,
                          onTap: () => setState(() => _selectedVoiceEngine = 'Normal Swift'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildEngineOption(
                          title: 'Agentic Mind',
                          desc: 'Deep reasoning reasoning',
                          icon: Icons.auto_awesome,
                          selected: _selectedVoiceEngine == 'Agentic Mind',
                          color: AppTheme.violet,
                          onTap: () => setState(() => _selectedVoiceEngine = 'Agentic Mind'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Select Voice Persona Style', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  ..._voiceStyles.map((vs) {
                    final isSel = _activeVoiceStyle == vs['title'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.cyan.withValues(alpha: 0.12) : AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? AppTheme.cyan : AppTheme.surfaceGlassBorder,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(vs['title']!, style: TextStyle(color: isSel ? AppTheme.cyan : AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text(vs['sub']!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.play_circle_fill, color: AppTheme.emerald, size: 22),
                              tooltip: 'Preview Voice',
                              onPressed: () {
                                VoiceService.instance.speak('Hello! I am ${vs['title']} voice from Max AI.');
                              },
                            ),
                            if (isSel) const Icon(Icons.check_circle, color: AppTheme.cyan, size: 20),
                          ],
                        ),
                        onTap: () => setState(() => _activeVoiceStyle = vs['title']!),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Secret & Relationship Settings (Companion Mode)
            _buildSectionHeader('COMPANION & SECRET SETTINGS'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Companion Mode', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    subtitle: const Text('Unlock emotional intimacy, unfiltered banter & persona closeness', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _secretModeEnabled,
                    activeColor: AppTheme.rose,
                    onChanged: (val) => setState(() => _secretModeEnabled = val),
                  ),
                  if (_secretModeEnabled) ...[
                    const Divider(color: AppTheme.surfaceGlassBorder),
                    const SizedBox(height: 6),
                    _buildRadioMode('Friendly Companion', 'Warm, supportive, non-romantic bond', 'Friendly'),
                    _buildRadioMode('Romantic Partner', 'Affectionate, flirtatious, deep bonding', 'Romantic'),
                    _buildRadioMode('Intense Sentry (18+)', 'Passionate, completely unfiltered, explicit dialogue', 'Intense'),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4. Autonomous Memory (Yaaddasht)
            _buildSectionHeader('AUTONOMOUS MEMORY (YAADDASHT)'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Max ko khud se yaad rakhne do', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                subtitle: const Text('Auto-extract user preferences, routines & facts from conversations into semantic vector memory', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                value: _memoryAutoLearn,
                activeColor: AppTheme.emerald,
                onChanged: (val) => setState(() => _memoryAutoLearn = val),
              ),
            ),

            const SizedBox(height: 14),

            // 5. Automation & Media
            _buildSectionHeader('PHONE & APP AUTOMATIONS'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reels Auto-Scroll', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    subtitle: const Text('Keep Instagram/YouTube Shorts auto-scrolling with smart timer', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _reelsAutoScroll,
                    activeColor: AppTheme.cyan,
                    onChanged: (val) => setState(() => _reelsAutoScroll = val),
                  ),
                  const Divider(color: AppTheme.surfaceGlassBorder),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Call Announcement', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    subtitle: const Text('Speak caller name aloud via neural voice on incoming call', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _callAnnouncement,
                    activeColor: AppTheme.cyan,
                    onChanged: (val) => setState(() => _callAnnouncement = val),
                  ),
                  if (_callAnnouncement)
                    SwitchListTile(
                      contentPadding: const EdgeInsets.only(left: 12),
                      title: const Text('Auto Loudspeaker', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      subtitle: const Text('Put call automatically on speaker when Max answers', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      value: _callLoudspeaker,
                      activeColor: AppTheme.emerald,
                      onChanged: (val) => setState(() => _callLoudspeaker = val),
                    ),
                  const Divider(color: AppTheme.surfaceGlassBorder),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Driving Mode', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    subtitle: const Text('Auto-reject incoming calls and send instant WhatsApp/SMS note', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _drivingMode,
                    activeColor: AppTheme.amber,
                    onChanged: (val) => setState(() => _drivingMode = val),
                  ),
                  if (_drivingMode) ...[
                    const SizedBox(height: 6),
                    TextField(
                      controller: _drivingSmsController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surface,
                        hintText: 'Driving auto-reply text template...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 6. Language & Standby Timeout
            _buildSectionHeader('LANGUAGE & POWER STANDBY'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Conversational Language (Bhasha)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceElevated,
                        items: _languages.map((l) {
                          return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLanguage = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Koi na bole to so jao (Standby Sleep Timer)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sleepTimers.map((st) {
                      final isSel = _selectedSleepTimer == st;
                      return ChoiceChip(
                        label: Text(st, style: TextStyle(color: isSel ? Colors.black : AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                        selected: isSel,
                        selectedColor: AppTheme.cyan,
                        backgroundColor: AppTheme.surface,
                        onSelected: (_) => setState(() => _selectedSleepTimer = st),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Assistant Persona & Automations saved successfully!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('SAVE CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.cyan,
        ),
      ),
    );
  }

  Widget _buildEngineOption({
    required String title,
    required String desc,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : AppTheme.surfaceGlassBorder, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppTheme.textMuted, size: 24),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? color : AppTheme.textPrimary, fontSize: 13)),
            const SizedBox(height: 2),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioMode(String title, String desc, String mode) {
    final isSel = _secretMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _secretMode = mode),
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSel ? AppTheme.rose.withValues(alpha: 0.12) : AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? AppTheme.rose : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(isSel ? Icons.radio_button_checked : Icons.radio_button_off, color: isSel ? AppTheme.rose : AppTheme.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? AppTheme.rose : AppTheme.textPrimary, fontSize: 12)),
                  Text(desc, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
