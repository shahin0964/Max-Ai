import 'package:flutter/material.dart';

/// Exact Color Palette extracted directly from Maya AI APK (com.getmaya.android.ui.theme.ColorKt)
class AppColors {
  // Core Maya Colors
  static const Color mayaBackground = Color(0xFF0A0C14);
  static const Color mayaSurface = Color(0xFF131724);
  static const Color mayaSurfaceElevated = Color(0xFF1A1F30);
  static const Color mayaBorder = Color(0xFF23293D);
  static const Color mayaPrimary = Color(0xFF7C4DFF);
  static const Color mayaPrimaryDark = Color(0xFF5E35B1);
  static const Color mayaAccentCyan = Color(0xFF00E5FF);
  static const Color mayaAccentTeal = Color(0xFF00BFA5);
  static const Color mayaAccentPink = Color(0xFFFF4081);
  static const Color mayaTextPrimary = Color(0xFFF0F3F8);
  static const Color mayaTextSecondary = Color(0xFF9EAABF);
  static const Color terminalBackground = Color(0xFF08090C);
  static const Color terminalGreen = Color(0xFF00FF66);
  static const Color terminalCyan = Color(0xFF00E5FF);

  // App Theme Mappings & Aliases
  static const Color background = mayaBackground;
  static const Color surfaceCard = mayaSurface;
  static const Color surfaceElevated = mayaSurfaceElevated;
  static const Color surfaceLight = mayaBorder;
  static const Color surfaceGlass = Color(0xDD131724);
  
  static const Color primary = mayaPrimary;
  static const Color primaryDark = mayaPrimaryDark;
  static const Color neonCyan = mayaAccentCyan;
  static const Color accent = mayaAccentCyan;
  static const Color electricBlue = Color(0xFF3D5AFE);
  static const Color neonPurple = mayaPrimary;
  static const Color neonBlue = Color(0xFF2979FF);
  static const Color accentTeal = mayaAccentTeal;
  static const Color accentPink = mayaAccentPink;

  static const Color textPrimary = mayaTextPrimary;
  static const Color textSecondary = mayaTextSecondary;
  static const Color textMuted = Color(0xFF6B7280);

  static const Color goldPro = Color(0xFFFFD700);
  static const Color online = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Gradients matching Maya VoiceOrb & Brand
  static const LinearGradient logoGradient = LinearGradient(
    colors: [mayaAccentCyan, mayaPrimary, mayaAccentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orbGradient = LinearGradient(
    colors: [mayaAccentCyan, Color(0xFF3D5AFE), mayaPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient botCenterBtnGradient = LinearGradient(
    colors: [mayaAccentCyan, mayaPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
