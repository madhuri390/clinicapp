import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';

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
    final phone = p?.phone ?? '+1 (555) 123-4567';
    final email =
        p?.email ?? '${p?.firstName.toLowerCase() ?? 'sarah.johnson'}@email.com';
    final address =
        p?.address ?? '123 Oak Street, Apartment 4B, Springfield, IL 62701';
    final regDate = p?.createdAt != null
        ? ProfileTab.formatDate(p!.createdAt!)
        : 'Jan 15, 2024';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 24),
                _ContactRow(icon: Icons.phone_outlined, text: phone),
                const SizedBox(height: 20),
                _ContactRow(icon: Icons.mail_outlined, text: email),
                const SizedBox(height: 20),
                _ContactRow(icon: Icons.location_on_outlined, text: address),
                const SizedBox(height: 20),
                _ContactRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Registered: $regDate',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Conditions',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _AllergyPill('Penicillin Allergy'),
                    _AllergyPill('Diabetes'),
                    _AllergyPill('Hypertension'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _AllergyPill extends StatelessWidget {
  const _AllergyPill(this.type);

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

