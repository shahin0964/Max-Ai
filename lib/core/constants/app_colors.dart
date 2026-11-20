import 'package:flutter/material.dart';

class AppColors {
  // Deep space / dark neon canvas
  static const Color background = Color(0xFF070B19);
  static const Color backgroundDark = Color(0xFF040711);
  static const Color surface = Color(0xFF0F172E);
  static const Color surfaceCard = Color(0xFF131D3B);
  static const Color surfaceLight = Color(0xFF1E2B52);
  static const Color surfaceGlass = Color(0x99111C3D);

  // Vibrant Neon accents from screenshot
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonBlue = Color(0xFF38BDF8);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color neonIndigo = Color(0xFF6366F1);
  static const Color electricBlue = Color(0xFF2563EB);
  static const Color goldPro = Color(0xFFFBBF24);

  // Aliases for themes and components
  static const Color primary = neonCyan;
  static const Color accent = neonPurple;
  static const Color success = Color(0xFF10B981);
  static const Color warning = goldPro;
  static const Color offline = Color(0xFF64748B);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Indicators
  static const Color online = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient logoGradient = LinearGradient(
    colors: [neonPurple, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonPurple, electricBlue, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF151F42), Color(0xFF0E152E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient botCenterBtnGradient = LinearGradient(
    colors: [neonPurple, Color(0xFF3B82F6), neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
