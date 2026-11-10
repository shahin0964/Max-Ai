import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkillItem {
  final String id;
  final String name;
  final String desc;
  final String category;
  final IconData icon;
  final String version;
  final String author;
  final String repo;
  bool installed;
  final bool isBuiltIn;

  SkillItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.category,
    required this.icon,
    this.version = 'v1.0.0',
    this.author = '@openjarvis',
    this.repo = 'https://github.com/openjarvis/skills-hub',
    this.installed = false,
    this.isBuiltIn = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'desc': desc,
        'category': category,
        'version': version,
        'author': author,
        'repo': repo,
        'installed': installed,
        'isBuiltIn': isBuiltIn,
      };
}

class SkillRegistryService extends ChangeNotifier {
  static final SkillRegistryService instance = SkillRegistryService._internal();
  SkillRegistryService._internal();

  static const String _prefKey = 'max_ai_installed_skills';
  static const String _customSkillsPrefKey = 'max_ai_custom_skills';

  bool _initialized = false;
  final List<SkillItem> _skills = [];

  List<SkillItem> get allSkills => List.unmodifiable(_skills);
  List<SkillItem> get installedSkills => _skills.where((s) => s.installed).toList();

  Future<void> initialize() async {
    if (_initialized) return;

    _skills.clear();
    _skills.addAll(_getDefaultCatalog());

    try {
      final prefs = await SharedPreferences.getInstance();
      final installedIds = prefs.getStringList(_prefKey) ?? [
        'markets_scanner',
        'marketing_studio',
        'docs_intelligence',
        'code_refactorer',
        'terminal_runner',
        'web_scraper',
      ];

      for (final s in _skills) {
        s.installed = installedIds.contains(s.id);
      }

      // Load custom user skills from github/community
      final customJson = prefs.getString(_customSkillsPrefKey);
      if (customJson != null && customJson.isNotEmpty) {
        final List<dynamic> list = jsonDecode(customJson);
        for (final item in list) {
          final m = item as Map<String, dynamic>;
          final id = m['id'] as String;
          if (!_skills.any((x) => x.id == id)) {
            _skills.add(
              SkillItem(
                id: id,
                name: m['name'] as String,
                desc: m['desc'] as String,
                category: m['category'] as String? ?? 'Community',
                icon: Icons.extension,
                version: m['version'] as String? ?? 'v1.0.0',
                author: m['author'] as String? ?? '@github',
                repo: m['repo'] as String? ?? '',
                installed: installedIds.contains(id),
                isBuiltIn: false,
              ),
            );
          }
        }
      }
    } catch (_) {}

    _initialized = true;
    notifyListeners();
  }

  bool isSkillInstalled(String id) {
    final match = _skills.firstWhere((s) => s.id == id, orElse: () => SkillItem(
      id: '', name: '', desc: '', category: '', icon: Icons.help, installed: false,
    ));
    return match.installed;
  }

  Future<void> installSkill(String id) async {
    for (final s in _skills) {
      if (s.id == id) {
        s.installed = true;
        break;
      }
    }
    await _saveInstalledState();
    notifyListeners();
  }

  Future<void> uninstallSkill(String id) async {
    for (final s in _skills) {
      if (s.id == id) {
        s.installed = false;
        break;
      }
    }
    await _saveInstalledState();
    notifyListeners();
  }

  Future<void> toggleSkill(String id) async {
    for (final s in _skills) {
      if (s.id == id) {
        s.installed = !s.installed;
        break;
      }
    }
    await _saveInstalledState();
    notifyListeners();
  }

