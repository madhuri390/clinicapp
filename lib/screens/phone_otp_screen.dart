import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key, this.initialPhone = ''});

  final String initialPhone;

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = widget.initialPhone;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrl) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  String get _phone {
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\s'), '');
    return raw.startsWith('+') ? raw : '+91$raw';
  }

  Future<void> _sendOtp() async {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      _showError('Enter a valid 10-digit phone number');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.sendPhoneOtp(_phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _loading = false;
        _resendSeconds = 30;
      });
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $_phone'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Failed to send OTP. Check phone number format.');
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      return _resendSeconds > 0;
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.map((c) => c.text).join();
    if (otp.length != 6) {
      _showError('Enter the complete 6-digit OTP');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.verifyPhoneOtp(phone: _phone, otp: otp);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Invalid OTP. Please try again.');
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
        title: Text(
          'Phone Login',
          style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_outlined,
                    size: 36, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                _otpSent ? 'Verify your number' : 'Enter phone number',
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'We sent a 6-digit code to $_phone'
                    : 'We\'ll send you a one-time password via SMS',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              if (!_otpSent) ...[
                // ── Phone field ──────────────────────────────────────────
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixText: '+91  ',
                    prefixStyle: GoogleFonts.poppins(
                        fontSize: 15, color: Colors.black87),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text('Send OTP',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                // ── OTP boxes ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 46,
                      height: 56,
                      child: TextField(
                        controller: _otpCtrl[i],
                        focusNode: _otpFocus[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor, width: 2),
                          ),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            _otpFocus[i + 1].requestFocus();
                          }
                          if (v.isEmpty && i > 0) {
                            _otpFocus[i - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _verifyOtp,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text('Verify & Login',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: _resendSeconds > 0
                      ? Text(
                          'Resend OTP in ${_resendSeconds}s',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey.shade500),
                        )
                      : GestureDetector(
                          onTap: _sendOtp,
                          child: Text(
                            'Resend OTP',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _otpSent = false),
                    child: Text(
                      'Change phone number',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
