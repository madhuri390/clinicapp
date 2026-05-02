import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/staff_model.dart';
import '../services/auth_service.dart';
import '../services/staff_service.dart';
import '../services/app_role_service.dart';
import '../theme/app_theme.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/visit_detail_repository.dart';
import '../models/appointment_model.dart';
import 'appointments_screen.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'patient_form_screen.dart';
import 'patient_list_screen.dart';
import 'patient_details_screen.dart';
import 'profile_screen.dart';
import '../models/visit_detail_model.dart';

// ── Reference colors (Tailwind) ─────────────────────────────────────────────
const _blue600 = Color(0xFF2563EB);
const _blue100 = Color(0xFFDBEAFE);
const _slate50 = Color(0xFFF8FAFC);
// const _slate100 = Color(0xFFF1F5F9);
const _slate200 = Color(0xFFE2E8F0);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);
// const _orange50 = Color(0xFFFFF7ED);
// const _orange200 = Color(0xFFFED7AA);
const _orange600 = Color(0xFFEA580C);
// const _orange700 = Color(0xFFC2410C);
// const _orange800 = Color(0xFF9A3412);
// const _orange900 = Color(0xFF7C2D12);
// const _green600 = Color(0xFF16A34A);
const _purple600 = Color(0xFF9333EA);
const _purple50 = Color(0xFFF5F3FF);
const _red500 = Color(0xFFEF4444);

/*
/// Mock inventory item for low stock.
class _MockInventoryItem {
  const _MockInventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minStock,
  });
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final int minStock;
}
*/

/*
/// Mock consultation for revenue/ongoing count.
class _MockConsultation {
  const _MockConsultation({required this.status, required this.totalCost});
  final String status;
  final int totalCost;
}
*/

