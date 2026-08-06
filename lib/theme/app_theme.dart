import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// The app-wide Material theme, built entirely from [AppTokens].
///
/// Both the staff app and the patient portal run on this theme — the portal
/// layers only surface treatments on top (see `PatientPortalTheme`), never its
/// own palette or type scale.
abstract final class AppTheme {
  // Kept for the handful of call sites that still reference the old constants.
  static const Color primaryColor = AppTokens.accent;
  static const Color lightBlueBackground = AppTokens.accentSofter;
  static const Color loginBackground = AppTokens.canvas;
  static const Color loginAccent = AppTokens.accent;
  static const Color loginAccentLight = Color(0xFF93B4F7);
  static const Color loginShapeColor = Color(0x262563EB);

  // ── Type scale ────────────────────────────────────────────────────────────
  // Plus Jakarta Sans throughout. Headings get negative tracking and tight
  // leading — that pairing is most of what separates "premium" from "default".

  static TextTheme get textTheme {
    TextStyle jakarta({
      required double size,
      required FontWeight weight,
      required Color color,
      double? tracking,
      double? height,
    }) =>
        GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: weight,
          color: color,
          letterSpacing: tracking,
          height: height,
        );

    return TextTheme(
      // Hero numbers and screen-opening statements.
      displaySmall: jakarta(
        size: 32,
        weight: FontWeight.w800,
        color: AppTokens.ink,
        tracking: -0.8,
        height: 1.12,
      ),
      headlineMedium: jakarta(
        size: 26,
        weight: FontWeight.w800,
        color: AppTokens.ink,
        tracking: -0.6,
        height: 1.18,
      ),
      headlineSmall: jakarta(
        size: 22,
        weight: FontWeight.w700,
        color: AppTokens.ink,
        tracking: -0.4,
        height: 1.22,
      ),
      // Card titles and section headers.
      titleLarge: jakarta(
        size: 18,
        weight: FontWeight.w700,
        color: AppTokens.ink,
        tracking: -0.3,
        height: 1.3,
      ),
      titleMedium: jakarta(
        size: 16,
        weight: FontWeight.w700,
        color: AppTokens.ink,
        tracking: -0.2,
        height: 1.35,
      ),
      titleSmall: jakarta(
        size: 14,
        weight: FontWeight.w600,
        color: AppTokens.ink,
        tracking: -0.1,
        height: 1.4,
      ),
      // Running text.
      bodyLarge: jakarta(
        size: 15,
        weight: FontWeight.w500,
        color: AppTokens.body,
        height: 1.5,
      ),
      bodyMedium: jakarta(
        size: 14,
        weight: FontWeight.w500,
        color: AppTokens.body,
        height: 1.5,
      ),
      bodySmall: jakarta(
        size: 12.5,
        weight: FontWeight.w500,
        color: AppTokens.muted,
        height: 1.45,
      ),
      // Buttons, chips, field labels.
      labelLarge: jakarta(
        size: 15,
        weight: FontWeight.w700,
        color: AppTokens.onAccent,
        tracking: 0.1,
      ),
      labelMedium: jakarta(
        size: 13,
        weight: FontWeight.w600,
        color: AppTokens.body,
        tracking: 0.1,
      ),
      // Small all-caps eyebrows above sections.
      labelSmall: jakarta(
        size: 11,
        weight: FontWeight.w700,
        color: AppTokens.muted,
        tracking: 0.8,
      ),
    );
  }

  static ColorScheme get colorScheme => const ColorScheme.light(
        primary: AppTokens.accent,
        onPrimary: AppTokens.onAccent,
        primaryContainer: AppTokens.accentSoft,
        onPrimaryContainer: AppTokens.accentDeep,
        secondary: AppTokens.accentDark,
        onSecondary: AppTokens.onAccent,
        surface: AppTokens.surface,
        onSurface: AppTokens.ink,
        surfaceContainerLowest: AppTokens.surface,
        surfaceContainerLow: AppTokens.canvas,
        surfaceContainer: AppTokens.subtle,
        onSurfaceVariant: AppTokens.body,
        outline: AppTokens.hairline,
        outlineVariant: AppTokens.hairline,
        error: AppTokens.danger,
        onError: Colors.white,
        errorContainer: AppTokens.dangerSoft,
        onErrorContainer: AppTokens.danger,
      );

  static ThemeData get lightTheme {
    final text = textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: text,
      // Transparent so the app-wide gradient canvas (painted in `main.dart`)
      // shows through every screen. Screens that need an opaque backdrop must
      // set it on their own container, not on the Scaffold.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: AppTokens.canvas,
      dividerColor: AppTokens.hairline,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppTokens.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: AppTokens.pageInset,
        titleTextStyle: text.titleLarge,
        iconTheme: const IconThemeData(color: AppTokens.ink, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: AppTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppTokens.brLg,
          side: const BorderSide(color: AppTokens.hairline),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppTokens.hairline,
        thickness: 1,
        space: 1,
      ),

      // ── Fields ──────────────────────────────────────────────────────────
      // Filled and borderless at rest; the border only appears on focus, which
      // keeps dense forms from turning into a grid of boxes.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.subtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s16,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppTokens.brMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppTokens.brMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppTokens.brMd,
          borderSide: BorderSide(color: AppTokens.accent, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppTokens.brMd,
          borderSide: BorderSide(color: AppTokens.danger, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppTokens.brMd,
          borderSide: BorderSide(color: AppTokens.danger, width: 1.6),
        ),
        hintStyle: text.bodyMedium?.copyWith(color: AppTokens.muted),
        labelStyle: text.labelMedium,
        floatingLabelStyle: text.labelMedium?.copyWith(color: AppTokens.accent),
        prefixIconColor: AppTokens.muted,
        suffixIconColor: AppTokens.muted,
        errorStyle: text.bodySmall?.copyWith(color: AppTokens.danger),
      ),

      // ── Buttons ─────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.accent,
          foregroundColor: AppTokens.onAccent,
          disabledBackgroundColor: AppTokens.subtle,
          disabledForegroundColor: AppTokens.muted,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s24),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.brMd),
          elevation: 0,
          textStyle: text.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.accent,
          foregroundColor: AppTokens.onAccent,
          minimumSize: const Size(0, 54),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.brMd),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.ink,
          backgroundColor: AppTokens.surface,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s24),
          side: const BorderSide(color: AppTokens.hairline),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.brMd),
          textStyle: text.labelLarge?.copyWith(color: AppTokens.ink),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.s12,
            vertical: AppTokens.s8,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppTokens.brSm),
          textStyle: text.labelLarge?.copyWith(color: AppTokens.accent),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppTokens.body,
          highlightColor: AppTokens.accentSoft,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTokens.accent,
        foregroundColor: AppTokens.onAccent,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.brLg),
      ),

      // ── Chips & tabs ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.surface,
        selectedColor: AppTokens.accent,
        secondarySelectedColor: AppTokens.accent,
        disabledColor: AppTokens.subtle,
        side: const BorderSide(color: AppTokens.hairline),
        labelStyle: text.labelMedium!,
        secondaryLabelStyle: text.labelMedium!.copyWith(
          color: AppTokens.onAccent,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s12,
          vertical: AppTokens.s8,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppTokens.rPill)),
        ),
        showCheckmark: false,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppTokens.ink,
        unselectedLabelColor: AppTokens.muted,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppTokens.accent, width: 2.5),
          insets: EdgeInsets.symmetric(horizontal: 4),
        ),
        dividerColor: AppTokens.hairline,
      ),

      // ── Navigation ──────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTokens.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTokens.accentSoft,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? text.labelSmall?.copyWith(
                  color: AppTokens.accentDark,
                  letterSpacing: 0.2,
                  fontSize: 11.5,
                )
              : text.labelSmall?.copyWith(
                  color: AppTokens.muted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  fontSize: 11.5,
                ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? AppTokens.accentDark
                : AppTokens.muted,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppTokens.surface,
        selectedItemColor: AppTokens.accentDark,
        unselectedItemColor: AppTokens.muted,
        selectedLabelStyle: text.labelSmall?.copyWith(letterSpacing: 0.2),
        unselectedLabelStyle: text.labelSmall?.copyWith(letterSpacing: 0.2),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Overlays ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.brXl),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppTokens.hairline,
        dragHandleSize: Size(40, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.rXl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: loginAccentLight,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppTokens.s16),
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.brMd),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.brMd),
        textStyle: text.bodyMedium?.copyWith(color: AppTokens.ink),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: AppTokens.ink,
          borderRadius: AppTokens.brSm,
        ),
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
      ),

      // ── Controls ────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s4,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.brMd),
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        iconColor: AppTokens.body,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppTokens.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppTokens.accent
              : AppTokens.hairline,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppTokens.accent
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: AppTokens.muted, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppTokens.accent
              : AppTokens.muted,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.accent,
        linearTrackColor: AppTokens.subtle,
        circularTrackColor: AppTokens.subtle,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppTokens.accent,
        inactiveTrackColor: AppTokens.subtle,
        thumbColor: AppTokens.accent,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
