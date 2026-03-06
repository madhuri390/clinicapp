import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/prescription_model.dart';

class PrescriptionRepository {
  final _db = Supabase.instance.client.from('prescriptions');

  Future<List<Prescription>> getForVisit(String visitId) async {
    final data = await _db
        .select()
        .eq('visit_id', visitId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Prescription>> getForPatientVisits(
      List<String> visitIds) async {
    if (visitIds.isEmpty) return [];
    final data = await _db
        .select()
        .inFilter('visit_id', visitIds)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Prescription> create(Prescription prescription) async {
    final result =
        await _db.insert(prescription.toInsertJson()).select().single();
    return Prescription.fromJson(result);
  }

  Future<void> delete(String id) async {
    await _db.delete().eq('id', id);
  }
}