/// Dashboard matching PatientTrackingVersion4/src/app/components/dashboard.tsx
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  final _apptRepo = AppointmentRepository();
  final _visitRepo = VisitDetailRepository();
  int _todayAppointmentsCount = 0;
  List<Appointment> _todayVisits = [];
  List<VisitDetail> _ongoingVisits = [];
  String _welcomeName = 'Doctor';
  String _profileRole = '';

  /*
  final _repo = PatientRepository();
  List<Patient> _patients = [];
  bool _patientsLoading = true;

  static const _patientIncrease = 12;
  static const _revenueIncrease = 18;
  // static const _todayAppointments = 8; // replaced by DB-backed count

  static const _mockConsultations = [
    _MockConsultation(status: 'ongoing', totalCost: 1500),
    _MockConsultation(status: 'completed', totalCost: 150),
    _MockConsultation(status: 'ongoing', totalCost: 1200),
    _MockConsultation(status: 'completed', totalCost: 500),
    _MockConsultation(status: 'ongoing', totalCost: 800),
  ];

  static const _mockInventory = [
    _MockInventoryItem(
      id: '1',
      name: 'Anesthetic (Lidocaine 2%)',
      quantity: 25,
      unit: 'vials',
      minStock: 10,
    ),
    _MockInventoryItem(
      id: '2',
      name: 'Dental Gloves (Medium)',
      quantity: 150,
      unit: 'pairs',
      minStock: 50,
    ),
    _MockInventoryItem(
      id: '3',
      name: 'Amalgam Filling Material',
      quantity: 8,
      unit: 'packs',
      minStock: 5,
    ),
    _MockInventoryItem(
      id: '4',
      name: 'Composite Resin',
      quantity: 3,
      unit: 'syringes',
      minStock: 5,
    ),
    _MockInventoryItem(
      id: '5',
      name: 'Amoxicillin 500mg',
      quantity: 120,
      unit: 'tablets',
      minStock: 50,
    ),
    _MockInventoryItem(
      id: '6',
      name: 'Ibuprofen 400mg',
      quantity: 200,
      unit: 'tablets',
      minStock: 100,
    ),
    _MockInventoryItem(
      id: '7',
      name: 'Face Masks',
      quantity: 80,
      unit: 'pieces',
      minStock: 100,
    ),
    _MockInventoryItem(
      id: '8',
      name: 'Dental Burs (Assorted)',
      quantity: 45,
      unit: 'pieces',
      minStock: 20,
    ),
  ];
  */

  /*
  int get _totalRevenue =>
      _mockConsultations.fold(0, (sum, c) => sum + c.totalCost);

  int get _ongoingCount =>
      _mockConsultations.where((c) => c.status == 'ongoing').length;

  List<_MockInventoryItem> get _lowStockItems =>
      _mockInventory.where((i) => i.quantity <= i.minStock).toList();

  int get _badgeCount => _lowStockItems.isNotEmpty ? _lowStockItems.length : 3;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _patientsLoading = true);
    try {
      final list = await _repo.getAll();
      if (!mounted) return;
      setState(() {
        _patients = list;
        _patientsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _patientsLoading = false);
    }
  }
  */

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  /// Called when the bottom-nav Home tab is selected so data stays fresh
  /// (this screen lives in an [IndexedStack] and does not rebuild on tab switch).
  Future<void> refreshFromServer() => _loadDashboard();

  Future<void> _loadDashboard() async {
    try {
      final uid = AuthService.currentUser?.id;
      final staff = await StaffService.instance.getStaff();
      Staff? me;
      if (uid != null) {
        for (final s in staff) {
          if (s.authUserId == uid) {
            me = s;
            break;
          }
        }
      }
      if (me != null && mounted) {
        final m = me;
        final n = m.name.trim();
        setState(() {
          _welcomeName = n.toLowerCase().startsWith('dr.') ? n : 'Dr. $n';
          _profileRole = m.role;
        });
      }

      final doctorId = await _visitRepo.getDoctorIdForCurrentUser();
      if (doctorId == null) {
        if (mounted) {
          setState(() {
            _todayAppointmentsCount = 0;
            _todayVisits = [];
          });
        }
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final all = await _apptRepo.getForDoctor(doctorId);
      final visits = all.where((a) {
        final d = a.date;
        final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
        final isActive =
            a.status == AppointmentStatus.scheduled || a.status == AppointmentStatus.ongoing;
        return isToday && isActive;
      }).toList()
        ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

      if (!mounted) return;
      
      final ongoingVisits = await _visitRepo.getAllOngoing();
      
      if (!mounted) return;
      setState(() {
        _todayAppointmentsCount = visits.length;
        _todayVisits = visits;
        _ongoingVisits = ongoingVisits;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _todayAppointmentsCount = 0;
          _todayVisits = [];
        });
      }
    }
  }

  Future<void> _onAddPatient() async {
    final shell = MainShell.of(context);
    if (shell != null) {
      shell.setTabIndex(1); // Switch to Patients tab
      await shell.getNavigatorForTab(1)?.push(
            MaterialPageRoute<void>(builder: (_) => const PatientFormScreen()),
          );
      shell.refreshPatientTab();
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PatientFormScreen()),
      );
    }
  }

  /*
  void _onInventoryTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTodaySchedule(),
                      const SizedBox(height: 16),
                      _buildOngoingTreatments(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }



  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      color: AppTheme.primaryColor,
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back, $_welcomeName',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }

  /*
  Widget _buildLowStockAlert() {
    return Material(
      color: _orange50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _onInventoryTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _orange200, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: _orange600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Low Stock Alert!',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _orange900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_lowStockItems.length} inventory item(s) are running low on stock',
                      style: GoogleFonts.inter(fontSize: 14, color: _orange700),
                    ),
                    const SizedBox(height: 8),
                    ..._lowStockItems
                        .take(3)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${item.name}: ${item.quantity} ${item.unit} (Min: ${item.minStock})',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: _orange800,
                              ),
                            ),
                          ),
                        ),
                    if (_lowStockItems.length > 3)
                      Text(
                        '+ ${_lowStockItems.length - 3} more items',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _orange700,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: _orange600, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            iconColor: _blue600,
            value: _patientsLoading ? '...' : '${_patients.length}',
            label: 'Total Patients',
            trend: '$_patientIncrease%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.attach_money,
            iconColor: _green600,
            value: '\$$_totalRevenue',
            label: 'Total Revenue',
            trend: '$_revenueIncrease%',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _go(const AppointmentsScreen()),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _slate200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: _purple600, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '$_todayAppointmentsCount',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _slate900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Today's Appointments",
                      style: GoogleFonts.inter(fontSize: 14, color: _slate600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _go(const PatientListScreen()),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _slate200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bolt, color: _orange600, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '$_ongoingCount',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _slate900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ongoing Treatments',
                      style: GoogleFonts.inter(fontSize: 14, color: _slate600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyRevenue() {
    const months = ['January', 'February', 'March'];
    final amounts = [4200, 5800, _totalRevenue];
    const maxAmount = 6000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Revenue',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _slate900,
                ),
              ),
              GestureDetector(
                onTap: () => _go(const PatientListScreen()),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _blue600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (i) {
            final amount = amounts[i];
            final pct = ((amount / maxAmount) * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        months[i],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _slate600,
                        ),
                      ),
                      Text(
                        '\$$amount',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _slate900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth * (pct / 100);
                      return Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: _slate100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(
                            width: w,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: _blue600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
  */

  Widget _buildTodaySchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: _blue600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Today's schedule",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _slate900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final shell = MainShell.of(context);
                  if (shell != null) {
                    shell.setTabIndex(2);
                  } else {
                    _go(const AppointmentsScreen());
                  }
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _blue600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_todayVisits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No visits scheduled for today.',
                style: GoogleFonts.inter(fontSize: 14, color: _slate500, height: 1.35),
              ),
            )
          else
            ..._todayVisits.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _slate50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: _orange600,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.patientName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _slate900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              a.type,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _slate600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${a.timeRange} · ${a.statusLabel}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _slate500,
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
        ],
      ),
    );
  }

  Widget _buildOngoingTreatments() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: _orange600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Ongoing Treatments",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _slate900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final shell = MainShell.of(context);
                  if (shell != null) {
                    shell.setTabIndex(1);
                  } else {
                    _go(const PatientListScreen());
                  }
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _blue600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_ongoingVisits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No ongoing treatments right now.',
                style: GoogleFonts.inter(fontSize: 14, color: _slate500, height: 1.35),
              ),
            )
          else
            ..._ongoingVisits.take(5).map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: _slate50,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PatientDetailsScreen(
                            patientId: v.visit.patientId,
                            patientName: v.patientName,
                            initialTabIndex: 1, // Ongoing tab
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.local_hospital_outlined,
                            color: _orange600,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.patientName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _slate900,
                                  ),
                                ),
                                if (v.visit.chiefComplaint != null && v.visit.chiefComplaint!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    v.visit.chiefComplaint!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: _slate600,
                                    ),
                                  ),
                                ],
                                if (v.treatments.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Plan: ${v.treatments.first.treatmentName}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: _slate500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _slate900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: _blue100,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _onAddPatient,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, color: _blue600, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Add Patient',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _blue600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: _purple50,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      final shell = MainShell.of(context);
                      if (shell != null) {
                        shell.setTabIndex(2); // Switch to Appointments tab
                      } else {
                        _go(const AppointmentsScreen());
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: _purple600,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'New Appointment ($_todayAppointmentsCount)',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _purple600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

/*
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.trend,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 32),
              Row(
                children: [
                  Icon(Icons.trending_up, color: _green600, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _green600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _slate900,
            ),
          ),
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: _slate600)),
        ],
      ),
    );
  }
}
*/


