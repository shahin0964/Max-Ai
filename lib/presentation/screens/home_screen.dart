import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_drawer.dart';
import 'chat_screen.dart';
import 'voice_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: CustomDrawer(
        selectedIndex: _navIndex,
        onSelectIndex: (index) {
          setState(() {
            _navIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  Row(
                    children: [
                      // Pro Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldPro.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.goldPro.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.workspace_premium_rounded,
                                color: AppColors.goldPro, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Pro',
                              style: TextStyle(
                                color: AppColors.goldPro,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification Bell
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded,
                                color: Colors.white, size: 24),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 12),

                  // Greeting Section with 3D Robot Mascot Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hello, Shahin! 👋',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'How can I help you today?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // 3D Robot Avatar Badge
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withOpacity(0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Glowing Prompt / Search Pill Container
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.neonCyan.withOpacity(0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.15),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.neonCyan, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Ask anything...',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_rounded, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const VoiceScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 6 Quick Action Cards (2x3 Grid)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      _actionCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Chat',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatScreen()),
                          );
                        },
                      ),
                      _actionCard(
                        icon: Icons.mic_none_rounded,
                        label: 'Voice',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VoiceScreen()),
                          );
                        },
                      ),
                      _actionCard(
                        icon: Icons.camera_alt_outlined,
                        label: 'Vision',
                        onTap: () {},
                      ),
                      _actionCard(
                        icon: Icons.grid_view_rounded,
                        label: 'Tools',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TasksScreen()),
                          );
                        },
                      ),
                      _actionCard(
                        icon: Icons.psychology_outlined,
                        label: 'Memory',
                        onTap: () {},
                      ),
                      _actionCard(
                        icon: Icons.more_horiz_rounded,
                        label: 'More',
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Quick Access Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Quick Access',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See all →',
                        style: TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Calendar Reminder Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.surfaceLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFFF43F5E),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'No upcoming reminder',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tap to add reminder',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),

      // Glassmorphic Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton(Icons.home_rounded, 'Home', 0),
            _navButton(Icons.chat_bubble_outline_rounded, 'Chat', 1),

            // Center glowing Sparkle Action Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VoiceScreen()),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.botCenterBtnGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            _navButton(Icons.grid_view_rounded, 'Tools', 2),
            _navButton(Icons.settings_outlined, 'Settings', 3),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight.withOpacity(0.6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.neonCyan, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, String label, int index) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        } else {
          setState(() => _navIndex = index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
