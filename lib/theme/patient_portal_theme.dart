import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette aligned with Prodontics logo (sky → navy gradient).
abstract final class PatientPortalTheme {
  static const Color skyBlue = Color(0xFF00AEEF);
  static const Color navyBlue = Color(0xFF003366);
  static const Color surface = Color(0xFFF3F9FC);
  static const Color surfaceElevated = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static LinearGradient get headerGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF00AEEF),
          Color(0xFF0088C6),
          Color(0xFF003366),
        ],
        stops: [0.0, 0.45, 1.0],
      );

  static LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [skyBlue, navyBlue],
      );

  static List<BoxShadow> cardShadow(BuildContext context) => [
        BoxShadow(
          color: navyBlue.withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      boxShadow: cardShadow(context),
      border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
    );
  }

  static TextStyle titleLarge(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle titleMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle label(BuildContext context) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 0.2,
      );

  /// Wraps the patient shell to tune Material defaults without affecting staff UI.
  static ThemeData themeOverlay(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: skyBlue,
        secondary: navyBlue,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
