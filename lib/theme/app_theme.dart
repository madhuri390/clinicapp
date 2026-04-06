import 'package:flutter/material.dart';

/// Clinic app theme with primary #0D8DC4, white background, black/grey text.
class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF0D8DC4);

  /// Login screen: soft blue tints derived from primary 0xFF0D8DC4
  static const Color loginBackground = Color(0xFFE6F3FA); // light blue
  static const Color loginAccent = Color(0xFF0D8DC4); // primary blue
  static const Color loginAccentLight = Color(0xFF90CDEC); // highlight circle
  static const Color loginShapeColor = Color(
    0x4D0D8DC4,
  ); // soft circles (30% opacity)
  static const Color lightBlueBackground = Color(
    0xFFEAF5FB,
  ); // soft blue for screens

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: Colors.white,
        onSurface: Colors.black87,
        onSurfaceVariant: Colors.black54,
        outline: Colors.grey.shade400,
      ),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
