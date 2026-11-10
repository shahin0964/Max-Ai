import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/cyber_drawer.dart';
import 'agent/agent_screen.dart';
import 'chat/chat_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'memory/memory_screen.dart';
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
    AgentScreen(),
    VoiceScreen(),
    MemoryScreen(),
    DashboardScreen(),
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
              icon: Icon(Icons.hub_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.hub, color: AppTheme.amber),
              label: 'Agent',
            ),
            NavigationDestination(
              icon: Icon(Icons.graphic_eq, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.graphic_eq, color: AppTheme.emerald),
              label: 'Voice',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.psychology, color: AppTheme.violet),
              label: 'Memory',
            ),
            NavigationDestination(
              icon: Icon(Icons.speed, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.speed, color: AppTheme.cyan),
              label: 'Telemetry',
            ),
          ],
        ),
      ),
    );
  }
}
