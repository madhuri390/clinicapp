import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/login_form_section.dart';
import '../services/app_role_service.dart';
import '../widgets/patient_portal_logo.dart';
import '../widgets/role_aware_shell.dart';
import '../widgets/ui_kit.dart';
import '../theme/app_tokens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AppRole _selectedRole = AppRole.staff;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    // Listen for auth state changes (e.g. OAuth redirect coming back)
    AuthService.authStateChanges.listen((data) async {
      if (!mounted) return;
      if (data.event == AuthChangeEvent.signedIn) {
        await AppRoleService.setRole(_selectedRole);
        if (!mounted) return;
        _navigateToShell();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToShell() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const RoleAwareShell(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final input = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      // Bare usernames get the clinic domain; a full address is passed through.
      // Appending unconditionally made every account whose auth email uses
      // another domain impossible to reach from this screen.
      final email =
          input.contains('@') ? input : '$input@prodontics.local';
      await AuthService.signInWithEmail(email: email, password: password);

      await AppRoleService.setRole(_selectedRole);
      if (!mounted) return;
      _navigateToShell();
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Sign in failed. Check your credentials.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTokens.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPatient = _selectedRole == AppRole.patient;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AppGradientBackground(
        child: SafeArea(
          child: Align(
            alignment: const Alignment(0, -0.45),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AnimatedEntrance(child: _LogoBlock()),
                  const SizedBox(height: AppTokens.s32),
                  AnimatedEntrance(
                    index: 1,
                    child: Container(
                      decoration: PatientPortalTheme.glassDecoration(context),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('Welcome ',
                                  style:
                                      PatientPortalTheme.displayLarge(context)),
                              Text(
                                'back',
                                style: PatientPortalTheme.displayLarge(context)
                                    .copyWith(color: AppTokens.accent),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.s8),
                          Text(
                            isPatient
                                ? 'Sign in to your patient portal'
                                : 'Sign in to your clinic workspace',
                            style: PatientPortalTheme.body(context),
                          ),
                          const SizedBox(height: AppTokens.s24),
                          _RoleToggle(
                            selected: _selectedRole,
                            onChanged: (r) {
                              _formKey.currentState?.reset();
                              setState(() => _selectedRole = r);
                            },
                          ),
                          const SizedBox(height: AppTokens.s24),
                          LoginFormSection(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            onSignIn: _onSignIn,
                            isLoading: _isLoading,
                            isPatientPortal: isPatient,
                          ),
                        ],
                      ),
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

/// Logo badge + wordmark above the card.
class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTokens.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppTokens.hairline),
            boxShadow: AppTokens.shadowMd,
          ),
          child: const Center(
            child: ClipOval(child: PatientPortalLogo(height: 58, width: 58)),
          ),
        ),
        const SizedBox(height: AppTokens.s20),
        Text(
          'Prodontics',
          style: PatientPortalTheme.displayLarge(context),
        ),
        const SizedBox(height: AppTokens.s4),
        Text(
          'KOKAPET',
          style: PatientPortalTheme.label(context).copyWith(
            letterSpacing: 3.2,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTokens.muted,
          ),
        ),
      ],
    );
  }
}

/// Sleek pill segmented control for Staff / Patient.
class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.selected, required this.onChanged});

  final AppRole selected;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppTokens.subtle,
        borderRadius: AppTokens.brLg,
      ),
      child: Row(
        children: [
          _segment('Staff', AppRole.staff, Icons.medical_services_rounded),
          _segment('Patient', AppRole.patient, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _segment(String label, AppRole role, IconData icon) {
    return Expanded(
      child: Builder(
        builder: (context) {
          final active = selected == role;
          return GestureDetector(
            onTap: () => onChanged(role),
            // Raised white pill on a recessed track — the segmented-control
            // idiom. A solid blue fill here would compete with the sign-in CTA
            // directly below it.
            child: AnimatedContainer(
              duration: AppTokens.medium,
              curve: AppTokens.ease,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? AppTokens.surface : null,
                borderRadius: AppTokens.brMd,
                boxShadow: active ? AppTokens.shadowSm : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: active ? AppTokens.accent : AppTokens.muted,
                  ),
                  const SizedBox(width: AppTokens.s8),
                  Text(
                    label,
                    style: PatientPortalTheme.titleMedium(context).copyWith(
                      fontSize: 14,
                      color: active ? AppTokens.ink : AppTokens.muted,
                    ),
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
