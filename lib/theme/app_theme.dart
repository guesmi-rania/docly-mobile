import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary       = Color(0xFF1a73e8);
  static const Color primaryDark   = Color(0xFF0d47a1);
  static const Color primaryLight  = Color(0xFFe8f0fe);
  static const Color success       = Color(0xFF4caf50);
  static const Color warning       = Color(0xFFf9a825);
  static const Color danger        = Color(0xFFe53935);
  static const Color background    = Color(0xFFf8faff);
  static const Color cardBg        = Color(0xFFffffff);
  static const Color textPrimary   = Color(0xFF1a1a2e);
  static const Color textSecondary = Color(0xFF888888);
  static const Color border        = Color(0xFFe0e8ff);

  static LinearGradient get gradient => const LinearGradient(
    colors: [Color(0xFF1a73e8), Color(0xFF0d47a1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFFe0e8ff), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFFe0e8ff), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
    ),
  );
}