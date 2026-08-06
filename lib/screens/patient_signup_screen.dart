import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';
import '../services/app_role_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/role_aware_shell.dart';
import '../theme/app_tokens.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTokens.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

    if (username.isEmpty) {
      _showError('Please provide a username');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final password = _passwordCtrl.text;
      late final AuthResponse authResponse;

      final authEmail = email.isNotEmpty ? email : '$username@prodontics.local';

      authResponse = await AuthService.signUpWithEmail(
        email: authEmail,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('User creation failed: No user returned');
      }

      // RLS requires a JWT: if email confirmation is on, signUp returns no session and
      // the insert runs as `anon` and fails. Sign in immediately when possible.
      if (authResponse.session == null) {
        try {
          await AuthService.signInWithEmail(email: authEmail, password: password);
        } on AuthException catch (e) {
          if (!mounted) return;
          _showError(
            'Account may need email/phone confirmation first (${e.message}). '
            'In Supabase: Authentication → Providers → turn off "Confirm email" for testing, '
            'or confirm your inbox and sign in manually.',
          );
          return;
        }
      }

      // Format phone for storage
      String? phoneVal;
      if (phone.isNotEmpty) {
        phoneVal = phone.startsWith('+') ? phone : '+91$phone';
      }

      // Prepare patient model for database insert (auth_user_id enables patient RLS)
      final patient = Patient(
        id: user.id,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isNotEmpty ? _lastNameCtrl.text.trim() : null,
        phone: phoneVal ?? '',
        email: email.isNotEmpty ? email : null,
        createdAt: DateTime.now(),
        authUserId: user.id,
        username: username,
      );

      // Save into Supabase Patients Table (upsert so retries after partial failure work)
      final repo = PatientRepository();
      await repo.upsert(patient);

      // Set App Role securely to ensure we navigate to patient view
      await AppRoleService.setRole(AppRole.patient);

      if (!mounted) return;
      
      // On success, go to shell
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const RoleAwareShell()),
        (_) => false,
      );
      
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to complete registration: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTokens.body),
        title: Text(
          'Patient Registration',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTokens.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1_outlined,
                        size: 36, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create an Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below to complete your registration.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTokens.body,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                _buildTextField(
                  controller: _usernameCtrl,
                  label: 'Username *',
                  prefixIcon: Icons.account_circle_outlined,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]')),
                  ],
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameCtrl,
                        label: 'First Name *',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameCtrl,
                        label: 'Last Name',
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneCtrl,
                  label: 'Phone Number (Optional)',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final s = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (s.isNotEmpty && s.length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailCtrl,
                  label: 'Email (Optional)',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isNotEmpty && !s.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTokens.body,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if ((v?.length ?? 0) < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            'Sign Up Now',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      style: GoogleFonts.plusJakartaSans(fontSize: 15, color: AppTokens.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTokens.body),
        prefixIcon: Icon(prefixIcon, color: AppTokens.muted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTokens.subtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTokens.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTokens.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTokens.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
