import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/treatment_template_model.dart';
import '../models/visit_detail_model.dart';
import '../models/visit_model.dart';

/// Single repository for Patient → Visits → TreatmentPlans → Sittings → Payments.
/// All operations hit Supabase directly; no local mock data.
class VisitDetailRepository {
  static final _client = Supabase.instance.client;

  // ── Nested select (single round-trip, no N+1) ─────────────────────────

  static const _nestedSelect = '''
    id, patient_id, doctor_id, visit_date, chief_complaint,
    diagnosis, notes, next_visit_date, status, created_at,
    doctors ( id, first_name, last_name ),
    treatment_plans (
      id, visit_id, treatment_name, description, teeth, total_cost, status, created_at,
      sittings (
        id, visit_id, treatment_plan_id, sitting_date,
        duration_str, notes, cost, status, created_at
      )
    ),
    prescriptions (
      id, visit_id, treatment_plan_id, sitting_id,
      medicine_name, dosage, duration, instructions, price, created_at
    ),
    payments (
      id, visit_id, treatment_plan_id, sitting_id,
      prescription_id, file_id,
      amount_paid, payment_mode, payment_date, notes, created_at
    )
  ''';

  // ── Reads ─────────────────────────────────────────────────────────────

  Future<List<VisitDetail>> getOngoing(String patientId) async {
    final data = await _client
        .from('visits')
        .select(_nestedSelect)
        .eq('patient_id', patientId)
        .eq('status', 'ongoing')
        .order('visit_date', ascending: false);
    return (data as List)
        .map((e) => VisitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VisitDetail>> getHistory(String patientId) async {
    final data = await _client
        .from('visits')
        .select(_nestedSelect)
        .eq('patient_id', patientId)
        .eq('status', 'complete')
        .order('visit_date', ascending: false);
    return (data as List)
        .map((e) => VisitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VisitDetail?> getById(String visitId) async {
    final data = await _client
        .from('visits')
        .select(_nestedSelect)
        .eq('id', visitId)
        .maybeSingle();
    if (data == null) return null;
    return VisitDetail.fromJson(data);
  }

  // ── Doctor lookup ─────────────────────────────────────────────────────

  /// Returns the doctor row ID for the currently authenticated user.
  /// Returns null if the user is not a doctor or not logged in.
  Future<String?> getDoctorIdForCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client
        .from('doctors')
        .select('id')
        .eq('auth_user_id', uid)
        .maybeSingle();
    return row?['id'] as String?;
  }

  // ── Visit mutations ───────────────────────────────────────────────────

  Future<Visit> createVisit(Visit visit) async {
    final result = await _client
        .from('visits')
        .insert(visit.toInsertJson())
        .select()
        .single();
    return Visit.fromJson(result);
  }

  Future<void> updateVisit(String visitId, Map<String, dynamic> changes) =>
      _client.from('visits').update(changes).eq('id', visitId);

  Future<void> completeVisit(String visitId) =>
      updateVisit(visitId, {'status': 'complete'});

  Future<void> deleteVisit(String visitId) =>
      _client.from('visits').delete().eq('id', visitId);

  // ── Treatment plan mutations ──────────────────────────────────────────

  Future<List<TreatmentTemplate>> getTreatmentTemplates() async {
    final data = await _client
        .from('treatment_templates')
        .select()
        .eq('is_active', true)
        .order('name');
    return (data as List)
        .map((e) => TreatmentTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TreatmentPlan> addTreatment(TreatmentPlan plan) async {
    final result = await _client
        .from('treatment_plans')
        .insert(plan.toInsertJson())
        .select()
        .single();
    return TreatmentPlan.fromJson(result);
  }

  Future<void> updateTreatmentStatus(String id, String status) =>
      _client.from('treatment_plans').update({'status': status}).eq('id', id);

  Future<void> updateTreatment(String id, Map<String, dynamic> changes) =>
      _client.from('treatment_plans').update(changes).eq('id', id);

  // ── Sitting mutations ─────────────────────────────────────────────────

  Future<Sitting> addSitting(Sitting sitting) async {
    final result = await _client
        .from('sittings')
        .insert(sitting.toInsertJson())
        .select()
        .single();
    return Sitting.fromJson(result);
  }

  Future<void> updateSittingStatus(String id, String status) =>
      _client.from('sittings').update({'status': status}).eq('id', id);

  Future<void> updateSitting(String id, Map<String, dynamic> changes) =>
      _client.from('sittings').update(changes).eq('id', id);

  // ── Prescription mutations ────────────────────────────────────────────

  Future<Prescription> addPrescription(Prescription prescription) async {
    final result = await _client
        .from('prescriptions')
        .insert(prescription.toInsertJson())
        .select()
        .single();
    return Prescription.fromJson(result);
  }

  Future<void> updatePrescription(String id, Map<String, dynamic> changes) =>
      _client.from('prescriptions').update(changes).eq('id', id);

  Future<void> deletePrescription(String id) =>
      _client.from('prescriptions').delete().eq('id', id);

  // ── Payment mutations ─────────────────────────────────────────────────

  Future<Payment> addPayment(Payment payment) async {
    final result = await _client
        .from('payments')
        .insert(payment.toInsertJson())
        .select()
        .single();
    return Payment.fromJson(result);
  }
}
