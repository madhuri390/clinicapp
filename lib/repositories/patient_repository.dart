import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model.dart';

class PatientRepository {
  final _db = Supabase.instance.client.from('patients');
  static final _supabase = Supabase.instance.client;

  /// Columns the patient list and search results actually render. Selecting
  /// these instead of `*` keeps the free-text history/address columns off the
  /// wire; screens that need the whole row load it with [getById].
  static const _listColumns =
      'id, first_name, last_name, phone, gender, date_of_birth, created_at';

  /// Rows fetched per page by [getAll] and [search].
  static const pageSize = 30;

  // Doctor row id for the signed-in user, cached per auth uid: screens build a
  // fresh PatientRepository each time, and this lookup ran on every load.
  static String? _doctorIdUid;
  static String? _doctorIdValue;

  /// Returns the doctors-table row id for the current auth user, or null if
  /// the logged-in user is not a doctor (admin, manager, patient).
  Future<String?> _getDoctorId() async {
    final uid = _supabase.auth.currentUser?.id;
    debugPrint('[PatientRepo] authUid=$uid cached=$_doctorIdUid');
    if (uid == null) return null;
    if (_doctorIdUid == uid) return _doctorIdValue;
    final row = await _supabase
        .from('doctors')
        .select('id')
        .eq('auth_user_id', uid)
        .maybeSingle();
    _doctorIdUid = uid;
    _doctorIdValue = row?['id'] as String?;
    return _doctorIdValue;
  }

  Future<List<Patient>> getAll({int offset = 0, int limit = pageSize}) async {
    return _fetchPage(
      doctorId: await _getDoctorId(),
      query: null,
      offset: offset,
      limit: limit,
    );
  }

  /// One page of patients visible to the caller, newest first.
  ///
  /// A doctor sees:
  ///   • patients who have at least one visit with them, AND
  ///   • patients who have NO visits yet (newly added, not yet assigned).
  /// Patients who only have visits with other doctors are excluded. A caller
  /// with no doctors row sees nothing at all.
  Future<List<Patient>> _fetchPage({
    required String? doctorId,
    required String? query,
    required int offset,
    required int limit,
  }) async {
    debugPrint('[PatientRepo] fetchPage doctorId=$doctorId query=$query '
        'offset=$offset limit=$limit');

    // No doctors row for this login means we have nothing to scope the list
    // to, so fail closed. This used to return every patient in the clinic,
    // which handed the full list to any orphaned account — a deleted staff
    // member whose auth user outlived their doctors row, for instance.
    if (doctorId == null) {
      debugPrint('[PatientRepo] no doctor row for current user → empty list');
      return const <Patient>[];
    }

    final hidden = await _hiddenPatientIds(doctorId);
    debugPrint('[PatientRepo] hidden=${hidden.length}');

    var q = _db.select(_listColumns);
    if (query != null) {
      q = q.or(
        'first_name.ilike.%$query%,last_name.ilike.%$query%,phone.ilike.%$query%',
      );
    }
    if (hidden.isNotEmpty) {
      q = q.not('id', 'in', '(${hidden.join(',')})');
    }

    debugPrint('[PatientRepo] → patients query');
    final data = await q
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    debugPrint('[PatientRepo] ← patients rows=${data.length}');
    return data.map(Patient.fromJson).toList();
  }

  /// Patients [doctorId] must not see: they have visit history, but none of it
  /// with this doctor.
  ///
  /// Derived from the other doctors' visits — normally a small slice — so we
  /// never pull every visit row in the clinic just to build a patient list.
  Future<Set<String>> _hiddenPatientIds(String doctorId) async {
    // Visits belonging to someone else, or to nobody (unassigned doctor_id).
    debugPrint('[PatientRepo] → other-doctor visits');
    final otherRows = await _supabase
        .from('visits')
        .select('patient_id')
        .or('doctor_id.neq.$doctorId,doctor_id.is.null');
    debugPrint('[PatientRepo] ← other-doctor visits rows=${otherRows.length}');
    final hidden = otherRows
        .map((e) => e['patient_id'] as String?)
        .whereType<String>()
        .toSet();
    if (hidden.isEmpty) return hidden;

    // Of those, the ones this doctor has also seen stay visible.
    debugPrint('[PatientRepo] → my visits among ${hidden.length} candidates');
    final mineRows = await _supabase
        .from('visits')
        .select('patient_id')
        .eq('doctor_id', doctorId)
        .inFilter('patient_id', hidden.toList());
    debugPrint('[PatientRepo] ← my visits rows=${mineRows.length}');
    hidden.removeAll(mineRows.map((e) => e['patient_id'] as String?));
    return hidden;
  }

  Future<Patient?> getById(String id) async {
    final data = await _db.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Patient.fromJson(data);
  }

  /// Resolve the patient profile for the logged-in auth user.
  /// Supports both schemas:
  /// - `patients.auth_user_id == authUserId`
  /// - `patients.id == authUserId` (legacy/demo)
  Future<Patient?> getForAuthUser(String authUserId) async {
    final data = await _db
        .select()
        .or('auth_user_id.eq.$authUserId,id.eq.$authUserId')
        .maybeSingle();
    if (data == null) return null;
    return Patient.fromJson(data);
  }

  Future<List<Patient>> search(
    String query, {
    int offset = 0,
    int limit = pageSize,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return getAll(offset: offset, limit: limit);
    return _fetchPage(
      doctorId: await _getDoctorId(),
      query: q,
      offset: offset,
      limit: limit,
    );
  }

  Future<Patient> create(Patient patient) async {
    final result =
        await _db.insert(patient.toInsertJson()).select().single();
    return Patient.fromJson(result);
  }

  /// Insert or replace by primary key (used after auth sign-up).
  Future<Patient> upsert(Patient patient) async {
    final result = await _db
        .upsert(patient.toInsertJson(), onConflict: 'id')
        .select()
        .single();
    return Patient.fromJson(result);
  }

  Future<Patient> update(String id, Map<String, dynamic> changes) async {
    final result =
        await _db.update(changes).eq('id', id).select().single();
    return Patient.fromJson(result);
  }

  Future<void> delete(String id) async {
    await _db.delete().eq('id', id);
  }
}
