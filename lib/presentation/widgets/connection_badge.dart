import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ConnectionBadge extends StatelessWidget {
  final bool isOnline;

  const ConnectionBadge({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.online.withOpacity(0.15)
            : AppColors.offline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? AppColors.online : AppColors.offline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.online : AppColors.offline,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isOnline ? AppColors.online : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
