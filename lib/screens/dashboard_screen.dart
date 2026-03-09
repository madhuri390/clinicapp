import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'appointments_screen.dart';
import 'patient_list_screen.dart';
import 'profile_screen.dart';

// ── Reference colors (Tailwind) ─────────────────────────────────────────────
const _blue600 = Color(0xFF2563EB);
const _blue500 = Color(0xFF3B82F6);
const _blue400 = Color(0xFF60A5FA);
const _blue100 = Color(0xFFDBEAFE);
const _slate50 = Color(0xFFF8FAFC);
const _slate100 = Color(0xFFF1F5F9);
const _slate200 = Color(0xFFE2E8F0);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);
const _orange50 = Color(0xFFFFF7ED);
const _orange200 = Color(0xFFFED7AA);
const _orange600 = Color(0xFFEA580C);
const _orange700 = Color(0xFFC2410C);
const _orange800 = Color(0xFF9A3412);
const _orange900 = Color(0xFF7C2D12);
const _green600 = Color(0xFF16A34A);
const _purple600 = Color(0xFF9333EA);
const _purple50 = Color(0xFFF5F3FF);
const _red500 = Color(0xFFEF4444);

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

/// Mock reminder.
class _MockReminder {
  const _MockReminder({
    required this.id,
    required this.patient,
    required this.message,
    required this.date,
  });
  final int id;
  final String patient;
  final String message;
  final String date;
}

/// Mock consultation for revenue/ongoing count.
class _MockConsultation {
  const _MockConsultation({
    required this.status,
    required this.totalCost,
  });
  final String status;
  final int totalCost;
}

/// Dashboard matching PatientTrackingVersion4/src/app/components/dashboard.tsx
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showProfileMenu = false;

  // Mock data matching reference
  static const _mockPatientCount = 3;
  static const _patientIncrease = 12;
  static const _revenueIncrease = 18;
  static const _todayAppointments = 8;

  static const _mockConsultations = [
    _MockConsultation(status: 'ongoing', totalCost: 1500),
    _MockConsultation(status: 'completed', totalCost: 150),
    _MockConsultation(status: 'ongoing', totalCost: 1200),
    _MockConsultation(status: 'completed', totalCost: 500),
    _MockConsultation(status: 'ongoing', totalCost: 800),
  ];

  static const _mockInventory = [
    _MockInventoryItem(id: '1', name: 'Anesthetic (Lidocaine 2%)', quantity: 25, unit: 'vials', minStock: 10),
    _MockInventoryItem(id: '2', name: 'Dental Gloves (Medium)', quantity: 150, unit: 'pairs', minStock: 50),
    _MockInventoryItem(id: '3', name: 'Amalgam Filling Material', quantity: 8, unit: 'packs', minStock: 5),
    _MockInventoryItem(id: '4', name: 'Composite Resin', quantity: 3, unit: 'syringes', minStock: 5),
    _MockInventoryItem(id: '5', name: 'Amoxicillin 500mg', quantity: 120, unit: 'tablets', minStock: 50),
    _MockInventoryItem(id: '6', name: 'Ibuprofen 400mg', quantity: 200, unit: 'tablets', minStock: 100),
    _MockInventoryItem(id: '7', name: 'Face Masks', quantity: 80, unit: 'pieces', minStock: 100),
    _MockInventoryItem(id: '8', name: 'Dental Burs (Assorted)', quantity: 45, unit: 'pieces', minStock: 20),
  ];

  static const _upcomingReminders = [
    _MockReminder(id: 1, patient: 'Sarah Johnson', message: 'Root canal follow-up appointment', date: '2026-03-19'),
    _MockReminder(id: 2, patient: 'Michael Chen', message: 'Crown placement scheduled', date: '2026-03-15'),
    _MockReminder(id: 3, patient: 'Emma Williams', message: 'Wisdom tooth extraction surgery', date: '2026-03-20'),
  ];

  int get _totalRevenue =>
      _mockConsultations.fold(0, (sum, c) => sum + c.totalCost);

  int get _ongoingCount =>
      _mockConsultations.where((c) => c.status == 'ongoing').length;

  List<_MockInventoryItem> get _lowStockItems =>
      _mockInventory.where((i) => i.quantity <= i.minStock).toList();

  int get _badgeCount => _lowStockItems.isNotEmpty ? _lowStockItems.length : 3;

  void _go(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _onAddPatient() {
    // Reference navigates to /patients
    _go(const PatientListScreen());
  }

  void _onInventoryTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
                      if (_lowStockItems.isNotEmpty) ...[
                        _buildLowStockAlert(),
                        const SizedBox(height: 16),
                      ],
                      _buildStatsCards(),
                      const SizedBox(height: 16),
                      _buildQuickStats(),
                      const SizedBox(height: 16),
                      _buildMonthlyRevenue(),
                      const SizedBox(height: 16),
                      _buildUpcomingReminders(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showProfileMenu) _buildProfileOverlay(context),
          if (_showProfileMenu) _buildProfileDropdown(context),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 80,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 224,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _slate200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Amanda Foster',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _slate900,
                      ),
                    ),
                    Text(
                      'Dental Surgeon',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _slate500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.person,
                label: 'My Profile',
                onTap: () {
                  setState(() => _showProfileMenu = false);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () {
                  setState(() => _showProfileMenu = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                isDestructive: true,
                onTap: () {
                  setState(() => _showProfileMenu = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      color: _blue600,
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
                  'Welcome back, Dr. Foster',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _blue100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: _red500,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$_badgeCount',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _showProfileMenu = !_showProfileMenu),
            child: Container(
              padding: const EdgeInsets.only(left: 4, right: 12, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: _blue500,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _blue400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return Material(
      color: _orange50,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: _onInventoryTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _orange200, width: 2),
            borderRadius: BorderRadius.circular(8),
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
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _orange700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._lowStockItems.take(3).map(
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
            value: '$_mockPatientCount',
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
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _go(const AppointmentsScreen()),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _slate200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: _purple600, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          '$_todayAppointments',
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
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _slate600,
                      ),
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
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _go(const PatientListScreen()),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: _slate200),
                  borderRadius: BorderRadius.circular(8),
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
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _slate600,
                      ),
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
        borderRadius: BorderRadius.circular(8),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View All'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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

  Widget _buildUpcomingReminders() {
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
                  Icon(Icons.chat_bubble_outline, color: _blue600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Reminders',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View All'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
          ..._upcomingReminders.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _slate50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notifications_outlined, color: _orange600, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.patient,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _slate900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.message,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _slate600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(r.date),
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

  Widget _buildQuickActions() {
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
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _onAddPatient,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _go(const AppointmentsScreen()),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: _purple600, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'New Appointment',
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

  Widget _buildProfileOverlay(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () => setState(() => _showProfileMenu = false),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(8),
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
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _slate600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFDC2626) : _slate700;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

