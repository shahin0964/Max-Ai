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

class _AssistantPersonaScreenState extends State<AssistantPersonaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _drivingSmsController = TextEditingController();

  late String _selectedPersona;
  late String _selectedVoiceEngine;
  late String _selectedLanguage;
  late String _selectedSleepTimer;
  late String _activeVoiceName;
  late String _activeVoiceGender;
  late String _secretMode;

  late bool _memoryAutoLearn;
  late bool _secretModeEnabled;
  late bool _callAnnouncement;
  late bool _callLoudspeaker;
  late bool _drivingMode;

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

  // Official 36 Google Gemini Neural Voices Catalog
  final List<Map<String, String>> _femaleVoices = [
    {'name': 'Kore', 'desc': 'Bold, clear & authoritative (Default)'},
    {'name': 'Aoede', 'desc': 'Breezy, cheerful & pleasant'},
    {'name': 'Zephyr', 'desc': 'Crisp, brilliant & energetic'},
    {'name': 'Leda', 'desc': 'Youthful, dynamic & bright'},
    {'name': 'Callirrhoe', 'desc': 'Melodic, expressive & lyrical'},
    {'name': 'Autonoe', 'desc': 'Calm, articulate & balanced'},
    {'name': 'Despina', 'desc': 'Soft, warm & intimate'},
    {'name': 'Erinome', 'desc': 'Friendly, conversational & natural'},
    {'name': 'Laomedeia', 'desc': 'Passionate, dramatic & vibrant'},
    {'name': 'Achernar', 'desc': 'Crisp, refined & professional'},
    {'name': 'Vega', 'desc': 'Bright, luminous & radiant'},
    {'name': 'Polaris', 'desc': 'Steady, confident & guiding'},
    {'name': 'Bellatrix', 'desc': 'Sharp, agile & assertive'},
    {'name': 'Capella', 'desc': 'Uplifting, resonant & optimistic'},
    {'name': 'Alcyone', 'desc': 'Serene, peaceful & tranquil'},
    {'name': 'Electra', 'desc': 'Vivid, electric & sharp'},
    {'name': 'Maia', 'desc': 'Gentle, nurturing & graceful'},
  ];

  final List<Map<String, String>> _maleVoices = [
    {'name': 'Puck', 'desc': 'Playful, witty & agile'},
    {'name': 'Charon', 'desc': 'Deep, resonant & steady'},
    {'name': 'Fenrir', 'desc': 'Rugged, bold & commanding'},
    {'name': 'Orus', 'desc': 'Authoritative, grounded & clear'},
    {'name': 'Enceladus', 'desc': 'Calm, soothing & gentle'},
    {'name': 'Iapetus', 'desc': 'Deep, stoic & solid'},
    {'name': 'Umbriel', 'desc': 'Mysterious, smooth & rich'},
    {'name': 'Algieba', 'desc': 'Confident, articulate & focused'},
    {'name': 'Algenib', 'desc': 'Crisp, executive & poised'},
    {'name': 'Rasalgethi', 'desc': 'Robust, distinguished & warm'},
    {'name': 'Alnilam', 'desc': 'Grand, stately & commanding'},
    {'name': 'Schedar', 'desc': 'Noble, balanced & deliberate'},
    {'name': 'Gacrux', 'desc': 'Seasoned mentor, deep & experienced'},
    {'name': 'Sadalbari', 'desc': 'Relaxed, natural & easygoing'},
    {'name': 'Mirfak', 'desc': 'Sharp, precise & decisive'},
    {'name': 'Sirius', 'desc': 'Powerful, punchy & commanding'},
    {'name': 'Rigel', 'desc': 'Direct, bold & confident'},
    {'name': 'Castor', 'desc': 'Youthful, clever & witty'},
    {'name': 'Pollux', 'desc': 'Strong, resonant & charismatic'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final s = SettingsService.instance;
    _nameController.text = s.assistantName;
    _drivingSmsController.text = s.drivingSmsText;
    _selectedPersona = s.assistantPersonaTone;
    _selectedVoiceEngine = s.voiceEngine;
    _selectedLanguage = s.assistantLanguage;
    _selectedSleepTimer = s.sleepTimer;
    _activeVoiceName = s.geminiVoiceName;
    _activeVoiceGender = s.geminiVoiceGender;
    _secretMode = s.companionLevel;
    _memoryAutoLearn = s.memoryAutoLearn;
    _secretModeEnabled = s.companionMode;
    _callAnnouncement = s.callAnnouncement;
    _callLoudspeaker = s.callLoudspeaker;
    _drivingMode = s.drivingMode;

    if (_activeVoiceGender == 'male') {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _drivingSmsController.dispose();
    super.dispose();
  }

  void _saveAllSettings() {
    final s = SettingsService.instance;
    s.setAssistantName(_nameController.text.trim());
    s.setAssistantPersonaTone(_selectedPersona);
    s.setVoiceEngine(_selectedVoiceEngine);
    s.setAssistantLanguage(_selectedLanguage);
    s.setSleepTimer(_selectedSleepTimer);
    s.setGeminiVoice(_activeVoiceName, _activeVoiceGender);
    s.setCompanionMode(_secretModeEnabled);
    s.setCompanionLevel(_secretMode);
    s.setMemoryAutoLearn(_memoryAutoLearn);
    s.setCallAnnouncement(_callAnnouncement);
    s.setCallLoudspeaker(_callLoudspeaker);
    s.setDrivingMode(_drivingMode);
    s.setDrivingSmsText(_drivingSmsController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All Settings & Voice ($_activeVoiceName) saved successfully!'),
        backgroundColor: AppTheme.emerald,
      ),
    );
    Navigator.pop(context);
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

            const SizedBox(height: 16),

            // 2. Neural Voice Engine & 30+ Official Gemini Voices
            _buildSectionHeader('GOOGLE GEMINI NEURAL VOICES (36 VOICES)'),
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
                          desc: 'Deep reasoning speech',
                          icon: Icons.auto_awesome,
                          selected: _selectedVoiceEngine == 'Agentic Mind',
                          color: AppTheme.violet,
                          onTap: () => setState(() => _selectedVoiceEngine = 'Agentic Mind'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // Gender Tabs
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.cyan.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cyan, width: 1.2),
                      ),
                      labelColor: AppTheme.cyan,
                      unselectedLabelColor: AppTheme.textMuted,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      tabs: const [
                        Tab(
                          iconMargin: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.female, size: 16, color: AppTheme.rose),
                              SizedBox(width: 6),
                              Text('FEMALE (17)'),
                            ],
                          ),
                        ),
                        Tab(
                          iconMargin: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.male, size: 16, color: AppTheme.cyan),
                              SizedBox(width: 6),
                              Text('MALE (19)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Voice List Container
                  SizedBox(
                    height: 340,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVoiceList(_femaleVoices, isFemale: true),
                        _buildVoiceList(_maleVoices, isFemale: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Companion & Secret Settings
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

            const SizedBox(height: 16),

            // 4. Intelligent Automations & Driving Mode
            _buildSectionHeader('INTELLIGENT AUTOMATIONS & DRIVING'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-Memory & Context Learning', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Automatically remember preferences, names, and routine tasks', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _memoryAutoLearn,
                    activeColor: AppTheme.cyan,
                    onChanged: (val) => setState(() => _memoryAutoLearn = val),
                  ),
                  const Divider(color: AppTheme.surfaceGlassBorder),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Incoming Caller ID Announcement', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Max announces who is calling using neural speech', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _callAnnouncement,
                    activeColor: AppTheme.cyan,
                    onChanged: (val) => setState(() => _callAnnouncement = val),
                  ),
                  const Divider(color: AppTheme.surfaceGlassBorder),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-Answer on Loudspeaker', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Automatically answers after 2 rings when on desk or driving', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _callLoudspeaker,
                    activeColor: AppTheme.cyan,
                    onChanged: (val) => setState(() => _callLoudspeaker = val),
                  ),
                  const Divider(color: AppTheme.surfaceGlassBorder),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Driving Mode Auto-Pilot', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Auto-reject calls and reply with instant custom message', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    value: _drivingMode,
                    activeColor: AppTheme.amber,
                    onChanged: (val) => setState(() => _drivingMode = val),
                  ),
                  if (_drivingMode) ...[
                    const SizedBox(height: 8),
                    const Text('Auto-Reply Message Template', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _drivingSmsController,
                      maxLines: 2,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. Language & Sleep Timer
            _buildSectionHeader('LANGUAGE & STANDBY TIMER'),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active AI Voice Language', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  const Text('Standby Sleep Timer (Auto-Sleep)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
            ElevatedButton.icon(
              onPressed: _saveAllSettings,
              icon: const Icon(Icons.save_rounded, size: 20),
              label: const Text('SAVE ALL CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceList(List<Map<String, String>> voices, {required bool isFemale}) {
    return ListView.builder(
      itemCount: voices.length,
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      itemBuilder: (ctx, index) {
        final v = voices[index];
        final name = v['name']!;
        final desc = v['desc']!;
        final isSel = _activeVoiceName == name;
        final genderStr = isFemale ? 'female' : 'male';
        final accentColor = isFemale ? AppTheme.rose : AppTheme.cyan;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: isSel ? accentColor.withValues(alpha: 0.12) : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSel ? accentColor : AppTheme.surfaceGlassBorder,
              width: isSel ? 1.4 : 0.8,
            ),
          ),
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: isSel ? accentColor.withValues(alpha: 0.25) : AppTheme.surfaceElevated,
              child: Icon(
                isFemale ? Icons.female : Icons.male,
                color: isSel ? accentColor : AppTheme.textSecondary,
                size: 18,
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                color: isSel ? accentColor : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              desc,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: AppTheme.emerald, size: 20),
                  tooltip: 'Preview Voice',
                  onPressed: () {
                    VoiceService.instance.speak('Hello! I am $name, neural voice for Max AI.');
                  },
                ),
                if (isSel)
                  Icon(Icons.check_circle, color: accentColor, size: 20)
                else
                  const Icon(Icons.circle_outlined, color: AppTheme.textMuted, size: 18),
              ],
            ),
            onTap: () {
              setState(() {
                _activeVoiceName = name;
                _activeVoiceGender = genderStr;
              });
              SettingsService.instance.setGeminiVoice(name, genderStr);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected Gemini Voice: $name ($genderStr)'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: accentColor,
                ),
              );
            },
          ),
        );
      },
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
