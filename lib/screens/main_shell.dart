import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'appointments_screen.dart';
import 'dashboard_screen.dart';
import 'patient_list_screen.dart';
import 'payment_screen.dart';
import 'prescription_screen.dart';
import 'treatment_screen.dart';

/// Root shell with persistent bottom navigation.
/// All primary screens live inside the IndexedStack for instant switching.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PatientListScreen(),
    AppointmentsScreen(),
    PaymentScreen(),
    _MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          iconSize: 26,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Accounts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

/// "More" grid — one-tap access to every feature.
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(
        icon: Icons.assignment_outlined,
        label: 'Treatment\nPlans',
        color: Colors.indigo,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TreatmentScreen()),
        ),
      ),
      _MoreItem(
        icon: Icons.medication_outlined,
        label: 'Prescriptions',
        color: Colors.teal,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PrescriptionScreen()),
        ),
      ),
      _MoreItem(
        icon: Icons.receipt_long_outlined,
        label: 'Invoices',
        color: Colors.orange.shade700,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PaymentScreen()),
        ),
      ),
      _MoreItem(
        icon: Icons.science_outlined,
        label: 'Lab Work',
        color: Colors.purple,
        onTap: () => _showComingSoon(context, 'Lab Work'),
      ),
      _MoreItem(
        icon: Icons.bar_chart_outlined,
        label: 'Reports',
        color: Colors.blue.shade700,
        onTap: () => _showComingSoon(context, 'Reports'),
      ),
      _MoreItem(
        icon: Icons.inventory_2_outlined,
        label: 'Inventory',
        color: Colors.brown,
        onTap: () => _showComingSoon(context, 'Inventory'),
      ),
      _MoreItem(
        icon: Icons.message_outlined,
        label: 'Messages',
        color: Colors.green.shade700,
        onTap: () => _showComingSoon(context, 'Messages'),
      ),
      _MoreItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        color: Colors.grey.shade700,
        onTap: () => _showComingSoon(context, 'Settings'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          'More',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.3,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  const _MoreItem({
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
