import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import 'patient_details_header.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROFILE TAB  —  matches referencedesign.html #profileScreen exactly
// ═══════════════════════════════════════════════════════════════════════════

class ProfileTab extends StatelessWidget {
  const ProfileTab({this.patient, required this.isLoading, super.key});

  final Patient? patient;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final p = patient;
    final phone = p?.phone ?? '+91 8688957695';
    final email =
        p?.email ?? '${p?.firstName.toLowerCase() ?? 'user'}@gmail.com';
    final address = p?.address ?? '123 Oak Street, Springfield, IL';
    final regDate = p?.createdAt != null
        ? ProfileTab.formatDate(p!.createdAt!)
        : 'Apr 17, 2026';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // ── Contact details card (.info-card) ─────────────────────
          _InfoCard(
            children: [
              const _SectionTitle(
                icon: Icons.badge_outlined,
                label: 'Contact details',
              ),
              const SizedBox(height: 16),
              _ContactRow(icon: Icons.phone_outlined, text: phone),
              _ContactRow(icon: Icons.email_outlined, text: email),
              _ContactRow(icon: Icons.location_on_outlined, text: address),
              _ContactRow(
                icon: Icons.calendar_today_outlined,
                text: 'Registered: $regDate',
                isMuted: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Medical Conditions card (.info-card) ──────────────────
          _InfoCard(
            children: [
              const _SectionTitle(
                icon: Icons.medical_information_outlined,
                label: 'Medical Conditions',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  _ConditionTag(icon: Icons.warning_amber_rounded, label: 'Penicillin Allergy'),
                  _ConditionTag(icon: Icons.water_drop_outlined, label: 'Diabetes'),
                  _ConditionTag(icon: Icons.favorite_border, label: 'Hypertension'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: kRefMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Last updated Apr 10, 2026',
                    style: GoogleFonts.lato(fontSize: 12, color: kRefMuted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ─── Reusable building blocks ────────────────────────────────────────────

/// Card wrapper — `.info-card`:  white, radius 28, border #eff3f8, shadow.
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kRefBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000), // 0.02 opacity
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Section title — `.section-title`:  blue left border + icon + text.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: kRefPrimary, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kRefPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kRefDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact row — `.contact-row + .contact-icon`.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.text,
    this.isMuted = false,
  });
  final IconData icon;
  final String text;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Icon(icon, size: 18, color: kRefPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: isMuted ? kRefMuted : kRefDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Condition tag — `.condition-tag`:  grey pill #F1F5F9, rounded 40, icon + text.
class _ConditionTag extends StatelessWidget {
  const _ConditionTag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kRefMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: kRefDark,
            ),
          ),
        ],
      ),
    );
  }
}
