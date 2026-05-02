import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/visit_detail_repository.dart';
import '../services/auth_service.dart';
import '../services/staff_service.dart';

import 'main_shell.dart';
import '../widgets/add_appointment_sheet.dart';
import '../widgets/cancel_appointment_sheet.dart';
import '../widgets/reschedule_sheet.dart';

// ── Reference colors ────────────────────────────────────────────────────────
const _blue600 = Color(0xFF0D8DC4);
const _blue500 = Color(0xFF28A0D4);
const _blue100 = Color(0xFFB4E0F0);
const _blue50 = Color(0xFFEAF5FB);
const _slate50 = Color(0xFFF8FAFC);
const _slate100 = Color(0xFFF1F5F9);
const _slate200 = Color(0xFFE2E8F0);
const _slate300 = Color(0xFFCBD5E1);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate900 = Color(0xFF0F172A);
const _green100 = Color(0xFFDCFCE7);
const _green600 = Color(0xFF16A34A);
const _red100 = Color(0xFFFEE2E2);
const _red500 = Color(0xFFEF4444);
const _orange100 = Color(0xFFFFEDD5);
const _orange700 = Color(0xFFC2410C);

/// All available 30-min time slots (9 AM → 7 PM).
const _allTimeSlots = [
  '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
  '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  '18:00', '18:30',
];

bool _calendarDayIsPast(DateTime day) {
  final now = DateTime.now();
  final t = DateTime(now.year, now.month, now.day);
  final d = DateTime(day.year, day.month, day.day);
  return d.isBefore(t);
}

bool _slotStartIsPastForDay(DateTime day, String slot) {
  final parts = slot.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  final start = DateTime(day.year, day.month, day.day, h, m);
  return start.isBefore(DateTime.now());
}

