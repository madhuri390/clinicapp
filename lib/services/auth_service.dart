import 'package:supabase_flutter/supabase_flutter.dart';

/// Single source of truth for all authentication operations.
/// Google and Apple use Supabase OAuth (browser flow); no native packages required.
class AuthService {
  static final _client = Supabase.instance.client;

  // ── Getters ──────────────────────────────────────────────────────────────

  static Session? get currentSession => _client.auth.currentSession;
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentSession != null;

  /// Stream of auth state changes — listen in root widget.
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ── Email / Password ─────────────────────────────────────────────────────

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _client.auth.signInWithPassword(email: email, password: password);

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _client.auth.signUp(email: email, password: password);

  static Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  // ── Google Sign-In (Supabase OAuth — opens browser) ──────────────────────

  /// Opens browser / in-app web view. Redirect URL must be configured in
  /// Supabase Dashboard → Auth → URL Configuration (e.g. io.supabase.clinicapp://login-callback/).
  static Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.clinicapp://login-callback/',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Apple Sign-In (Supabase OAuth — opens browser) ───────────────────────

  /// Opens browser / in-app web view. Apple provider must be enabled in
  /// Supabase Dashboard and redirect URL configured.
  static Future<bool> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.clinicapp://login-callback/',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Phone OTP ─────────────────────────────────────────────────────────────

  /// Step 1: Send OTP to phone number (+91XXXXXXXXXX format).
  static Future<void> sendPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Step 2: Verify the OTP received via SMS.
  static Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) =>
      _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

  // ── Sign Out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() => _client.auth.signOut();

  // ── Test helper ──────────────────────────────────────────────────────────

  static SupabaseClient get client => _client;
}
