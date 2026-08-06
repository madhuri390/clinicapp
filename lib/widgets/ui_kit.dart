import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import '../theme/patient_portal_theme.dart';

/// Shared, reusable building blocks for the refreshed patient-portal UI:
/// gradient canvas, animated screen entrances, page transitions, hero icon
/// badges and gradient text.

// ─────────────────────────────────────────────────────────────────────────────
// Gradient canvas
// ─────────────────────────────────────────────────────────────────────────────

/// The page canvas: a cool off-white that fades from the faintest brand tint at
/// the top edge. One soft wash sits behind the header area so the first card on
/// a screen has something to lift off; the rest of the page stays flat, which
/// is what keeps dense clinical content readable.
///
/// Applied once for the whole app in `main.dart` via `MaterialApp.builder`, so
/// individual screens only need `Scaffold(backgroundColor: Colors.transparent)`
/// — which is now the theme default.
///
/// Nesting is safe: a second instance inside an existing canvas is a
/// pass-through, so the wash and the glow blob never double up.
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (_GradientCanvasScope.isInside(context)) return child;
    return _GradientCanvasScope(
      child: Stack(
        // Expand, not the default loose fit: as the app-wide root this wraps
        // the Navigator, and under loose constraints a full-screen child can
        // shrink-wrap to nothing.
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: PatientPortalTheme.scaffoldGradient,
              ),
            ),
          ),
          const Positioned(
            top: -140,
            right: -100,
            child: _GlowBlob(size: 320, color: AppTokens.accent),
          ),
          child,
        ],
      ),
    );
  }
}

/// Marks the subtree that already has a gradient canvas painted above it.
class _GradientCanvasScope extends InheritedWidget {
  const _GradientCanvasScope({required super.child});

  static bool isInside(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_GradientCanvasScope>() != null;

  @override
  bool updateShouldNotify(_GradientCanvasScope oldWidget) => false;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.10),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Entrance animation
// ─────────────────────────────────────────────────────────────────────────────

/// Fades + slides its [child] up on first build. Pass an increasing [index] to
/// stagger a column of cards so they cascade in.
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.offset = 24,
    this.duration = const Duration(milliseconds: 450),
    this.delayUnit = const Duration(milliseconds: 80),
  });

  final Widget child;
  final int index;
  final double offset;
  final Duration duration;
  final Duration delayUnit;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delayUnit * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page transition
// ─────────────────────────────────────────────────────────────────────────────

/// Smooth fade + gentle slide-from-right route used for all in-portal
/// navigation, replacing the abrupt platform default.
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  FadeSlideRoute({required this.page, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 360),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (_, animation, _, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );

  final Widget page;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero icon badge
// ─────────────────────────────────────────────────────────────────────────────

/// A rounded-square gradient tile holding a white icon, with a soft coloured
/// glow — the "hero icon" treatment from the inspiration.
class HeroIconBadge extends StatelessWidget {
  const HeroIconBadge({
    super.key,
    required this.icon,
    this.size = 52,
    this.iconSize,
    this.gradient,
    this.glowColor,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final Gradient? gradient;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? PatientPortalTheme.buttonGradient;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: g,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: AppTokens.accentGlow(
          glowColor ?? AppTokens.accent,
        ),
      ),
      child: Icon(icon, color: Colors.white, size: iconSize ?? size * 0.46),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient text
// ─────────────────────────────────────────────────────────────────────────────

/// Paints [text] with a gradient — used for accent words in hero headlines.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = PatientPortalTheme.buttonGradient,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary gradient button
// ─────────────────────────────────────────────────────────────────────────────

/// Pill-shaped gradient CTA matching the inspiration's primary buttons, with a
/// subtle press animation.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: AppTokens.fast,
        curve: AppTokens.ease,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: enabled ? PatientPortalTheme.buttonGradient : null,
            color: enabled ? null : AppTokens.subtle,
            borderRadius: AppTokens.brMd,
            boxShadow: enabled ? AppTokens.accentGlow() : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: enabled ? Colors.white : AppTokens.muted,
                  size: 19,
                ),
                const SizedBox(width: AppTokens.s8),
              ],
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: enabled ? Colors.white : AppTokens.muted,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
