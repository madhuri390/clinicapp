import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../services/appointment_store.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/add_appointment_sheet.dart';
import '../widgets/patient_portal_logo.dart';

/// Patient-facing: list own appointments and book new ones.
class PatientPortalAppointmentsScreen extends StatefulWidget {
  const PatientPortalAppointmentsScreen({super.key});

  @override
  State<PatientPortalAppointmentsScreen> createState() =>
      _PatientPortalAppointmentsScreenState();
}

class _PatientPortalAppointmentsScreenState
    extends State<PatientPortalAppointmentsScreen> {
  final _store = AppointmentStore.instance;

  void _refresh() => setState(() {});

  void _book() {
    final pid = PatientSession.portalPatientId;
    final linked = PatientSession.linked;
    final name =
        PatientSession.portalPatientName ?? linked?.fullName ?? 'Patient';
    final rawPhone = linked?.phone.trim() ?? '';
    final safePhone = rawPhone.isNotEmpty ? rawPhone : '9999999999';

    if (pid == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddAppointmentSheet(
        selectedDate: DateTime.now(),
        onSaved: _refresh,
        prefilledPatientId: pid,
        prefilledPatientName: name,
        prefilledPatientPhone: safePhone,
      ),
    );
  }

  void _showDetails(Appointment a) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: PatientPortalTheme.accentGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.event_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      a.type,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: PatientPortalTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow('Date', DateFormat('EEEE, MMM d, y').format(a.date)),
              _detailRow('Time', a.timeRange),
              _detailRow('Doctor', a.doctorName),
              _detailRow('Status', a.status.name),
              if (a.notes != null && a.notes!.isNotEmpty)
                _detailRow('Notes', a.notes!),
              if (a.doctorMessage != null && a.doctorMessage!.isNotEmpty)
                _detailRow('Clinic message', a.doctorMessage!),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: PatientPortalTheme.skyBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _detailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: PatientPortalTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            v,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: PatientPortalTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pid = PatientSession.portalPatientId;
    if (pid == null) {
      return Scaffold(
        backgroundColor: PatientPortalTheme.surface,
        body: Center(
          child: Text(
            'Could not load appointments.',
            style: PatientPortalTheme.body(context),
          ),
        ),
      );
    }

    final mine = _store.getAppointmentsForPatient(pid);
    final active = mine
        .where(
          (a) =>
              a.status == AppointmentStatus.scheduled ||
              a.status == AppointmentStatus.ongoing,
        )
        .toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        return a.timeSlot.compareTo(b.timeSlot);
      });
    final past = mine
        .where(
          (a) =>
              a.status == AppointmentStatus.completed ||
              a.status == AppointmentStatus.cancelled ||
              a.status == AppointmentStatus.rescheduled,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: PatientPortalTheme.surface,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _book,
            borderRadius: BorderRadius.circular(30),
            child: Ink(
              decoration: BoxDecoration(
                gradient: PatientPortalTheme.accentGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: PatientPortalTheme.skyBlue.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Book visit',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const PatientPortalLogo(height: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointments',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: PatientPortalTheme.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        Text(
                          'Book and review your visits',
                          style: PatientPortalTheme.body(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Upcoming', style: PatientPortalTheme.titleMedium(context)),
                const SizedBox(height: 12),
                if (active.isEmpty)
                  const _EmptyLine('No upcoming appointments.')
                else
                  ...active.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentCard(
                        appointment: a,
                        onTap: () => _showDetails(a),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                Text('Past & other', style: PatientPortalTheme.titleMedium(context)),
                const SizedBox(height: 12),
                if (past.isEmpty)
                  const _EmptyLine('No history yet.')
                else
                  ...past.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AppointmentCard(
                        appointment: a,
                        onTap: () => _showDetails(a),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: PatientPortalTheme.body(context)),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y').format(appointment.date);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: PatientPortalTheme.cardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: PatientPortalTheme.accentGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.type,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: PatientPortalTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr · ${appointment.timeRange}',
                        style: PatientPortalTheme.body(context),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: PatientPortalTheme.skyBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appointment.status.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: PatientPortalTheme.navyBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: PatientPortalTheme.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
