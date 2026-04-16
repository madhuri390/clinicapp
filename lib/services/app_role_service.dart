import 'package:shared_preferences/shared_preferences.dart';

/// Staff (clinic) vs patient portal. Persisted so cold start returns to the right shell.
enum AppRole { staff, patient }

class AppRoleService {
  AppRoleService._();

  static const _prefsKey = 'app_role';

  static AppRole _current = AppRole.staff;

  static AppRole get current => _current;

  static bool get isPatient => _current == AppRole.patient;

  static bool get isStaff => _current == AppRole.staff;

  /// Call from [main] before [runApp].
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _current = raw == AppRole.patient.name ? AppRole.patient : AppRole.staff;
  }

  static Future<void> setRole(AppRole role) async {
    _current = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, role.name);
  }
}
