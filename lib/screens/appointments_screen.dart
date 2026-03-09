import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reference colors
const _blue600 = Color(0xFF2563EB);
const _blue500 = Color(0xFF3B82F6);
const _blue100 = Color(0xFFDBEAFE);
const _slate50 = Color(0xFFF8FAFC);
const _slate100 = Color(0xFFF1F5F9);
const _slate200 = Color(0xFFE2E8F0);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);
const _green100 = Color(0xFFDCFCE7);
const _green700 = Color(0xFF15803D);

class _Appointment {
  const _Appointment({
    required this.id,
    required this.patientName,
    required this.time,
    required this.date,
    required this.type,
    required this.doctor,
    required this.status,
  });
  final String id;
  final String patientName;
  final String time;
  final String date;
  final String type;
  final String doctor;
  final String status; // ongoing, upcoming, completed
}

/// Appointments screen matching PatientTrackingVersion4 appointments.tsx
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAddModal = false;

  static const _mockAppointments = [
    _Appointment(
      id: '1',
      patientName: 'Sarah Johnson',
      time: '10:00 AM',
      date: '2026-03-07',
      type: 'Root Canal - Follow-up',
      doctor: 'Dr. Amanda Foster',
      status: 'ongoing',
    ),
    _Appointment(
      id: '2',
      patientName: 'Michael Chen',
      time: '02:30 PM',
      date: '2026-03-07',
      type: 'Crown Placement',
      doctor: 'Dr. Robert Martinez',
      status: 'upcoming',
    ),
    _Appointment(
      id: '3',
      patientName: 'Emma Williams',
      time: '04:00 PM',
      date: '2026-03-10',
      type: 'Wisdom Tooth Extraction',
      doctor: 'Dr. Sarah Peterson',
      status: 'upcoming',
    ),
    _Appointment(
      id: '4',
      patientName: 'John Davis',
      time: '09:00 AM',
      date: '2026-03-12',
      type: 'Teeth Cleaning',
      doctor: 'Dr. Amanda Foster',
      status: 'upcoming',
    ),
    _Appointment(
      id: '5',
      patientName: 'Lisa Anderson',
      time: '11:30 AM',
      date: '2026-03-05',
      type: 'Dental Checkup',
      doctor: 'Dr. Robert Martinez',
      status: 'completed',
    ),
    _Appointment(
      id: '6',
      patientName: 'Robert Brown',
      time: '03:00 PM',
      date: '2026-03-04',
      type: 'Cavity Filling',
      doctor: 'Dr. Amanda Foster',
      status: 'completed',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ongoing = _mockAppointments.where((a) => a.status == 'ongoing').toList();
    final upcoming = _mockAppointments.where((a) => a.status == 'upcoming').toList();
    final completed = _mockAppointments.where((a) => a.status == 'completed').toList();

    return Scaffold(
      backgroundColor: _slate50,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: _blue600,
                expandedHeight: 0,
                toolbarHeight: kToolbarHeight + 56,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: _blue600,
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appointments',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${_mockAppointments.length} total appointments',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: _blue100,
                                  ),
                                ),
                              ],
                            ),
                            Material(
                              color: _blue500,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => setState(() => _showAddModal = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Add',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: _blue600,
                    unselectedLabelColor: _slate600,
                    indicatorColor: _blue600,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'Ongoing (${ongoing.length})'),
                      Tab(text: 'Upcoming (${upcoming.length})'),
                      Tab(text: 'Completed (${completed.length})'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(appointments: ongoing, type: 'ongoing'),
                _AppointmentList(appointments: upcoming, type: 'upcoming'),
                _AppointmentList(appointments: completed, type: 'completed'),
              ],
            ),
          ),
          if (_showAddModal)
            _AddAppointmentModal(
              onClose: () => setState(() => _showAddModal = false),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => setState(() => _showAddModal = true),
          backgroundColor: _blue600,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class _AppointmentList extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
    required this.type,
  });

  final List<_Appointment> appointments;
  final String type;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      final messages = {
        'ongoing': 'No ongoing appointments',
        'upcoming': 'No upcoming appointments',
        'completed': 'No completed appointments',
      };
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _slate50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.bolt, size: 48, color: _slate400),
              const SizedBox(height: 12),
              Text(
                messages[type]!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _slate500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, i) {
        final a = appointments[i];
        return _AppointmentCard(appointment: a, type: type);
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.type,
  });

  final _Appointment appointment;
  final String type;

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        final d = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        return '${d.month}/${d.day}/${d.year}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _slate200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(type: type),
                    const SizedBox(height: 8),
                    Text(
                      appointment.patientName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _slate900,
                      ),
                    ),
                    Text(
                      appointment.type,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: _slate400),
              const SizedBox(width: 8),
              Text(
                _formatDate(appointment.date),
                style: GoogleFonts.inter(fontSize: 14, color: _slate600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: _slate400),
              const SizedBox(width: 8),
              Text(
                appointment.time,
                style: GoogleFonts.inter(fontSize: 14, color: _slate600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: _slate400),
              const SizedBox(width: 8),
              Text(
                appointment.doctor,
                style: GoogleFonts.inter(fontSize: 14, color: _slate600),
              ),
            ],
          ),
          if (type != 'completed') ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: _slate50,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reschedule'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          'Reschedule',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _slate700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Material(
                    color: _blue600,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              type == 'ongoing' ? 'View Details' : 'Start',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          type == 'ongoing' ? 'View Details' : 'Start',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;
    switch (type) {
      case 'ongoing':
        bg = _green100;
        fg = _green700;
        icon = Icons.bolt;
        label = 'Ongoing';
        break;
      case 'upcoming':
        bg = _blue100;
        fg = _blue600;
        icon = Icons.info_outline;
        label = 'Upcoming';
        break;
      case 'completed':
        bg = _slate100;
        fg = _slate700;
        icon = Icons.check_circle_outline;
        label = 'Completed';
        break;
      default:
        bg = _slate100;
        fg = _slate700;
        icon = Icons.circle;
        label = type;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAppointmentModal extends StatelessWidget {
  const _AddAppointmentModal({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Schedule Appointment',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _slate900,
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: Icon(Icons.close, color: _slate400),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Add appointment form coming soon',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _slate600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Appointment scheduled!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              onClose();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Schedule Appointment'),
                          ),
                        ),
                      ],
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
