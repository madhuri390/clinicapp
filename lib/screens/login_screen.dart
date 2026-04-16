import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/login_form_section.dart';
import '../services/app_role_service.dart';
import '../widgets/patient_portal_logo.dart';
import '../widgets/role_aware_shell.dart';
import 'patient_signup_screen.dart';
import 'phone_otp_screen.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  AppRole _selectedRole = AppRole.staff;
  bool _isLoading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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
    _emailOrPhoneController.dispose();
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

    final input = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);
    
    try {
      if (input.contains('@')) {
        await AuthService.signInWithEmail(email: input, password: password);
      } else {
        String phoneStr = input.replaceAll(RegExp(r'\D'), ''); // Strip non digits
        if (!phoneStr.startsWith('+')) {
          phoneStr = '+91$phoneStr'; // default formatting
        }
        await AuthService.signInWithPhone(phone: phoneStr, password: password);
      }
      
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

  Future<void> _onGoogleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      final opened = await AuthService.signInWithGoogle();
      if (!mounted) return;
      if (!opened) {
        _showError('Could not open Google sign-in. Check Supabase Google provider.');
      }
      // Navigation happens via authStateChanges when user returns from browser
    } catch (e) {
      if (!mounted) return;
      _showError('Google sign-in failed.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _onAppleSignIn() async {
    setState(() => _appleLoading = true);
    try {
      final opened = await AuthService.signInWithApple();
      if (!mounted) return;
      if (!opened) {
        _showError('Could not open Apple sign-in. Check Supabase Apple provider.');
      }
      // Navigation happens via authStateChanges when user returns from browser
    } catch (e) {
      if (!mounted) return;
      _showError('Apple sign-in failed.');
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  Future<void> _showPhoneOtp(String phone) async {
    await AppRoleService.setRole(_selectedRole);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhoneOtpScreen(initialPhone: phone),
      ),
    );
  }

  void _onForgotPassword() async {
    final input = _emailOrPhoneController.text.trim();
    if (input.isEmpty || !input.contains('@')) {
      _showError('Enter your email address first to reset password');
      return;
    }
    try {
      await AuthService.resetPassword(input);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to $input'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _onSignUp() {
    if (_selectedRole == AppRole.staff) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff sign-up coming soon — contact admin to create account'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PatientSignupScreen(),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _BlueHeader(isPatientPortal: _selectedRole == AppRole.patient),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                    child: SegmentedButton<AppRole>(
                      segments: const [
                        ButtonSegment<AppRole>(
                          value: AppRole.staff,
                          label: Text('Staff'),
                          icon: Icon(Icons.medical_services_outlined, size: 18),
                        ),
                        ButtonSegment<AppRole>(
                          value: AppRole.patient,
                          label: Text('Patient'),
                          icon: Icon(Icons.person_outline, size: 18),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (s) {
                        _formKey.currentState?.reset();
                        setState(() => _selectedRole = s.first);
                      },
                    ),
                  ),
                  LoginFormSection(
                    formKey: _formKey,
                    emailOrPhoneController: _emailOrPhoneController,
                    passwordController: _passwordController,
                    onForgotPassword: _onForgotPassword,
                    onSignIn: _onSignIn,
                    onSignUp: _onSignUp,
                    isLoading: _isLoading,
                    onGoogleSignIn: _onGoogleSignIn,
                    onAppleSignIn: _onAppleSignIn,
                    onPhoneSignIn: () => _showPhoneOtp(''),
                    googleLoading: _googleLoading,
                    appleLoading: _appleLoading,
                    isPatientPortal: _selectedRole == AppRole.patient,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueHeader extends StatelessWidget {
  const _BlueHeader({this.isPatientPortal = false});
  final bool isPatientPortal;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return ClipPath(
      clipper: _ArchClipper(),
      child: Container(
        width: double.infinity,
        color: AppTheme.primaryColor,
        padding: EdgeInsets.only(top: topPadding + 32, bottom: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: ClipOval(
                  child: PatientPortalLogo(height: 50, width: 50),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Prodontics',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Kokapet',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 32,
        size.width,
        size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
