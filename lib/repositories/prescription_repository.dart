import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/prescription_model.dart';

class PrescriptionRepository {
  final _db = Supabase.instance.client.from('prescriptions');
  final List<Prescription> _mockCache = [];

  Future<List<Prescription>> getForVisit(String visitId) async {
    final data = await _db
        .select()
        .eq('visit_id', visitId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Prescription>> getForPatientVisits(List<String> visitIds) async {
    if (visitIds.isEmpty) return _mockCache;
    try {
      final data = await _db
          .select()
          .inFilter('visit_id', visitIds)
          .order('created_at', ascending: false);
      final dbData = (data as List)
          .map((e) => Prescription.fromJson(e as Map<String, dynamic>))
          .toList();
      return [...dbData, ..._mockCache];
    } catch (_) {
      return _mockCache;
    }
  }

  Future<Prescription> create(Prescription prescription) async {
    try {
      final result = await _db
          .insert(prescription.toInsertJson())
          .select()
          .single();
      return Prescription.fromJson(result);
    } catch (_) {
      final mock = Prescription(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        visitId: prescription.visitId,
        treatmentPlanId: prescription.treatmentPlanId,
        sittingId: prescription.sittingId,
        medicineName: prescription.medicineName,
        dosage: prescription.dosage,
        instructions: prescription.instructions,
      );
      _mockCache.add(mock);
      return mock;
    }
  }

  Future<void> delete(String id) async {
    await _db.delete().eq('id', id);
  }
}
