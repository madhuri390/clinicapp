import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model.dart';

class PatientRepository {
  final _db = Supabase.instance.client.from('patients');

  Future<List<Patient>> getAll() async {
    final data =
        await _db.select().order('created_at', ascending: false);
    return (data as List)
        .map((e) => Patient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Patient?> getById(String id) async {
    final data = await _db.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Patient.fromJson(data);
  }

  Future<List<Patient>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    final data = await _db
        .select()
        .or('first_name.ilike.%$q%,last_name.ilike.%$q%,phone.ilike.%$q%')
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Patient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Patient> create(Patient patient) async {
    final result =
        await _db.insert(patient.toInsertJson()).select().single();
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
