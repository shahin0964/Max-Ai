import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'gradient_logo.dart';
import '../screens/chat_screen.dart';
import '../screens/settings_screen.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelectIndex;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0A1024),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  const GradientLogo(size: 44),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Max AI',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Smarter. Simpler. Always with you.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surfaceLight, height: 1),

            // Navigation Items
            const SizedBox(height: 12),
            _drawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              isSelected: selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                onSelectIndex(0);
              },
            ),
            _drawerItem(
              icon: Icons.chat_bubble_rounded,
              title: 'Chat',
              isSelected: selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                onSelectIndex(1);
              },
            ),
            _drawerItem(
              icon: Icons.camera_alt_rounded,
              title: 'Vision',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.grid_view_rounded,
              title: 'Tools',
              isSelected: selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                onSelectIndex(2);
              },
            ),
            _drawerItem(
              icon: Icons.psychology_rounded,
              title: 'Memory',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              isSelected: selectedIndex == 3,
              onTap: () {
                Navigator.pop(context);
                onSelectIndex(3);
              },
            ),
            _drawerItem(
              icon: Icons.more_horiz_rounded,
              title: 'More',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),

            const Spacer(),

            // Bottom Pro Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF261D4C), Color(0xFF131735)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.neonPurple.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldPro.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.goldPro,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Max AI Pro',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Unlock more features',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
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

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.electricBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
