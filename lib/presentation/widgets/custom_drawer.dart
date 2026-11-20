import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/gradient_logo.dart';
import '../screens/chat_screen.dart';
import '../screens/vision_screen.dart';
import '../screens/memory_screen.dart';
import '../screens/tools_manager_screen.dart';
import '../screens/terminal_reel_screen.dart';
import '../screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectIndex;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  void _showFeatureSheet(BuildContext context, String title, String description, IconData icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3FB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: const Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('100% Active & Unlocked', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(description, style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5, height: 1.45)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Open in Max AI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEDF4FC),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header matching frame_014.jpg
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'M',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Maya',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'by The Hunter AI',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFCBD5E1), height: 1),

            // Scrollable Navigation List matching frame_014.jpg
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  _sectionHeader('HOME'),
                  _drawerClayItem(Icons.home_rounded, 'Home', () {
                    Navigator.pop(context);
                    onSelectIndex(0);
                  }),
                  _drawerClayItem(Icons.home_outlined, 'Maya Home', () {
                    Navigator.pop(context);
                    onSelectIndex(0);
                  }),

                  const SizedBox(height: 16),
                  _sectionHeader('KAAM-KAAJ'),
                  _drawerClayItem(Icons.trending_up_rounded, 'Markets', () {
                    Navigator.pop(context);
                    _showFeatureSheet(context, 'Markets & Live Intelligence', 'Track live stock indices, crypto rates, and market forecasts powered by Gemini.', Icons.trending_up_rounded);
                  }),
                  _drawerClayItem(Icons.storefront_rounded, 'Marketing', () {
                    Navigator.pop(context);
                    _showFeatureSheet(context, 'Autonomous Marketing', 'Generate viral copy, SEO tags, email campaigns, and product descriptions.', Icons.storefront_rounded);
                  }),
                  _drawerClayItem(Icons.description_rounded, 'Documents', () {
                    Navigator.pop(context);
                    _showFeatureSheet(context, 'Document & PDF Intelligence', 'Read, extract, summarize, and translate PDFs, DOCX, and text documents.', Icons.description_rounded);
                  }),
                  _drawerClayItem(Icons.photo_library_rounded, 'Meri photos', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionScreen()));
                  }),
                  _drawerClayItem(Icons.code_rounded, 'Website / Coding', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen()));
                  }),
                  _drawerClayItem(Icons.terminal_rounded, 'Terminal', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalReelScreen()));
                  }),
                  _drawerClayItem(Icons.language_rounded, 'Browser', () {
                    Navigator.pop(context);
                    _showFeatureSheet(context, 'Automated Browser', 'Surf web pages, read web content, and search Google seamlessly with Maya.', Icons.language_rounded);
                  }),
                  _drawerClayItem(Icons.accessibility_new_rounded, 'Accessibility', () {
                    Navigator.pop(context);
                    _showFeatureSheet(context, 'Accessibility Service', 'Allows Maya to read your screen, tap buttons, and send WhatsApp messages automatically.', Icons.accessibility_new_rounded);
                  }),

                  const SizedBox(height: 16),
                  _sectionHeader('SYSTEM'),
                  _drawerClayItem(Icons.settings_rounded, 'Settings', () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  }),
                ],
              ),
            ),

            // Footer matching frame_014.jpg
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Text(
                'v5.2.63 · The Hunter AI',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _drawerClayItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x103060A0),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: const Color(0xFF2563EB), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
