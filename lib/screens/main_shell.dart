import 'package:flutter/material.dart';

import 'appointments_screen.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'messages_screen.dart';
import 'patient_list_screen.dart';

// Reference: PatientTrackingVersion4 bottom-nav.tsx colors
const _blue600 = Color(0xFF2563EB);
const _slate400 = Color(0xFF94A3B8);

/// Root shell with persistent bottom navigation.
/// Matches PatientTrackingVersion4/src/app/components/bottom-nav.tsx
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
    MessagesScreen(),
    InventoryScreen(),
  ];

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = _navigatorKeys[_currentIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
          } else {
            // If on first tab and cannot pop, let the system handle it (exit)
            // This requires making the scaffold poppable or using SystemNavigator
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(_screens.length, (i) {
            return Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (_) => _screens[i]);
              },
            );
          }),
        ),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            if (_currentIndex == i) {
              _navigatorKeys[i].currentState?.popUntil((r) => r.isFirst);
            } else {
              setState(() => _currentIndex = i);
            }
          },
        ),
      ),
    );
  }
}

/// Custom bottom nav matching reference: flex items-center justify-around,
/// icon w-5 h-5 (20px), gap-1, py-2, text-xs font-medium
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Patients'),
    (
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Appointments',
    ),
    (
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Messages',
    ),
    (
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Inventory',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final isActive = currentIndex == i;
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 24,
                      color: isActive ? _blue600 : _slate400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
