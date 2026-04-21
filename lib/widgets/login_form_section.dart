import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.formKey,
    required this.emailOrPhoneController,
    required this.passwordController,
    required this.onSignIn,
    required this.isLoading,
    this.isPatientPortal = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailOrPhoneController;
  final TextEditingController passwordController;
  final VoidCallback onSignIn;
  final bool isLoading;
  final bool isPatientPortal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        28,
        24,
        28,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isPatientPortal ? 'Patient Login' : 'Staff Login',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 24),

          // ── Email/Password form ──────────────────────────────────────────
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EmailOrPhoneField(controller: emailOrPhoneController),
                const SizedBox(height: 14),
                _PasswordField(controller: passwordController),
                const SizedBox(height: 24),
                _LoginNowButton(onPressed: onSignIn, isLoading: isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fields ────────────────────────────────────────────────────────────────────

class _EmailOrPhoneField extends StatelessWidget {
  const _EmailOrPhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF263238)),
      decoration: InputDecoration(
        hintText: 'Email or phone number',
        hintStyle:
            GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (v) {
        final s = v?.trim() ?? '';
        if (s.isEmpty) return 'Enter email or phone number';
        final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(s);
        if (hasLetters) {
          // Treat as email attempt
          final re = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!re.hasMatch(s)) return 'Enter a valid email address';
        } else {
          // Treat as phone attempt
          if (s.replaceAll(RegExp(r'\D'), '').length < 10) {
            return 'Enter a valid phone number';
          }
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF263238)),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle:
            GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        return null;
      },
    );
  }
}

class _LoginNowButton extends StatelessWidget {
  const _LoginNowButton({required this.onPressed, required this.isLoading});
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Login now',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

