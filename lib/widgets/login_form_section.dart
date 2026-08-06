import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/patient_portal_theme.dart';
import 'ui_kit.dart';
import '../theme/app_tokens.dart';

/// The credential fields + sign-in button, styled for the refreshed login.
class LoginFormSection extends StatelessWidget {
  const LoginFormSection({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSignIn,
    required this.isLoading,
    this.isPatientPortal = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSignIn;
  final bool isLoading;
  final bool isPatientPortal;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            controller: emailController,
            hint: 'Username or email',
            icon: Icons.account_circle_outlined,
            inputFormatters: [
              // '@' is allowed so accounts whose auth email is not on the
              // clinic domain can be typed in full.
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._@-]')),
            ],
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return 'Enter your username';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _PasswordField(controller: passwordController),
          const SizedBox(height: 24),
          isLoading
              ? const SizedBox(
                  height: 54,
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          PatientPortalTheme.brightBlue,
                        ),
                      ),
                    ),
                  ),
                )
              : GradientButton(
                  label: 'Sign in',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onSignIn,
                ),
        ],
      ),
    );
  }
}

// ── Fields ──────────────────────────────────────────────────────────────────

InputDecoration _decoration(BuildContext context, String hint, IconData icon,
    {Widget? suffixIcon}) {
  OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: PatientPortalTheme.body(context),
    prefixIcon: Icon(icon, color: PatientPortalTheme.brightBlue),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.85),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: border(Colors.transparent),
    enabledBorder: border(AppTokens.hairline),
    focusedBorder: border(PatientPortalTheme.brightBlue, 1.8),
    errorBorder: border(AppTokens.danger),
    focusedErrorBorder: border(AppTokens.danger, 1.8),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      style: PatientPortalTheme.titleMedium(context).copyWith(fontSize: 15),
      decoration: _decoration(context, hint, icon),
      inputFormatters: inputFormatters,
      validator: validator,
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
      style: PatientPortalTheme.titleMedium(context).copyWith(fontSize: 15),
      decoration: _decoration(
        context,
        'Password',
        Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: PatientPortalTheme.textSecondary,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        return null;
      },
    );
  }
}
