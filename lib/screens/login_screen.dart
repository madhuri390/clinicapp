import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/login_form_section.dart';
import 'main_shell.dart';
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
    AuthService.authStateChanges.listen((data) {
      if (!mounted) return;
      if (data.event == AuthChangeEvent.signedIn) {
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
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _onSignIn() async {
    // TODO: DEV ONLY — bypass auth, accept any credentials
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // fake delay
    if (!mounted) return;
    setState(() => _isLoading = false);
    _navigateToShell();
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

  void _showPhoneOtp(String phone) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sign-up coming soon — contact admin to create account'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          _BlueHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: LoginFormSection(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueHeader extends StatelessWidget {
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
            const ProdonticsBadge(size: 72, iconSize: 36),
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
