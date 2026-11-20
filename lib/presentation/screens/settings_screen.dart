import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final key = context.read<ChatProvider>().apiKey;
    _apiKeyController = TextEditingController(text: key);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Profile Card matching Screen 6
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: Row(
              children: [
                // Profile Avatar Circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'MS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Md Shahin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'shahin@example.com',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Preferences Section Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'App Preferences',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Preferences List Group
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _prefTile(Icons.language_rounded, 'Language', 'English'),
                _divider(),
                _prefTile(Icons.dark_mode_outlined, 'Theme', 'Dark'),
                _divider(),
                _prefTile(Icons.volume_up_outlined, 'Voice', 'Default'),
                _divider(),
                _prefTile(Icons.sentiment_satisfied_alt_rounded, 'Personality', 'Friendly'),
                _divider(),
                _prefTile(Icons.psychology_outlined, 'Memory & Data', ''),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data & Privacy Section Header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Data & Privacy',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _prefTile(Icons.backup_outlined, 'Backup & Restore', ''),
                _divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gemini API Key',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your AIzaSy API Key...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check, color: AppColors.neonCyan),
                            onPressed: () {
                              context.read<ChatProvider>().setApiKey(_apiKeyController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('API Key saved!')),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _prefTile(IconData icon, String title, String trailingText) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonCyan, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText.isNotEmpty)
            Text(
              trailingText,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _divider() => const Divider(color: AppColors.surfaceLight, height: 1);
}