/// Appointments screen with horizontal date scroller and time-block grid.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  late ScrollController _dateScrollController;
  final _repo = AppointmentRepository();
  final _visitRepo = VisitDetailRepository();
  final _staffService = StaffService.instance;
  String? _doctorId;
  String? _doctorName;
  bool _loading = true;
  String? _loadError;
  List<Appointment> _appointments = [];

  /// 14-day window: 7 before today through 6 after.
  late List<DateTime> _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDate = DateTime.now();
    _dateScrollController = ScrollController();
    _buildDateRange();
    _bootstrap();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  Future<void> _bootstrap() async {
    if (mounted) setState(() { _loading = true; _loadError = null; });

    // 1. Resolve doctor ID (critical – stop if not available).
    try {
      _doctorId = await _visitRepo.getDoctorIdForCurrentUser();
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _loadError = 'Could not load doctor profile: $e'; });
      return;
    }

    if (_doctorId == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    // 2. Resolve doctor display name (best-effort, never blocks appointments).
    try {
      final uid = AuthService.currentUser?.id;
      if (uid != null) {
        final staff = await _staffService.getStaff();
        final me = staff.where((s) => s.authUserId == uid).toList();
        _doctorName = me.isNotEmpty ? 'Dr. ${me.first.name}' : null;
      }
    } catch (_) {
      // Name resolution failure must not prevent appointments from loading.
    }

    // 3. Load appointments.
    try {
      _appointments = await _repo.getForDoctor(_doctorId!);
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _loadError = 'Failed to load appointments: $e'; });
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _buildDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dateRange = List.generate(
      14,
      (i) => today.subtract(Duration(days: 7 - i)),
    );
  }

  void _scrollToSelectedDate() {
    final idx = _dateRange.indexWhere(
      (d) =>
          d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day,
    );
    if (idx >= 0 && _dateScrollController.hasClients) {
      final offset = (idx * 72.0) - (MediaQuery.of(context).size.width / 2 - 36);
      _dateScrollController.animateTo(
        offset.clamp(0, _dateScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Appointment> get _dayAppointments {
    final d = _selectedDate;
    return _appointments.where((a) =>
        a.date.year == d.year &&
        a.date.month == d.month &&
        a.date.day == d.day).toList()
      ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateScrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async => _bootstrap();

  /// Called when the bottom-nav Appointments tab is selected so data stays in sync
  /// (this screen lives in an [IndexedStack] and does not rebuild on tab switch).
  Future<void> refreshFromServer() => _bootstrap();

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    _scrollToSelectedDate();
  }

  void _goToToday() {
    final now = DateTime.now();
    _onDateSelected(DateTime(now.year, now.month, now.day));
  }

  void _showAddAppointment() {
    final did = _doctorId;
    if (did == null) return;
    if (_calendarDayIsPast(_selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bookings are only for today or future dates.'),
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
        selectedDate: _selectedDate,
        onSaved: _refresh,
        prefilledDoctorId: did,
        prefilledDoctorName: _doctorName ?? 'Doctor',
      ),
    );
  }

  void _showReschedule(Appointment appt) {
    if (appt.isCancelRescheduleLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reschedule is only available until 1 hour before the visit.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RescheduleSheet(
        appointment: appt,
        onSaved: () => _refresh(),
      ),
    );
  }

  void _showCancel(Appointment appt) {
    if (appt.isCancelRescheduleLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cancellation is only available until 1 hour before the visit.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelAppointmentSheet(
        appointment: appt,
        onSaved: () => _refresh(),
      ),
    );
  }

  void _startAppointment(Appointment appt) {
    _repo.markOngoing(appt.id).then((_) => _refresh());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${appt.patientName}\'s appointment started'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completeAppointment(Appointment appt) {
    _repo.markCompleted(appt.id).then((_) => _refresh());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${appt.patientName}\'s appointment completed'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show a recoverable error screen with a retry button.
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: _slate50,
        appBar: AppBar(
          title: Text('Schedule', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: _blue600,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_outlined, size: 64, color: _slate300),
                const SizedBox(height: 16),
                Text(
                  'Could not load appointments',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: _slate900),
                ),
                const SizedBox(height: 8),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: _slate500, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_doctorId == null) {
      return Scaffold(
        backgroundColor: _slate50,
        appBar: AppBar(
          title: Text('Schedule', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          backgroundColor: _blue600,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_information_outlined, size: 64, color: _slate300),
                const SizedBox(height: 16),
                Text(
                  'No doctor profile linked',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: _slate900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account needs a linked doctor record to load and manage appointments. Contact an administrator if this is unexpected.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: _slate500, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final all = _dayAppointments;
    final upcoming = all.where((a) => a.status == AppointmentStatus.scheduled).toList();
    final completed = all.where((a) => a.status == AppointmentStatus.completed).toList();
    final cancelled = all.where((a) =>
        a.status == AppointmentStatus.cancelled ||
        a.status == AppointmentStatus.rescheduled).toList();

    return Scaffold(
      backgroundColor: _slate50,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildAppBar(),
          _buildDateScroller(),
          _buildTabBar(all, upcoming, completed, cancelled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TimeBlockView(
              selectedDate: _selectedDate,
              appointments: all.where((a) => a.status != AppointmentStatus.rescheduled).toList(),
              onReschedule: _showReschedule,
              onCancel: _showCancel,
              onStart: _startAppointment,
              onComplete: _completeAppointment,
              onRefresh: _refresh,
              onAddAtSlot: (slot) {
                if (_calendarDayIsPast(_selectedDate) || _slotStartIsPastForDay(_selectedDate, slot)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can only book future time slots.'),
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
                    selectedDate: _selectedDate,
                    prefilledTimeSlot: slot,
                    onSaved: _refresh,
                  ),
                );
              },
            ),
            _AppointmentListView(
              appointments: upcoming,
              emptyMessage: 'No upcoming appointments',
              emptyIcon: Icons.event_available,
              onReschedule: _showReschedule,
              onCancel: _showCancel,
              onStart: _startAppointment,
              onComplete: _completeAppointment,
              onRefresh: _refresh,
            ),
            _AppointmentListView(
              appointments: completed,
              emptyMessage: 'No completed appointments',
              emptyIcon: Icons.check_circle_outline,
              onReschedule: _showReschedule,
              onCancel: _showCancel,
              onStart: _startAppointment,
              onComplete: _completeAppointment,
              onRefresh: _refresh,
            ),
            _AppointmentListView(
              appointments: cancelled,
              emptyMessage: 'No cancelled appointments',
              emptyIcon: Icons.cancel_outlined,
              onReschedule: _showReschedule,
              onCancel: _showCancel,
              onStart: _startAppointment,
              onComplete: _completeAppointment,
              onRefresh: _refresh,
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: _calendarDayIsPast(_selectedDate) ? null : _showAddAppointment,
          backgroundColor: _blue600,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _blue600,
      expandedHeight: 0,
      toolbarHeight: kToolbarHeight + 8,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: _blue600,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top,
            left: 16, right: 16, bottom: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            MainShell.of(context)?.setTabIndex(0);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule',
                            style: GoogleFonts.inter(
                              fontSize: 20, fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                            style: GoogleFonts.inter(
                              fontSize: 13, color: _blue100,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _HeaderButton(
                        label: 'Today',
                        icon: Icons.today,
                        onTap: _goToToday,
                      ),
                      const SizedBox(width: 8),
                      _HeaderButton(
                        label: 'Add',
                        icon: Icons.add,
                        onTap: _showAddAppointment,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader _buildDateScroller() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _DateScrollerDelegate(
        dates: _dateRange,
        selectedDate: _selectedDate,
        onDateSelected: _onDateSelected,
        scrollController: _dateScrollController,
        appointmentCounts: {
          for (final d in _dateRange)
            d: _appointments
                .where((a) =>
                    a.date.year == d.year &&
                    a.date.month == d.month &&
                    a.date.day == d.day &&
                    a.status != AppointmentStatus.cancelled &&
                    a.status != AppointmentStatus.rescheduled)
                .length,
        },
      ),
    );
  }

  SliverPersistentHeader _buildTabBar(
    List<Appointment> all,
    List<Appointment> upcoming,
    List<Appointment> completed,
    List<Appointment> cancelled,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: _blue600,
          unselectedLabelColor: _slate600,
          indicatorColor: _blue600,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: 'All (${all.where((a) => a.status != AppointmentStatus.rescheduled).length})'),
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'Done (${completed.length})'),
            Tab(text: 'Cancelled (${cancelled.length})'),
          ],
        ),
      ),
    );
  }
}

// ─── Header button ──────────────────────────────────────────────────────────

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _blue600, // Use primary brand color
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date scroller delegate ─────────────────────────────────────────────────

class _DateScrollerDelegate extends SliverPersistentHeaderDelegate {
  _DateScrollerDelegate({
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
    required this.scrollController,
    required this.appointmentCounts,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ScrollController scrollController;
  final Map<DateTime, int> appointmentCounts;

  @override
  double get minExtent => 88;
  @override
  double get maxExtent => 88;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final date = dates[i];
                final isSelected = date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final count = appointmentCounts[date] ?? 0;

                return GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? _blue600 : (isToday ? _blue50 : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _blue600 : (isToday ? _blue500 : _slate200),
                        width: isToday && !isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date).substring(0, 3),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white70 : _slate500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : _slate900,
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : _blue500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: _slate200),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DateScrollerDelegate oldDelegate) => true;
}

// ─── Tab bar delegate ───────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ─── Time block view (All tab) ──────────────────────────────────────────────

class _TimeBlockView extends StatelessWidget {
  const _TimeBlockView({
    required this.selectedDate,
    required this.appointments,
    required this.onReschedule,
    required this.onCancel,
    required this.onStart,
    required this.onComplete,
    required this.onAddAtSlot,
    required this.onRefresh,
  });

  final DateTime selectedDate;
  final List<Appointment> appointments;
  final void Function(Appointment) onReschedule;
  final void Function(Appointment) onCancel;
  final void Function(Appointment) onStart;
  final void Function(Appointment) onComplete;
  final void Function(String slot) onAddAtSlot;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      final past = _calendarDayIsPast(selectedDate);
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 56, color: _slate300),
                      const SizedBox(height: 12),
                      Text(
                        'No appointments for this day',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 15, color: _slate500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        past
                            ? 'Past days are read-only. Choose today or a future date to add visits.'
                            : 'Tap + to schedule one, or tap an empty time row.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: _slate400, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _blue600,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
        itemCount: _allTimeSlots.length,
        itemBuilder: (context, i) {
          final slot = _allTimeSlots[i];
          final apptAtSlot = appointments.where((a) => a.timeSlot == slot).toList();
          final dayPast = _calendarDayIsPast(selectedDate);
          final slotPast = _slotStartIsPastForDay(selectedDate, slot);
          final cannotAdd = dayPast || slotPast;

          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _slate100)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time label
                  SizedBox(
                    width: 64,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: Text(
                        Appointment.to12Hour(slot),
                        style: GoogleFonts.inter(fontSize: 12, color: _slate400, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  // Vertical divider
                  Container(width: 1, color: _slate200),
                  // Appointment or empty slot
                  Expanded(
                    child: apptAtSlot.isNotEmpty
                        ? Column(
                            children: apptAtSlot
                                .map((a) => _AppointmentCard(
                                      appointment: a,
                                      onReschedule: onReschedule,
                                      onCancel: onCancel,
                                      onStart: onStart,
                                      onComplete: onComplete,
                                    ))
                                .toList(),
                          )
                        : _EmptySlot(onTap: cannotAdd ? null : () => onAddAtSlot(slot)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Empty slot ─────────────────────────────────────────────────────────────

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 48,
      alignment: Alignment.center,
      child: Icon(Icons.add, size: 18, color: onTap != null ? _slate300 : _slate200),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

// ─── Appointment card ───────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onReschedule,
    required this.onCancel,
    required this.onStart,
    required this.onComplete,
  });

  final Appointment appointment;
  final void Function(Appointment) onReschedule;
  final void Function(Appointment) onCancel;
  final void Function(Appointment) onStart;
  final void Function(Appointment) onComplete;

  Color get _statusColor {
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        return _blue600;
      case AppointmentStatus.ongoing:
        return _green600;
      case AppointmentStatus.completed:
        return _slate500;
      case AppointmentStatus.cancelled:
        return _red500;
      case AppointmentStatus.rescheduled:
        return _orange700;
    }
  }

  Color get _statusBg {
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        return _blue100;
      case AppointmentStatus.ongoing:
        return _green100;
      case AppointmentStatus.completed:
        return _slate100;
      case AppointmentStatus.cancelled:
        return _red100;
      case AppointmentStatus.rescheduled:
        return _orange100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final lockCancelReschedule = a.isCancelRescheduleLocked;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge + time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  a.statusLabel,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor),
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 13, color: _slate400),
              const SizedBox(width: 4),
              Text(
                a.timeRange,
                style: GoogleFonts.inter(fontSize: 12, color: _slate500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Patient + type
          Text(
            a.patientName,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _slate900),
          ),
          const SizedBox(height: 2),
          Text(
            a.type,
            style: GoogleFonts.inter(fontSize: 13, color: _slate600),
          ),
          // Doctor message
          if (a.doctorMessage != null && a.doctorMessage!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _slate50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _slate200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.message, size: 14, color: _slate400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Dr: ${a.doctorMessage}',
                      style: GoogleFonts.inter(fontSize: 12, color: _slate600, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Treatment plan indicator
          if (a.treatmentPlanId != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.link, size: 13, color: _blue500),
                const SizedBox(width: 4),
                Text(
                  'Linked to treatment plan',
                  style: GoogleFonts.inter(fontSize: 11, color: _blue500),
                ),
              ],
            ),
          ],
          // Action buttons
          if (a.status == AppointmentStatus.scheduled || a.status == AppointmentStatus.ongoing) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (a.status == AppointmentStatus.scheduled) ...[
                  Expanded(
                    child: _ActionButton(
                      label: 'Start',
                      color: _green600,
                      icon: Icons.play_arrow,
                      onTap: () => onStart(a),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (a.status == AppointmentStatus.ongoing)
                  Expanded(
                    child: _ActionButton(
                      label: 'Complete',
                      color: _green600,
                      icon: Icons.check,
                      onTap: () => onComplete(a),
                    ),
                  ),
                if (a.status == AppointmentStatus.ongoing)
                  const SizedBox(width: 8),
                if (lockCancelReschedule)
                  Expanded(
                    child: Tooltip(
                      message: 'Available until 1 hour before the visit',
                      child: _ActionButton(
                        label: 'Reschedule',
                        color: _slate600,
                        icon: Icons.schedule,
                        onTap: () => onReschedule(a),
                        outlined: true,
                        enabled: false,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _ActionButton(
                      label: 'Reschedule',
                      color: _slate600,
                      icon: Icons.schedule,
                      onTap: () => onReschedule(a),
                      outlined: true,
                    ),
                  ),
                const SizedBox(width: 8),
                if (lockCancelReschedule)
                  Expanded(
                    child: Tooltip(
                      message: 'Available until 1 hour before the visit',
                      child: _ActionButton(
                        label: 'Cancel',
                        color: _red500,
                        icon: Icons.close,
                        onTap: () => onCancel(a),
                        outlined: true,
                        enabled: false,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: _ActionButton(
                      label: 'Cancel',
                      color: _red500,
                      icon: Icons.close,
                      onTap: () => onCancel(a),
                      outlined: true,
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

// ─── Action button ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.outlined = false,
    this.enabled = true,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: outlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 30,
            alignment: Alignment.center,
            decoration: outlined
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Icon(icon, size: 14, color: outlined ? color : Colors.white),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: outlined ? color : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Appointment list view (for Upcoming/Completed/Cancelled tabs) ──────────

class _AppointmentListView extends StatelessWidget {
  const _AppointmentListView({
    required this.appointments,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.onReschedule,
    required this.onCancel,
    required this.onStart,
    required this.onComplete,
    required this.onRefresh,
  });

  final List<Appointment> appointments;
  final String emptyMessage;
  final IconData emptyIcon;
  final void Function(Appointment) onReschedule;
  final void Function(Appointment) onCancel;
  final void Function(Appointment) onStart;
  final void Function(Appointment) onComplete;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(emptyIcon, size: 56, color: _slate300),
                      const SizedBox(height: 12),
                      Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 15, color: _slate500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try another tab or pick a different day in the calendar.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: _slate400, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: _blue600,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 120),
        itemCount: appointments.length,
        itemBuilder: (_, i) => _AppointmentCard(
          appointment: appointments[i],
          onReschedule: onReschedule,
          onCancel: onCancel,
          onStart: onStart,
          onComplete: onComplete,
        ),
      ),
    );
  }
}
