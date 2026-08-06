import 'package:flutter/material.dart';

/// The single source of truth for the Prodontics visual language.
///
/// Every colour, radius, gap and shadow in the app should come from here so the
/// staff side and the patient portal stay in step. Nothing in this file depends
/// on `BuildContext` — it is pure design data.
abstract final class AppTokens {
  // ── Brand ramp ────────────────────────────────────────────────────────────
  // Built around the clinic blue (#2563EB), with a darker pressed state and
  // two tints for fills that must sit under text.

  static const Color accent = Color(0xFF2563EB);
  static const Color accentDark = Color(0xFF1D4ED8);
  static const Color accentDeep = Color(0xFF1E3A8A);
  static const Color accentSoft = Color(0xFFE8EFFD);
  static const Color accentSofter = Color(0xFFF4F7FE);

  // ── Ink ───────────────────────────────────────────────────────────────────
  // Near-black rather than pure black: reads as considered, not harsh.

  /// Headings, numbers, anything that should carry weight.
  static const Color ink = Color(0xFF0B1220);

  /// Body copy and secondary values.
  static const Color body = Color(0xFF5A6577);

  /// Captions, units, placeholder text. The lightest text that still passes
  /// 4.5:1 on [surface].
  static const Color muted = Color(0xFF8894A6);

  /// Text and icons on top of [accent].
  static const Color onAccent = Color(0xFFFFFFFF);

  // ── Surfaces ──────────────────────────────────────────────────────────────

  /// Cards, sheets, app bars.
  static const Color surface = Color(0xFFFFFFFF);

  /// The page behind the cards — a cool off-white so white cards separate.
  static const Color canvas = Color(0xFFF5F8FB);

  /// Inset fields, table stripes, disabled fills.
  static const Color subtle = Color(0xFFEFF3F8);

  /// 1px separators. Never use a shadow where a hairline will do.
  static const Color hairline = Color(0xFFE6ECF2);

  // ── Status ────────────────────────────────────────────────────────────────
  // Each pairs a saturated colour for text/icons with a tint for its chip.

  static const Color success = Color(0xFF0F9D6E);
  static const Color successSoft = Color(0xFFE6F6F0);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningSoft = Color(0xFFFDF3E2);
  static const Color danger = Color(0xFFD1483C);
  static const Color dangerSoft = Color(0xFFFCEDEB);
  static const Color info = accent;
  static const Color infoSoft = accentSoft;

  // ── Spacing ───────────────────────────────────────────────────────────────
  // A 4pt scale. Prefer these over ad-hoc SizedBox values.

  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;

  /// Standard horizontal page inset.
  static const double pageInset = 20;

  // ── Radii ─────────────────────────────────────────────────────────────────

  static const double rSm = 10;
  static const double rMd = 14;
  static const double rLg = 20;
  static const double rXl = 28;
  static const double rPill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(rXl));

  // ── Elevation ─────────────────────────────────────────────────────────────
  // Tinted with the brand navy instead of black, which keeps shadows from
  // looking grey and dirty over the cool canvas.

  static const Color _shadowTint = Color(0xFF0B1B3F);

  /// Resting cards. Barely there — depth comes from the canvas contrast.
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// Raised cards, the primary content of a screen.
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Sheets, dialogs, floating bars.
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: _shadowTint.withValues(alpha: 0.10),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  /// Coloured glow under a primary CTA. Use sparingly — one per screen.
  static List<BoxShadow> accentGlow([Color color = accent]) => [
        BoxShadow(
          color: color.withValues(alpha: 0.28),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Motion ────────────────────────────────────────────────────────────────

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve ease = Curves.easeOutCubic;

  // ── Composed decorations ──────────────────────────────────────────────────

  /// The default card: white, hairline border, whisper of shadow.
  static BoxDecoration get card => BoxDecoration(
        color: surface,
        borderRadius: brLg,
        border: Border.all(color: hairline),
        boxShadow: shadowSm,
      );

  /// A card that should pull focus — the hero block on a screen.
  static BoxDecoration get cardRaised => BoxDecoration(
        color: surface,
        borderRadius: brXl,
        border: Border.all(color: hairline),
        boxShadow: shadowMd,
      );

  /// Flat inset block for grouped rows and read-only values.
  static BoxDecoration get inset => const BoxDecoration(
        color: subtle,
        borderRadius: brMd,
      );

  /// Tinted container for a status or category chip.
  static BoxDecoration chip(Color tint) => BoxDecoration(
        color: tint,
        borderRadius: const BorderRadius.all(Radius.circular(rPill)),
      );
}
