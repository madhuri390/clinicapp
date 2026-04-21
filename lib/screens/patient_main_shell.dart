import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../repositories/patient_repository.dart';
import '../services/auth_service.dart';
import '../services/local_store.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/patient_portal_logo.dart';
import 'patient_home_dashboard_screen.dart';
import 'patient_portal_appointments_screen.dart';
import 'patient_portal_care_screen.dart';
import 'patient_portal_profile_screen.dart';

/// Patient app: Home (dashboard), Patient (profile / ongoing / history), Appointments, Profile.
class PatientMainShell extends StatefulWidget {
  const PatientMainShell({super.key});

  @override
  State<PatientMainShell> createState() => _PatientMainShellState();
}

class _PatientMainShellState extends State<PatientMainShell> {
  int _currentIndex = 0;
  bool _ready = false;

  /// Incremented when Home requests a jump to Ongoing / History on the Patient tab.
  final ValueNotifier<int> _patientCareNavSignal = ValueNotifier<int>(0);
  int _patientCareTargetTab = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _navigateToCareTab(int tabIndex) {
    _patientCareTargetTab = tabIndex.clamp(0, 2);
    _patientCareNavSignal.value = _patientCareNavSignal.value + 1;
    setState(() => _currentIndex = 1);
  }

  @override
  void dispose() {
    _patientCareNavSignal.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    LocalStore.instance.seedIfNeeded();
    final repo = PatientRepository();
    try {
      final uid = AuthService.currentUser?.id;
      if (uid == null) throw Exception('Not logged in');

      final p = await repo.getForAuthUser(uid);
      if (p == null) throw Exception('No patient profile linked to this login');

      final name = p.fullName.isNotEmpty ? p.fullName : p.firstName;
      PatientSession.setPortal(
        patientId: p.id,
        displayName: name,
        patient: p,
      );
      LocalStore.instance.seedOngoingForPatient(p.id);
    } catch (_) {
      PatientSession.clear();
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Material(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: PatientPortalTheme.headerGradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const PatientPortalLogo(height: 88),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preparing your care…',
                    style: PatientPortalTheme.body(context).copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final stackScreens = [
      PatientHomeDashboardScreen(
        onOpenOngoing: () => _navigateToCareTab(1),
        onOpenHistory: () => _navigateToCareTab(2),
      ),
      PatientPortalCareScreen(
        careNavSignal: _patientCareNavSignal,
        careTargetTabResolver: () => _patientCareTargetTab,
      ),
      const PatientPortalAppointmentsScreen(),
      const PatientPortalProfileScreen(),
    ];

    return Theme(
      data: PatientPortalTheme.themeOverlay(context),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final nav = _navigatorKeys[_currentIndex].currentState;
          if (nav != null && nav.canPop()) {
            nav.pop();
          } else if (_currentIndex != 0) {
            setState(() => _currentIndex = 0);
          }
        },
        child: Scaffold(
          backgroundColor: PatientPortalTheme.surface,
          body: IndexedStack(
            index: _currentIndex,
            children: List.generate(stackScreens.length, (i) {
              return Navigator(
                key: _navigatorKeys[i],
                onGenerateRoute: (settings) {
                  return MaterialPageRoute<void>(builder: (_) => stackScreens[i]);
                },
              );
            }),
          ),
          bottomNavigationBar: _PatientBottomNav(
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
      ),
    );
  }
}

class _PatientBottomNav extends StatelessWidget {
  const _PatientBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Patient',
    ),
    (
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Appointments',
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: PatientPortalTheme.navyBlue.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = currentIndex == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: active ? PatientPortalTheme.accentGradient : null,
                        color: active ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active ? item.activeIcon : item.icon,
                            size: 22,
                            color: active ? Colors.white : PatientPortalTheme.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? Colors.white : PatientPortalTheme.textSecondary,
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
