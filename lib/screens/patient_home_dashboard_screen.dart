import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
import '../services/patient_session.dart';
import '../theme/app_theme.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/add_appointment_sheet.dart';
import '../widgets/patient_portal_shell_header.dart';

/// Patient home: doctor-style header, today's visits in one card, care shortcuts.
class PatientHomeDashboardScreen extends StatefulWidget {
  const PatientHomeDashboardScreen({
    super.key,
    this.onOpenOngoing,
    this.onOpenHistory,
  });

  final VoidCallback? onOpenOngoing;
  final VoidCallback? onOpenHistory;

  @override
  State<PatientHomeDashboardScreen> createState() =>
      _PatientHomeDashboardScreenState();
}

class _PatientHomeDashboardScreenState extends State<PatientHomeDashboardScreen> {
  final _repo = AppointmentRepository();
  bool _loading = true;
  String? _loadError;
  List<Appointment> _todayList = const [];

  DateTime _calendarDay(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final id = PatientSession.portalPatientId;
    if (id == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _todayList = const [];
          _loadError = 'Could not load your profile.';
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final all = await _repo.getForPatient(id);
      final today = _calendarDay(DateTime.now());
      final todayList = all
          .where((a) {
            final d = _calendarDay(a.date);
            final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
            final isActive = a.status == AppointmentStatus.scheduled || a.status == AppointmentStatus.ongoing;
            return isToday && isActive;
          })
          .toList()
        ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

      if (!mounted) return;
      setState(() {
        _todayList = todayList;
        _loading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load appointments. Pull to refresh.';
      });
    }
  }

  void _bookToday() {
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddAppointmentSheet(
        selectedDate: today,
        onSaved: () {
          _loadToday();
        },
        prefilledPatientId: pid,
        prefilledPatientName: name,
        prefilledPatientPhone: phone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = PatientSession.resolvedPortalDisplayName();

    return Scaffold(
      backgroundColor: PatientPortalTheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadToday,
        color: PatientPortalTheme.skyBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: PatientPortalShellHeader(
                title: 'Home',
                subtitle: 'Welcome back, $displayName',
              ),
            ),
            if (_loadError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    _loadError!,
                    style: PatientPortalTheme.body(context).copyWith(color: Colors.red.shade700),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TodayAppointmentsCard(
                    appointments: _loading ? const [] : _todayList,
                    onTapEmpty: _bookToday,
                    onTapTile: (a) => _showAppointmentDialog(a),
                    loading: _loading,
                  ),
                  const SizedBox(height: 24),
                  _CareGuidanceCard(
                    onOngoing: widget.onOpenOngoing,
                    onHistory: widget.onOpenHistory,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDialog(Appointment a) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.type,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: PatientPortalTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${DateFormat('EEEE, MMM d').format(a.date)} · ${a.timeRange}',
                style: PatientPortalTheme.body(context),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Close', style: GoogleFonts.inter(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayAppointmentsCard extends StatelessWidget {
  const _TodayAppointmentsCard({
    required this.appointments,
    required this.onTapEmpty,
    required this.onTapTile,
    required this.loading,
  });

  final List<Appointment> appointments;
  final VoidCallback onTapEmpty;
  final void Function(Appointment) onTapTile;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: PatientPortalTheme.cardDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: appointments.isEmpty ? onTapEmpty : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loading) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: PatientPortalTheme.skyBlue.withValues(alpha: 0.85),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Loading today's appointments…",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: PatientPortalTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(minHeight: 2),
                ] else if (appointments.isEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        color: PatientPortalTheme.skyBlue.withValues(alpha: 0.85),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No appointments for this day',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: PatientPortalTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to schedule one.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Text(
                    "Today's appointments",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: PatientPortalTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...appointments.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: const Color(0xFFF8FAFE),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => onTapTile(a),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: AppTheme.primaryColor, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.timeRange,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: PatientPortalTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        a.type,
                                        style: PatientPortalTheme.body(context),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: PatientPortalTheme.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CareGuidanceCard extends StatelessWidget {
  const _CareGuidanceCard({
    required this.onOngoing,
    required this.onHistory,
  });

  final VoidCallback? onOngoing;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined, color: AppTheme.primaryColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your treatment & visits',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: PatientPortalTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Prescriptions and visit notes are available under your active and past consultations. Open the Patient tab to review ongoing care or your history.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.45,
              color: PatientPortalTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOngoing,
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Ongoing'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onHistory,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
