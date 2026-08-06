import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/ui_kit.dart';
import 'appointments_screen.dart';
import 'dashboard_screen.dart';
// import 'inventory_screen.dart';
// import 'messages_screen.dart';
import 'patient_list_screen.dart';
import 'profile_screen.dart';
import '../theme/app_tokens.dart';

/// Root shell with persistent bottom navigation.
/// Matches PatientTrackingVersion4/src/app/components/bottom-nav.tsx
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainShellState>();
  }

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final GlobalKey<DashboardScreenState> _dashboardScreenKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<PatientListScreenState> _patientListScreenKey =
      GlobalKey<PatientListScreenState>();
  final GlobalKey<AppointmentsScreenState> _appointmentsScreenKey =
      GlobalKey<AppointmentsScreenState>();

  List<Widget> get _screens => [
    DashboardScreen(key: _dashboardScreenKey),
    PatientListScreen(key: _patientListScreenKey),
    AppointmentsScreen(key: _appointmentsScreenKey),
    const ProfileScreen(),
  ];

  void _refreshDashboardTabIfNeeded(int index) {
    if (index != 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dashboardScreenKey.currentState?.refreshFromServer();
    });
  }

  late final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  void setTabIndex(int index) {
    if (index < 0 || index >= _screens.length) return;
    setState(() => _currentIndex = index);
    _refreshDashboardTabIfNeeded(index);
    if (index == 1) refreshPatientTab();
  }

  void refreshPatientTab() {
    _patientListScreenKey.currentState?.refresh();
  }

  NavigatorState? getNavigatorForTab(int index) {
    if (index < 0 || index >= _navigatorKeys.length) return null;
    return _navigatorKeys[index].currentState;
  }

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
                return FadeSlideRoute<void>(
                  page: _screens[i],
                  settings: settings,
                );
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
              _refreshDashboardTabIfNeeded(i);
              // Do not auto-refresh Appointments on every tab switch.
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
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.people_outline,
      activeIcon: Icons.people_rounded,
      label: 'Patients'
    ),
    (
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Schedule',
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppTokens.s16, 0, AppTokens.s16, 12),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: AppTokens.brXl,
        border: Border.all(color: AppTokens.hairline),
        boxShadow: AppTokens.shadowLg,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = currentIndex == i;
              // A soft tinted pill rather than a saturated fill: at four tabs
              // wide, solid blue blocks fight the content above them.
              final tint = isActive ? AppTokens.accentDark : AppTokens.muted;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: AppTokens.brLg,
                    child: AnimatedContainer(
                      duration: AppTokens.medium,
                      curve: AppTokens.ease,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isActive ? AppTokens.accentSoft : null,
                        borderRadius: AppTokens.brLg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 22,
                            color: tint,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w600,
                              letterSpacing: 0.1,
                              color: tint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
