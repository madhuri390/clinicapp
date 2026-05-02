import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single source of truth for all authentication operations.
class AuthService {
  static final _client = Supabase.instance.client;

  /// Lazily resolved service role key from .env (admin operations only).
  static String get _serviceRoleKey =>
      dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  static String get _supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

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
  }) async {
    try {
      return await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthException(e.message.replaceAll('Email', 'Username').replaceAll('email', 'username'), statusCode: e.statusCode);
    }
  }

  static Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) =>
      _client.auth.signInWithPassword(phone: phone, password: password);

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthException(e.message.replaceAll('Email', 'Username').replaceAll('email', 'username'), statusCode: e.statusCode);
    }
  }

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

  // ── Admin: Create User (no email confirmation) ────────────────────────────

  /// Creates a new auth user via the Admin API (bypasses email confirmation).
  /// Requires SUPABASE_SERVICE_ROLE_KEY in .env.
  /// Returns the new user's UUID.
  static Future<String> adminCreateUser({
    String? email,
    String? phone,
    required String password,
  }) async {
    assert(email != null || phone != null, 'email or phone required');
    final url = '$_supabaseUrl/auth/v1/admin/users';
    final body = <String, dynamic>{
      'password': password,
      'email_confirm': true,  // skip confirmation
      'phone_confirm': true,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;

    print('[AuthService] adminCreateUser: Sending POST request to $url');
    print('[AuthService] adminCreateUser: Body: ${jsonEncode(body)}');
    // Ensure service key is set properly
    final keyPreview = _serviceRoleKey.length > 10 ? '${_serviceRoleKey.substring(0, 10)}...' : _serviceRoleKey;
    print('[AuthService] adminCreateUser: Using Service Key: $keyPreview (length: ${_serviceRoleKey.length})');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'apikey': _serviceRoleKey,
        'Authorization': 'Bearer $_serviceRoleKey',
      },
      body: jsonEncode(body),
    );

    print('[AuthService] adminCreateUser: Response Status: ${response.statusCode}');
    print('[AuthService] adminCreateUser: Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      var msg = decoded?['msg'] ?? decoded?['message'] ?? response.body;
      if (msg is String) {
        msg = msg.replaceAll('Email', 'Username').replaceAll('email', 'username');
      }
      print('[AuthService] Error in adminCreateUser: $msg');
      throw Exception('Failed to create auth user: $msg');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['id'] as String;
  }

  // ── Admin: Update User ───────────────────────────────────────────────────

  /// Updates the email, phone, or password for any auth user by their UUID.
  /// Requires SUPABASE_SERVICE_ROLE_KEY in .env.
  static Future<void> adminUpdateUser({
    required String userId,
    String? email,
    String? phone,
    String? password,
  }) async {
    final url = '$_supabaseUrl/auth/v1/admin/users/$userId';
    print('[AuthService] adminUpdateUser: PUT request to $url');
    
    final body = <String, dynamic>{};
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (password != null && password.isNotEmpty) body['password'] = password;

    if (body.isEmpty) return; // Nothing to update

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'apikey': _serviceRoleKey,
        'Authorization': 'Bearer $_serviceRoleKey',
      },
      body: jsonEncode(body),
    );

    print('[AuthService] adminUpdateUser: Response Status: ${response.statusCode}');
    print('[AuthService] adminUpdateUser: Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      var msg = decoded?['msg'] ?? decoded?['message'] ?? response.body;
      if (msg is String) {
        msg = msg.replaceAll('Email', 'Username').replaceAll('email', 'username');
      }
      print('[AuthService] Error in adminUpdateUser: $msg');
      throw Exception('Failed to update auth user: $msg');
    }
  }

  // ── Test helper ──────────────────────────────────────────────────────────

  static SupabaseClient get client => _client;
}
