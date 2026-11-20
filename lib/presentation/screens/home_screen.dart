import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/custom_drawer.dart';
import '../providers/chat_provider.dart';
import '../providers/task_provider.dart';
import 'chat_screen.dart';
import 'voice_screen.dart';
import 'vision_screen.dart';
import 'memory_screen.dart';
import 'tools_manager_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _navIndex = 0;

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: AppColors.neonCyan, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'System Notifications',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: AppColors.surfaceLight),
            _notifItem('⚡ Autonomous Agent Engine', 'Gemini 3.8 Flash & 19 tools are active and standing by.'),
            _notifItem('📱 Termux Bridge Ready', 'Ready to run background bash intents.'),
            _notifItem('🎙️ Voice Guardian & Wake Word', 'Voiceprint monitoring enabled.'),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.neonCyan, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0E142B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.goldPro),
        ),
        title: Row(
          children: const [
            Icon(Icons.workspace_premium_rounded, color: AppColors.goldPro, size: 28),
            SizedBox(width: 8),
            Text('Max AI Pro Active', style: TextStyle(color: AppColors.goldPro, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('👑 Unlocked Features:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• Gemini 3.8 Flash High Turbo Engine\n• 19 Autonomous Tools & Termux Rootless Bridge\n• Multi-step App Macros Execution\n• Voice Guardian Speaker Biometrics\n• Infinite Long-Term Memory Vault',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPro, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog() {
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Quick Reminder / Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: titleCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. Call team at 4 PM, Build APK',
            labelText: 'Reminder Title',
            labelStyle: TextStyle(color: AppColors.neonCyan),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCyan, foregroundColor: Colors.black),
            onPressed: () {
              final text = titleCtrl.text.trim();
              if (text.isNotEmpty) {
                context.read<TaskProvider>().addTask(text, dueDate: DateTime.now().add(const Duration(hours: 3)));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder added successfully!')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final pendingTasks = taskProvider.tasks.where((t) => !t.isCompleted).toList();
    final nextTask = pendingTasks.isNotEmpty ? pendingTasks.first : null;

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
                      GestureDetector(
                        onTap: _showProModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.goldPro.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.goldPro.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.workspace_premium_rounded, color: AppColors.goldPro, size: 16),
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
                      ),
                      const SizedBox(width: 8),
                      // Notification Bell
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                            onPressed: _showNotificationSheet,
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
                        children: [
                          Text(
                            'Hello, ${chatProvider.userName.split(' ')[0]}! 👋',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'How can I help you today?',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // 3D Robot Avatar Badge
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceScreen())),
                        child: Container(
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

                  // 6 Quick Action Cards (2x3 Grid) - 100% Functional!
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
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                      ),
                      _actionCard(
                        icon: Icons.mic_none_rounded,
                        label: 'Voice',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceScreen())),
                      ),
                      _actionCard(
                        icon: Icons.camera_alt_outlined,
                        label: 'Vision',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionScreen())),
                      ),
                      _actionCard(
                        icon: Icons.grid_view_rounded,
                        label: 'Tools',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen())),
                      ),
                      _actionCard(
                        icon: Icons.psychology_outlined,
                        label: 'Memory',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryScreen())),
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
                    children: [
                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAddReminderDialog,
                        child: const Text(
                          '+ Add Reminder',
                          style: TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Dynamic Calendar Reminder Card
                  GestureDetector(
                    onTap: _showAddReminderDialog,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceLight),
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
                              children: [
                                Text(
                                  nextTask != null ? nextTask.title : 'No upcoming reminder',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  nextTask != null && nextTask.dueDate != null
                                      ? DateFormat('EEE, MMM d • h:mm a').format(nextTask.dueDate!)
                                      : 'Tap to add reminder',
                                  style: const TextStyle(
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ToolsManagerScreen()));
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
