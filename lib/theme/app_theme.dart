import 'package:flutter/material.dart';

class AppTheme {
  // ─── Couleurs fixes (light) ───────────────────────────────────────
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

  // ─── Gradient ────────────────────────────────────────────────────
  static LinearGradient get gradient => const LinearGradient(
    colors: [Color(0xFF1a73e8), Color(0xFF0d47a1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Theme Light ─────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: cardBg,
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
    extensions: const [AppColors.light],
  );

  // ─── Theme Dark ──────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0f1923),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1e2d3d),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: const Color(0xFF1e2d3d),
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
      fillColor: const Color(0xFF1e2d3d),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF2d3f50), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color(0xFF2d3f50), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
    ),
    extensions: const [AppColors.dark],
  );

  // ─── Ancien getter theme (compatibilité) ─────────────────────────
  // Gardé pour ne pas casser les fichiers qui utilisent AppTheme.theme
  static ThemeData get theme => lightTheme;
}

// ─── Extension couleurs dynamiques (light/dark) ──────────────────────
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color cardBg;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const AppColors({
    required this.background,
    required this.cardBg,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  // ── Valeurs Light ──
  static const light = AppColors(
    background:    Color(0xFFf8faff),
    cardBg:        Color(0xFFffffff),
    border:        Color(0xFFe0e8ff),
    textPrimary:   Color(0xFF1a1a2e),
    textSecondary: Color(0xFF888888),
  );

  // ── Valeurs Dark ──
  static const dark = AppColors(
    background:    Color(0xFF0f1923),
    cardBg:        Color(0xFF1e2d3d),
    border:        Color(0xFF2d3f50),
    textPrimary:   Color(0xFFe8eaf0),
    textSecondary: Color(0xFF8a9bb0),
  );

  // ── Helpers pour accéder facilement depuis le contexte ──
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? background,
    Color? cardBg,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
  }) =>
      AppColors(
        background:    background    ?? this.background,
        cardBg:        cardBg        ?? this.cardBg,
        border:        border        ?? this.border,
        textPrimary:   textPrimary   ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background:    Color.lerp(background,    other.background,    t)!,
      cardBg:        Color.lerp(cardBg,        other.cardBg,        t)!,
      border:        Color.lerp(border,        other.border,        t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

// ─── ThemeNotifier (mode sombre) ─────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode  => _mode;
  bool get isDark     => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDark(bool value) {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}