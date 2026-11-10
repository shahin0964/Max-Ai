import 'package:flutter/material.dart';

class AppTheme {
  // Void Black & Cyber Palette
  static const Color background = Color(0xFF070A11);
  static const Color surface = Color(0xFF0D1322);
  static const Color surfaceElevated = Color(0xFF131C31);
  static const Color surfaceGlass = Color(0x99131C31);
  static const Color surfaceGlassBorder = Color(0x3300F2FE);

  // Neon Accents
  static const Color cyan = Color(0xFF00F2FE);
  static const Color cyanGlow = Color(0x4D00F2FE);
  static const Color violet = Color(0xFF9D4EDD);
  static const Color violetGlow = Color(0x4D9D4EDD);
  static const Color emerald = Color(0xFF00FF87);
  static const Color amber = Color(0xFFFFAA00);
  static const Color rose = Color(0xFFFF0055);

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: violet,
        surface: surface,
        error: rose,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x2200F2FE), width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x1A00F2FE),
        thickness: 1,
      ),
    );
  }
}
