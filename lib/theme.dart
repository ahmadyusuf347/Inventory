import 'package:flutter/material.dart';

/// Palet warna hangat ala dashboard Claude.
class C {
  static const bg = Color(0xFFF5F4ED);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFAF9F5);
  static const border = Color(0xFFE8E6DC);
  static const text = Color(0xFF141413);
  static const muted = Color(0xFF6B6A64);
  static const accent = Color(0xFFD97757);
  static const accentSoft = Color(0xFFF6E3DA);
  static const ok = Color(0xFF5B8C5A);
  static const okSoft = Color(0xFFE3EEDF);
  static const warn = Color(0xFFC8872B);
  static const warnSoft = Color(0xFFF8EBD3);
  static const danger = Color(0xFFB5453A);
  static const dangerSoft = Color(0xFFF8E3E0);
}

TextStyle serif(double size,
    {FontWeight weight = FontWeight.w500, Color color = C.text}) {
  return TextStyle(
    fontFamily: 'serif',
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: -0.2,
    height: 1.2,
  );
}

ThemeData buildTheme() {
  const scheme = ColorScheme.light(
    primary: C.accent,
    onPrimary: Colors.white,
    secondary: C.accent,
    onSecondary: Colors.white,
    surface: C.bg,
    onSurface: C.text,
    error: C.danger,
    outline: C.border,
  );

  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    dividerColor: C.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: C.text,
      centerTitle: false,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: C.accentSoft,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(C.border),
      enabledBorder: border(C.border),
      focusedBorder: border(C.accent),
      errorBorder: border(C.danger),
      focusedErrorBorder: border(C.danger),
      labelStyle: const TextStyle(color: C.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.text,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: C.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