  Future<void> addCustomSkill({
    required String name,
    required String desc,
    required String category,
    required String repoUrl,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newSkill = SkillItem(
      id: id,
      name: name,
      desc: desc,
      category: category,
      icon: Icons.extension,
      version: 'v1.0.0',
      author: '@community',
      repo: repoUrl,
      installed: true,
      isBuiltIn: false,
    );

    _skills.add(newSkill);

    try {
      final prefs = await SharedPreferences.getInstance();
      final customList = _skills.where((s) => !s.isBuiltIn).map((s) => s.toJson()).toList();
      await prefs.setString(_customSkillsPrefKey, jsonEncode(customList));
    } catch (_) {}

    await _saveInstalledState();
    notifyListeners();
  }

  Future<void> _saveInstalledState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final installedIds = _skills.where((s) => s.installed).map((s) => s.id).toList();
      await prefs.setStringList(_prefKey, installedIds);
    } catch (_) {}
  }

  List<SkillItem> _getDefaultCatalog() {
    return [
      SkillItem(
        id: 'markets_scanner',
        name: 'Financial Markets Scanner',
        desc: 'Fetches live crypto order books, Binance 24h ticker metrics, and macroeconomic volatility sentiment',
        category: 'Finance',
        icon: Icons.trending_up,
        version: 'v2.1.0',
        author: '@openjarvis/finance',
        repo: 'https://github.com/openjarvis/skill-financial-markets',
        installed: true,
      ),
      SkillItem(
        id: 'marketing_studio',
        name: 'Marketing & Viral Copywriter',
        desc: 'Generates high-converting Instagram reels, YouTube titles, LinkedIn thought-leadership & ad copy',
        category: 'Marketing',
        icon: Icons.campaign_outlined,
        version: 'v1.8.4',
        author: '@openjarvis/growth',
        repo: 'https://github.com/openjarvis/skill-growth-copy',
        installed: true,
      ),
      SkillItem(
        id: 'docs_intelligence',
        name: 'Document & PDF Intelligence',
        desc: 'Parses contracts, technical papers, markdown specs & extracts structured action items and Q&A insights',
        category: 'Documents',
        icon: Icons.description_outlined,
        version: 'v3.0.1',
        author: '@openjarvis/knowledge',
        repo: 'https://github.com/openjarvis/skill-doc-analyzer',
        installed: true,
      ),
      SkillItem(
        id: 'code_refactorer',
        name: 'Code Architect & AST Debugger',
        desc: 'Generates production Flutter/Dart, Python, FastAPI, Node.js & analyzes syntax trees for memory leaks',
        category: 'Coding',
        icon: Icons.code,
        version: 'v2.4.0',
        author: '@openjarvis/devtools',
        repo: 'https://github.com/openjarvis/skill-code-architect',
        installed: true,
      ),
      SkillItem(
        id: 'terminal_runner',
        name: 'Android Shell & Linux Terminal',
        desc: 'Executes real bash commands on on-device Android sh runtime, checks kernel metrics & network ping',
        category: 'System',
        icon: Icons.terminal,
        version: 'v1.5.2',
        author: '@openjarvis/core',
        repo: 'https://github.com/openjarvis/skill-bash-runner',
        installed: true,
      ),
      SkillItem(
        id: 'web_scraper',
        name: 'Autonomous Web Research Scraper',
        desc: 'HTTP GET scraper that cleans HTML DOM, strips script tags, extracts readable article text & synthesizes facts',
        category: 'Research',
        icon: Icons.travel_explore,
        version: 'v2.2.0',
        author: '@openjarvis/scraper',
        repo: 'https://github.com/openjarvis/skill-web-crawler',
        installed: true,
      ),
      SkillItem(
        id: 'smart_home_iot',
        name: 'Smart Home IoT Controller',
        desc: 'Bridges Matter, Zigbee and Home Assistant REST endpoints to toggle lighting, switches & climate',
        category: 'IoT',
        icon: Icons.home_repair_service,
        version: 'v1.1.0',
        author: '@community/home-assistant',
        repo: 'https://github.com/home-assistant/skills-iot',
        installed: false,
      ),
      SkillItem(
        id: 'whatsapp_bot',
        name: 'WhatsApp & Telegram Auto-Responder',
        desc: 'Autonomous inbound message filtering, smart automated customer replies, and notification alerts',
        category: 'Communication',
        icon: Icons.mark_chat_read,
        version: 'v1.3.0',
        author: '@community/messenger-bot',
        repo: 'https://github.com/community/whatsapp-bot-skill',
        installed: false,
      ),
      SkillItem(
        id: 'github_triager',
        name: 'GitHub PR & Issue Triager',
        desc: 'Automates reviewing incoming repository pull requests, comments on code diffs, and triages bug labels',
        category: 'Coding',
        icon: Icons.source,
        version: 'v2.0.1',
        author: '@community/github-bot',
        repo: 'https://github.com/google/antigravity-skills-github',
        installed: false,
      ),
      SkillItem(
        id: 'youtube_analyzer',
        name: 'YouTube Script & Viral Catalyst',
        desc: 'Analyzes trending video transcripts, generates viral hook pacing, and drafts storyboard timestamps',
        category: 'Marketing',
        icon: Icons.smart_display,
        version: 'v1.0.5',
        author: '@community/youtube-creator',
        repo: 'https://github.com/community/youtube-script-skill',
        installed: false,
      ),
      SkillItem(
        id: 'sqlite_inspector',
        name: 'SQLite & Vector DB Inspector',
        desc: 'Executes queries against local SQLite databases, inspects schema definitions & checks table integrity',
        category: 'System',
        icon: Icons.storage,
        version: 'v1.2.3',
        author: '@openjarvis/storage',
        repo: 'https://github.com/openjarvis/skill-sqlite-explorer',
        installed: false,
      ),
      SkillItem(
        id: 'voice_transcriber',
        name: 'Whisper Audio & Voice Transcriber',
        desc: 'Transcribes recorded audio notes, meetings, and voice memos into structured meeting minutes',
        category: 'Productivity',
        icon: Icons.mic_none,
        version: 'v2.0.0',
        author: '@openjarvis/voice',
        repo: 'https://github.com/openjarvis/skill-whisper-transcribe',
        installed: false,
      ),
      SkillItem(
        id: 'android_automation',
        name: 'Android System Automation & Intents',
        desc: 'Launches Android system settings, dispatches intents, monitors clipboard, and creates calendar events',
        category: 'System',
        icon: Icons.android,
        version: 'v1.4.0',
        author: '@openjarvis/android',
        repo: 'https://github.com/openjarvis/skill-android-automation',
        installed: false,
      ),
      SkillItem(
        id: 'deep_research',
        name: 'Autonomous Deep Research & Fact Checker',
        desc: 'Multi-step web search synthesis across scientific repositories, news APIs & cross-referencing citations',
        category: 'Research',
        icon: Icons.menu_book,
        version: 'v2.3.1',
        author: '@openjarvis/research',
        repo: 'https://github.com/openjarvis/skill-deep-research',
        installed: false,
      ),
    ];
  }
}
