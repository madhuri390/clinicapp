import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
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
  final _repo = AppointmentRepository();
  bool _loading = true;
  List<Appointment> _mine = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pid = PatientSession.portalPatientId;
    if (pid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await _repo.getForPatient(pid);
      if (!mounted) return;
      setState(() {
        _mine = list;
        _loading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load appointments. Pull to refresh or try again later.';
      });
    }
  }

  void _book() {
    final pid = PatientSession.portalPatientId;
    final linked = PatientSession.linked;
    final name =
        PatientSession.portalPatientName ?? linked?.fullName ?? 'Patient';
    final phone = (linked?.phone ?? '').trim();

    if (pid == null) return;
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your profile is missing a phone number. Please update it first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddAppointmentSheet(
        selectedDate: DateTime.now(),
        onSaved: _load,
        prefilledPatientId: pid,
        prefilledPatientName: name,
        prefilledPatientPhone: phone,
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

    final mine = _mine;
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

    return Scaffold(
      backgroundColor: PatientPortalTheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        color: PatientPortalTheme.skyBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 16,
                  20,
                  8,
                ),
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
            if (_loadError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Material(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _loadError!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade900,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Upcoming', style: PatientPortalTheme.titleMedium(context)),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (active.isEmpty)
                    _AppointmentEmptyCard(
                      icon: Icons.event_available_rounded,
                      title: 'No upcoming visits',
                      subtitle: 'Tap Book visit to choose a doctor and time.',
                    )
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
                  if (!_loading) ...[
                    const SizedBox(height: 28),
                    Text('Past & other', style: PatientPortalTheme.titleMedium(context)),
                    const SizedBox(height: 12),
                    if (past.isEmpty)
                      _AppointmentEmptyCard(
                        icon: Icons.history_rounded,
                        title: 'No past appointments yet',
                        subtitle: 'Completed and cancelled visits will show up here.',
                      )
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
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _book,
            borderRadius: BorderRadius.circular(30),
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
    );
  }
}

class _AppointmentEmptyCard extends StatelessWidget {
  const _AppointmentEmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PatientPortalTheme.skyBlue.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PatientPortalTheme.skyBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: PatientPortalTheme.skyBlue, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: PatientPortalTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: PatientPortalTheme.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
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
