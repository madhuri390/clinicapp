import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';

// ── Reference design palette (single source of truth) ─────────────────────
const kRefPrimary   = Color(0xFF0D8DC4);
const kRefPrimaryDk = Color(0xFF0A719D);
const kRefDark      = Color(0xFF0F172A);
const kRefMuted     = Color(0xFF5B6E8C);
const kRefTabInactive = Color(0xFF94A3B8);
const kRefBorder    = Color(0xFFEDF2F7);
const kRefScreenBg  = Color(0xFFF9FAFE);

/// Header matching `.main-header > .header-row > .patient-header + .new-btn`.
class PatientHeader extends StatelessWidget {
  const PatientHeader({
    super.key,
    this.patient,
    required this.displayName,
    this.onBack,
    this.onNewConsultation,
    this.onEdit,
    this.editTooltip = 'Edit Patient',
  });

  final Patient? patient;
  final String displayName;
  final VoidCallback? onBack;
  final VoidCallback? onNewConsultation;
  final VoidCallback? onEdit;
  final String editTooltip;

  @override
  Widget build(BuildContext context) {
    final name = patient?.fullName ?? displayName;
    final age = patient?.age;
    final gender = patient?.gender;
    final initials = _initials(name);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kRefBorder, width: 1)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: onBack,
              color: kRefMuted,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(right: 8),
              visualDensity: VisualDensity.compact,
            ),
          ],
          // Gradient avatar (48×48, borderRadius 28)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [kRefPrimary, kRefPrimaryDk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.lato(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kRefDark,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        onPressed: onEdit,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: kRefTabInactive,
                        tooltip: editTooltip,
                      ),
                  ],
                ),
                if (age != null || (gender != null && gender.isNotEmpty))
                  Text(
                    [
                      if (age != null) '$age yrs',
                      if (gender != null && gender.isNotEmpty) gender,
                    ].join(' · '),
                    style: GoogleFonts.lato(fontSize: 12, color: kRefMuted),
                  ),
              ],
            ),
          ),
          if (onNewConsultation != null)
            GestureDetector(
              onTap: onNewConsultation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kRefPrimary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kRefPrimary.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'New Visit',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
