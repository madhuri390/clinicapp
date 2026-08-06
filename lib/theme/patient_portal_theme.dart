import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'app_tokens.dart';

/// Surface treatments for the patient portal.
///
/// The portal no longer carries its own palette or type scale — everything
/// resolves to [AppTokens] and [AppTheme] so the patient and staff sides are
/// one product. The names below are kept as a thin, stable facade over the
/// tokens for the screens that already consume them.
abstract final class PatientPortalTheme {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color skyBlue = AppTokens.accent;
  static const Color navyBlue = AppTokens.accentDeep;
  static const Color brightSky = AppTokens.accent;
  static const Color brightBlue = AppTokens.accentDark;

  // ── Tints ─────────────────────────────────────────────────────────────────
  // Formerly lavender/mint/peach pastels. Now a single-hue set, which is what
  // stops the portal from reading as a different app.
  static const Color lavender = AppTokens.accentSofter;
  static const Color skyTint = AppTokens.accentSoft;
  static const Color mint = AppTokens.successSoft;
  static const Color peach = AppTokens.warningSoft;

  // ── Surfaces & text ───────────────────────────────────────────────────────
  static const Color surface = AppTokens.canvas;
  static const Color surfaceElevated = AppTokens.surface;
  static const Color textPrimary = AppTokens.ink;
  static const Color textSecondary = AppTokens.body;

  // ── Gradients ─────────────────────────────────────────────────────────────

  /// The page canvas. Deliberately near-flat — depth now comes from card
  /// contrast and hairlines rather than a coloured wash.
  static const LinearGradient scaffoldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppTokens.accentSofter, AppTokens.canvas],
    stops: [0.0, 0.55],
  );

  /// Primary CTA fill. A tight two-stop ramp inside the brand hue reads as a
  /// solid colour with depth, not as a gradient.
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTokens.accent, AppTokens.accentDark],
  );

  static LinearGradient get headerGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTokens.accent, AppTokens.accentDark, AppTokens.accentDeep],
        stops: [0.0, 0.55, 1.0],
      );

  static LinearGradient get accentGradient => buttonGradient;

  // ── Elevation & cards ─────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow(BuildContext context) => AppTokens.shadowSm;

  static List<BoxShadow> glow(Color color) => AppTokens.accentGlow(color);

  static BoxDecoration cardDecoration(BuildContext context) => AppTokens.card;

  /// Previously a translucent "glass" panel. Now an opaque card — legibility
  /// over patient data beats the frosted effect.
  static BoxDecoration glassDecoration(BuildContext context) =>
      AppTokens.cardRaised;

  // ── Typography ────────────────────────────────────────────────────────────
  // Thin wrappers over the app text theme so the portal cannot drift.

  static TextStyle displayLarge(BuildContext context) =>
      AppTheme.textTheme.headlineMedium!;

  /// Accent word inside a hero headline, painted with [accentGradient].
  static TextStyle displayAccent(BuildContext context) =>
      AppTheme.textTheme.headlineMedium!.copyWith(
        fontStyle: FontStyle.italic,
      );

  static TextStyle titleLarge(BuildContext context) =>
      AppTheme.textTheme.titleLarge!;

  static TextStyle titleMedium(BuildContext context) =>
      AppTheme.textTheme.titleMedium!;

  static TextStyle body(BuildContext context) =>
      AppTheme.textTheme.bodyMedium!;

  static TextStyle label(BuildContext context) =>
      AppTheme.textTheme.labelMedium!;

  /// Wraps the patient shell. Only the transparent scaffold differs from the
  /// staff theme — the portal paints its own canvas behind the content.
  static ThemeData themeOverlay(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}
