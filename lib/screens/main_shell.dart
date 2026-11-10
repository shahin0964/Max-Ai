import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/cyber_drawer.dart';
import 'chat/chat_screen.dart';
import 'more/more_hub_screen.dart';
import 'vision/jarvis_vision_screen.dart';
import 'voice/voice_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    JarvisVisionScreen(),
    VoiceScreen(),
    MoreHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CyberDrawer(
        selectedIndex: _currentIndex,
        onSelectTab: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceElevated,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceGlassBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppTheme.cyan.withValues(alpha: 0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (idx) {
            setState(() {
              _currentIndex = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.chat_bubble, color: AppTheme.cyan),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.center_focus_strong_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.center_focus_strong, color: AppTheme.emerald),
              label: 'Vision',
            ),
            NavigationDestination(
              icon: Icon(Icons.graphic_eq, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.graphic_eq, color: AppTheme.violet),
              label: 'Voice',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.grid_view, color: AppTheme.amber),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
