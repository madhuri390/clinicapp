import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../theme/patient_portal_theme.dart';
import '../theme/app_tokens.dart';

// ── Reference design palette (single source of truth) ─────────────────────
const kRefPrimary   = AppTokens.accent;
const kRefPrimaryDk = AppTokens.accentDark;
const kRefDark      = AppTokens.ink;
const kRefMuted     = AppTokens.body;
const kRefTabInactive = AppTokens.muted;
const kRefBorder    = AppTokens.subtle;
const kRefScreenBg  = AppTokens.canvas;

/// Patient identity block plus the screen's primary actions.
///
/// Identity sits on the first row; the actions get their own full-width row
/// beneath it as labelled buttons. An icon-only control was too small to hit
/// and gave no clue what it did.
class PatientHeader extends StatelessWidget {
  const PatientHeader({
    super.key,
    this.patient,
    required this.displayName,
    this.onBack,
    this.onNewConsultation,
    this.onEdit,
    this.editLabel = 'Edit details',
  });

  final Patient? patient;
  final String displayName;
  final VoidCallback? onBack;
  final VoidCallback? onNewConsultation;
  final VoidCallback? onEdit;

  /// Label on the edit button — "Update profile" in the patient portal.
  final String editLabel;

  @override
  Widget build(BuildContext context) {
    final name = patient?.fullName ?? displayName;
    final age = patient?.age;
    final gender = patient?.gender;
    final blood = patient?.bloodGroup;
    final phone = patient?.phone;

    final facts = <String>[
      if (age != null) '$age yrs',
      if (gender != null && gender.isNotEmpty) gender,
      if (blood != null && blood.isNotEmpty && blood != 'Unknown') blood,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onBack != null) ...[
                _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack!),
                const SizedBox(width: 10),
              ],
              _Avatar(initials: _initials(name)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: kRefDark,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (facts.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [for (final f in facts) _FactChip(label: f)],
                      ),
                    ] else if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: kRefMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (onEdit != null || onNewConsultation != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: _HeaderAction(
                      label: editLabel,
                      icon: Icons.edit_outlined,
                      onPressed: onEdit!,
                    ),
                  ),
                if (onEdit != null && onNewConsultation != null)
                  const SizedBox(width: 10),
                if (onNewConsultation != null)
                  Expanded(
                    child: _HeaderAction(
                      label: 'New visit',
                      icon: Icons.add_rounded,
                      onPressed: onNewConsultation!,
                      primary: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}

// ── Header pieces ───────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        gradient: PatientPortalTheme.accentGradient,
        boxShadow: PatientPortalTheme.glow(PatientPortalTheme.brightSky),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      shape: CircleBorder(side: BorderSide(color: AppTokens.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 15, color: kRefDark),
        ),
      ),
    );
  }
}

/// Small tinted pill carrying one fact about the patient.
class _FactChip extends StatelessWidget {
  const _FactChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppTokens.accentSoft,
        borderRadius: const BorderRadius.all(Radius.circular(AppTokens.rPill)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: kRefPrimaryDk,
          height: 1.25,
        ),
      ),
    );
  }
}

/// Header CTA. [primary] fills with the brand gradient; otherwise it is a
/// white pill with a hairline border so the two read as a clear hierarchy.
class _HeaderAction extends StatefulWidget {
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  State<_HeaderAction> createState() => _HeaderActionState();
}

class _HeaderActionState extends State<_HeaderAction> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.primary;
    final fg = primary ? Colors.white : kRefPrimaryDk;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: AppTokens.fast,
        curve: AppTokens.ease,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: primary ? PatientPortalTheme.buttonGradient : null,
            color: primary ? null : AppTokens.surface,
            borderRadius: const BorderRadius.all(Radius.circular(AppTokens.rPill)),
            border: primary ? null : Border.all(color: AppTokens.hairline),
            boxShadow: primary ? AppTokens.accentGlow() : AppTokens.shadowSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 17, color: fg),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tab bar delegate matching `.tab-bar` — underline-style, not pill-style.
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this.tabBar, {this.backgroundColor});
  final TabBar tabBar;
  final Color? backgroundColor;

  @override
  double get minExtent => 48.0;
  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar || oldDelegate.backgroundColor != backgroundColor;
}
