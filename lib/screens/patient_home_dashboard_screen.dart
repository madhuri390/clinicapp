import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../services/appointment_store.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/patient_portal_logo.dart';
import 'patient_prescriptions_screen.dart';

/// Patient home: brand hero, upcoming visits, prescriptions entry.
class PatientHomeDashboardScreen extends StatefulWidget {
  const PatientHomeDashboardScreen({super.key});

  @override
  State<PatientHomeDashboardScreen> createState() =>
      _PatientHomeDashboardScreenState();
}

class _PatientHomeDashboardScreenState
    extends State<PatientHomeDashboardScreen> {
  final _store = AppointmentStore.instance;

  List<Appointment> get _myUpcoming {
    final id = PatientSession.portalPatientId;
    if (id == null) return [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _store
        .getAppointmentsForPatient(id)
        .where(
          (a) =>
              a.status == AppointmentStatus.scheduled &&
              !a.date.isBefore(today),
        )
        .toList()
      ..sort((a, b) {
        final da = a.date.compareTo(b.date);
        if (da != 0) return da;
        return a.timeSlot.compareTo(b.timeSlot);
      });
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _myUpcoming.take(5).toList();
    final name = PatientSession.portalPatientName ?? 'there';
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: PatientPortalTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, topInset + 20, 24, 36),
                  decoration: BoxDecoration(
                    gradient: PatientPortalTheme.headerGradient,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PatientPortalTheme.navyBlue.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const PatientPortalLogo(height: 56),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prodontics',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hello, $name',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.15,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your care at a glance — book visits anytime from Appointments.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Upcoming visits',
                  style: PatientPortalTheme.titleMedium(context),
                ),
                const SizedBox(height: 6),
                Text(
                  upcoming.isEmpty
                      ? 'Nothing scheduled yet — tap Appointments to book.'
                      : '${upcoming.length} scheduled',
                  style: PatientPortalTheme.body(context),
                ),
                const SizedBox(height: 16),
                if (upcoming.isNotEmpty)
                  ...upcoming.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SleekAppointmentTile(appointment: a),
                    ),
                  ),
                if (upcoming.isEmpty)
                  _EmptyStateCard(
                    icon: Icons.event_available_rounded,
                    message: 'No upcoming appointments',
                  ),
                const SizedBox(height: 28),
                _PrescriptionHeroCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PatientPrescriptionsScreen(),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleekAppointmentTile extends StatelessWidget {
  const _SleekAppointmentTile({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(appointment.date);
    return Container(
      decoration: PatientPortalTheme.cardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: PatientPortalTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: PatientPortalTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appointment.timeRange} · ${appointment.type}',
                    style: PatientPortalTheme.body(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: PatientPortalTheme.cardDecoration(context),
      child: Column(
        children: [
          Icon(icon, size: 40, color: PatientPortalTheme.skyBlue.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: PatientPortalTheme.body(context),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionHeroCard extends StatelessWidget {
  const _PrescriptionHeroCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: PatientPortalTheme.accentGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: PatientPortalTheme.skyBlue.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View prescriptions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Medicines and instructions from your visits',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
