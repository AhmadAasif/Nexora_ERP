import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF3457D5);
  static const Color ink = Color(0xFF18233B);
  static const Color muted = Color(0xFF7C879B);
  static const Color canvas = Color(0xFFF5F7FB);
  static const Color border = Color(0xFFE9EDF4);

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Roboto',
      dividerColor: border,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
    );
  }
}
