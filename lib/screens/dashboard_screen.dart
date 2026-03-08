import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'add_visit_screen.dart';
import 'patient_form_screen.dart';
import 'patient_list_screen.dart';
import 'prescription_screen.dart';

/// Mock appointment model.
class _TodayAppt {
  const _TodayAppt({
    required this.name,
    required this.time,
    required this.treatment,
    required this.status,
  });

  final String name;
  final String time;
  final String treatment;

  /// 0 = upcoming, 1 = in-progress, 2 = done
  final int status;
}

/// Mock recent patient model.
class _RecentPatient {
  const _RecentPatient({
    required this.name,
    required this.lastVisit,
    required this.initials,
  });

  final String name;
  final String lastVisit;
  final String initials;
}

/// Main dashboard home — greeting, today's schedule, quick actions, stats, recent.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── Mock data ──────────────────────────────────────────────────────────────
  static const _doctorName = 'Dr. Priya';
  static const _clinicName = 'Prodontics Clinic';
  static const _totalPatients = 1247;
  static const _todayVisits = 18;
  static const _pendingPayments = 5;
  static const _upcomingAppts = 12;

  static const _appointments = [
    _TodayAppt(
      name: 'Rahul Sharma',
      time: '09:00',
      treatment: 'Root Canal',
      status: 2,
    ),
    _TodayAppt(
      name: 'Priya Nair',
      time: '10:15',
      treatment: 'Cleaning',
      status: 1,
    ),
    _TodayAppt(
      name: 'Anil Kumar',
      time: '11:00',
      treatment: 'Crown Fitting',
      status: 0,
    ),
    _TodayAppt(
      name: 'Meena Rao',
      time: '12:30',
      treatment: 'Consultation',
      status: 0,
    ),
    _TodayAppt(
      name: 'Sam Thomas',
      time: '14:00',
      treatment: 'Extraction',
      status: 0,
    ),
  ];

  static const _recentPatients = [
    _RecentPatient(name: 'Sarah Mitchell', lastVisit: 'Feb 28', initials: 'SM'),
    _RecentPatient(name: 'James Chen', lastVisit: 'Feb 25', initials: 'JC'),
    _RecentPatient(name: 'Emma Rodriguez', lastVisit: 'Feb 20', initials: 'ER'),
  ];

  String get _greeting {
    final h = TimeOfDay.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _todayLabel {
    final d = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────
  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _onAddPatient() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const PatientFormScreen()),
    );
    if (added == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Patient added'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  "Today's Appointments",
                  '$_todayVisits today',
                  () => _go(const PatientListScreen()),
                ),
                const SizedBox(height: 12),
                _buildAppointmentsList(),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Recent Patients',
                  'View all',
                  () => _go(const PatientListScreen()),
                ),
                const SizedBox(height: 12),
                _buildRecentPatients(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3142C5), Color(0xFF4F63D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _clinicName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  _HeaderIcon(icon: Icons.notifications_outlined, onTap: () {}),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      'P',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // Text(
          //   '$_greeting,',
          //   style: GoogleFonts.poppins(
          //     fontSize: 15,
          //     color: Colors.white70,
          //   ),
          // ),
          // Text(
          //   _doctorName,
          //   style: GoogleFonts.poppins(
          //     fontSize: 24,
          //     fontWeight: FontWeight.w700,
          //     color: Colors.white,
          //   ),
          // ),
          // const SizedBox(height: 4),
          // Text(
          //   _todayLabel,
          //   style: GoogleFonts.poppins(
          //     fontSize: 13,
          //     color: Colors.white60,
          //   ),
          // ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatChip(
          value: '$_totalPatients',
          label: 'Patients',
          icon: Icons.people_outline,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 10),
        _StatChip(
          value: '$_todayVisits',
          label: 'Today',
          icon: Icons.today_outlined,
          color: Colors.teal,
        ),
        const SizedBox(width: 10),
        _StatChip(
          value: '$_pendingPayments',
          label: 'Pending',
          icon: Icons.payment_outlined,
          color: Colors.orange.shade700,
        ),
        const SizedBox(width: 10),
        _StatChip(
          value: '$_upcomingAppts',
          label: 'Upcoming',
          icon: Icons.event_available_outlined,
          color: Colors.indigo,
        ),
      ],
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickAction(
              icon: Icons.person_add_outlined,
              label: 'Add\nPatient',
              color: AppTheme.primaryColor,
              onTap: _onAddPatient,
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.calendar_today_outlined,
              label: 'New\nAppointment',
              color: Colors.teal,
              onTap: () {},
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.medication_outlined,
              label: 'Prescription',
              color: Colors.indigo,
              onTap: () => _go(const PrescriptionScreen()),
            ),
            const SizedBox(width: 10),
            _QuickAction(
              icon: Icons.payments_outlined,
              label: 'Collect\nPayment',
              color: Colors.orange.shade700,
              onTap: () => _go(const AddVisitScreen()),
            ),
          ],
        ),
      ],
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    String action,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Appointments list ──────────────────────────────────────────────────────
  Widget _buildAppointmentsList() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _appointments.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _AppointmentCard(appt: _appointments[i]),
      ),
    );
  }

  // ── Recent patients ────────────────────────────────────────────────────────
  Widget _buildRecentPatients() {
    return Column(
      children: _recentPatients
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecentPatientTile(patient: p),
            ),
          )
          .toList(),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appt});

  final _TodayAppt appt;

  static const _statusColors = [
    Color(0xFF3142C5), // upcoming
    Colors.teal, // in-progress
    Colors.grey, // done
  ];
  static const _statusLabels = ['Upcoming', 'In Progress', 'Done'];

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[appt.status];
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appt.time,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            appt.name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            appt.treatment,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _statusLabels[appt.status],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPatientTile extends StatelessWidget {
  const _RecentPatientTile({required this.patient});

  final _RecentPatient patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            child: Text(
              patient.initials,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Last visit: ${patient.lastVisit}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
