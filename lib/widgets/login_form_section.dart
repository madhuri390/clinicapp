import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.formKey,
    required this.emailOrPhoneController,
    required this.passwordController,
    required this.onForgotPassword,
    required this.onSignIn,
    required this.onSignUp,
    required this.isLoading,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    required this.onPhoneSignIn,
    this.googleLoading = false,
    this.appleLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailOrPhoneController;
  final TextEditingController passwordController;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final VoidCallback onPhoneSignIn;
  final bool googleLoading;
  final bool appleLoading;

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
            'User Login',
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _ForgotPasswordLink(onTap: onForgotPassword),
                ),
                const SizedBox(height: 24),
                _LoginNowButton(onPressed: onSignIn, isLoading: isLoading),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Social buttons ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  label: 'Google',
                  icon: _GoogleIcon(),
                  isLoading: googleLoading,
                  onTap: onGoogleSignIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialButton(
                  label: 'Apple',
                  icon: const Icon(Icons.apple, size: 22, color: Colors.black87),
                  isLoading: appleLoading,
                  onTap: onAppleSignIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialButton(
                  label: 'Phone',
                  icon: Icon(Icons.phone_outlined,
                      size: 20, color: AppTheme.primaryColor),
                  isLoading: false,
                  onTap: onPhoneSignIn,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          _SignUpLink(onTap: onSignUp),
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
        if (s.contains('@')) {
          final re = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!re.hasMatch(s)) return 'Enter a valid email address';
        } else {
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

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        'Forgot password?',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
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

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Simple Google 'G' icon drawn with coloured text.
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        children: const [
          TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
        ],
      ),
    );
  }
}

// ── Sign up link ──────────────────────────────────────────────────────────────

class _SignUpLink extends StatelessWidget {
  const _SignUpLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No account yet? ',
          style:
              GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Sign up now →',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
