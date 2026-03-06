import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visit_model.dart';

class VisitRepository {
  final _db = Supabase.instance.client.from('visits');

  Future<List<Visit>> getForPatient(String patientId) async {
    final data = await _db
        .select()
        .eq('patient_id', patientId)
        .order('visit_date', ascending: false);
    return (data as List)
        .map((e) => Visit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Visit?> getById(String id) async {
    final data = await _db.select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Visit.fromJson(data);
  }

  Future<Visit> create(Visit visit) async {
    final result =
        await _db.insert(visit.toInsertJson()).select().single();
    return Visit.fromJson(result);
  }

  Future<void> update(String id, Map<String, dynamic> changes) async {
    await _db.update(changes).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _db.delete().eq('id', id);
  }
}
