import 'package:flutter/material.dart';

class TemaApp {
  static const Color _colorSemilla = Color(0xFF00695C);

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(
      seedColor: _colorSemilla,
      brightness: brillo,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        headlineSmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w600, color: esquema.onSurface),
        titleLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, color: esquema.onSurface),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: esquema.onSurface),
        bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400,
            color: esquema.onSurfaceVariant),
        labelSmall: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500,
            color: esquema.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}