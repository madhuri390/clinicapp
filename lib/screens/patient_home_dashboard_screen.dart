import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/add_appointment_sheet.dart';
import '../widgets/patient_portal_shell_header.dart';
import '../widgets/ui_kit.dart';
import '../theme/app_tokens.dart';

/// Patient home: bright gradient canvas, hero banner, quick actions and the
/// day's visits.
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

  String _firstName(String full) {
    final t = full.trim();
    if (t.isEmpty) return 'there';
    return t.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = PatientSession.resolvedPortalDisplayName();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: RefreshIndicator(
          onRefresh: _loadToday,
          color: PatientPortalTheme.brightBlue,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: PatientPortalShellHeader(
                  title: 'Hello,',
                  accentWord: _firstName(displayName),
                  subtitle: 'Here is your care at a glance',
                ),
              ),
              if (_loadError != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      _loadError!,
                      style: PatientPortalTheme.body(context).copyWith(color: AppTokens.danger),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AnimatedEntrance(
                      index: 1,
                      child: _HeroBanner(onBook: _bookToday),
                    ),
                    const SizedBox(height: 22),
                    AnimatedEntrance(
                      index: 2,
                      child: _QuickActions(
                        onBook: _bookToday,
                        onOngoing: widget.onOpenOngoing,
                        onHistory: widget.onOpenHistory,
                      ),
                    ),
                    const SizedBox(height: 22),
                    AnimatedEntrance(
                      index: 3,
                      child: _TodayAppointmentsCard(
                        appointments: _loading ? const [] : _todayList,
                        onTapEmpty: _bookToday,
                        onTapTile: (a) => _showAppointmentDialog(a),
                        loading: _loading,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedEntrance(
                      index: 4,
                      child: _CareGuidanceCard(
                        onOngoing: widget.onOpenOngoing,
                        onHistory: widget.onOpenHistory,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDialog(Appointment a) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroIconBadge(icon: Icons.event_rounded, size: 46),
              const SizedBox(height: 16),
              Text(a.type, style: PatientPortalTheme.titleLarge(context)),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('EEEE, MMM d').format(a.date)} · ${a.timeRange}',
                style: PatientPortalTheme.body(context),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: PatientPortalTheme.titleMedium(context)
                        .copyWith(color: PatientPortalTheme.brightBlue),
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

/// Gradient hero banner echoing the inspiration's headline card.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: PatientPortalTheme.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: PatientPortalTheme.glow(PatientPortalTheme.brightBlue),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take care of your smile',
                  style: PatientPortalTheme.titleLarge(context)
                      .copyWith(color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Book a visit and stay on top of your care.',
                  style: PatientPortalTheme.body(context)
                      .copyWith(color: Colors.white.withValues(alpha: 0.92)),
                ),
                const SizedBox(height: 16),
                _WhiteCta(label: 'Book appointment', onTap: onBook),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.sentiment_very_satisfied_rounded,
                color: Colors.white, size: 38),
          ),
        ],
      ),
    );
  }
}

class _WhiteCta extends StatelessWidget {
  const _WhiteCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: PatientPortalTheme.titleMedium(context)
                    .copyWith(color: PatientPortalTheme.brightBlue),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: PatientPortalTheme.brightBlue),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of hero-icon shortcuts.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onBook,
    required this.onOngoing,
    required this.onHistory,
  });

  final VoidCallback onBook;
  final VoidCallback? onOngoing;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.add_circle_outline_rounded,
            label: 'Book',
            gradient: PatientPortalTheme.buttonGradient,
            glow: PatientPortalTheme.brightSky,
            onTap: onBook,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.medical_services_rounded,
            label: 'Ongoing',
            gradient: const LinearGradient(
              colors: [AppTokens.success, AppTokens.success],
            ),
            glow: AppTokens.success,
            onTap: onOngoing,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.history_rounded,
            label: 'History',
            gradient: const LinearGradient(
              colors: [AppTokens.accent, AppTokens.accent],
            ),
            glow: AppTokens.accent,
            onTap: onHistory,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final Color glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HeroIconBadge(
                icon: icon,
                size: 46,
                gradient: gradient,
                glowColor: glow,
              ),
              const SizedBox(height: 10),
              Text(label, style: PatientPortalTheme.label(context)),
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
      decoration: PatientPortalTheme.glassDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: appointments.isEmpty ? onTapEmpty : null,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (loading) ...[
                  Row(
                    children: [
                      const HeroIconBadge(icon: Icons.schedule_rounded, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          "Loading today's appointments…",
                          style: PatientPortalTheme.titleMedium(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(minHeight: 3),
                ] else if (appointments.isEmpty) ...[
                  Row(
                    children: [
                      const HeroIconBadge(
                        icon: Icons.event_available_rounded,
                        size: 44,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No appointments today',
                              style: PatientPortalTheme.titleMedium(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to schedule one',
                              style: PatientPortalTheme.body(context).copyWith(
                                color: PatientPortalTheme.brightBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: PatientPortalTheme.textSecondary),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Text(
                        "Today's appointments",
                        style: PatientPortalTheme.titleMedium(context),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: PatientPortalTheme.buttonGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${appointments.length}',
                          style: PatientPortalTheme.label(context)
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...appointments.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: PatientPortalTheme.skyTint.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => onTapTile(a),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded,
                                    color: PatientPortalTheme.brightBlue,
                                    size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.timeRange,
                                        style: PatientPortalTheme.titleMedium(
                                                context)
                                            .copyWith(fontSize: 14),
                                      ),
                                      Text(a.type,
                                          style:
                                              PatientPortalTheme.body(context)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: PatientPortalTheme.textSecondary),
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
      decoration: PatientPortalTheme.glassDecoration(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HeroIconBadge(
                icon: Icons.health_and_safety_rounded,
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Your treatment & visits',
                  style: PatientPortalTheme.titleMedium(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Prescriptions and visit notes live under your active and past consultations. Open the Patient tab to review ongoing care or your history.',
            style: PatientPortalTheme.body(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GhostButton(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Ongoing',
                  onTap: onOngoing,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GhostButton(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: onHistory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: PatientPortalTheme.brightBlue.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: PatientPortalTheme.brightBlue),
              const SizedBox(width: 8),
              Text(
                label,
                style: PatientPortalTheme.titleMedium(context)
                    .copyWith(color: PatientPortalTheme.brightBlue, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
