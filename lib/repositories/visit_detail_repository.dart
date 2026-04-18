import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/treatment_template_model.dart';
import '../models/visit_detail_model.dart';
import '../models/visit_model.dart';

/// Single repository for the full Patient → Visits → TreatmentPlans →
/// Sittings → Payments hierarchy. All operations hit Supabase directly;
/// no local mock data.
class VisitDetailRepository {
  static final _client = Supabase.instance.client;

  // ── Nested select used by both ongoing and history tabs ──────────────────

  /// Supabase nested select query that pulls a full visit with all children
  /// in a single round-trip.
  static const _nestedSelect = '''
    id, patient_id, doctor_id, visit_date, chief_complaint,
    diagnosis, notes, next_visit_date, status, created_at,
    doctors ( id, first_name, last_name ),
    treatment_plans (
      id, visit_id, treatment_name, description, total_cost, status, created_at,
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

  // ── Reads ────────────────────────────────────────────────────────────────

  /// Fetch ongoing visits (status = 'ongoing') for a patient.
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

  /// Fetch completed visits (status = 'complete') for a patient.
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

  /// Fetch a single visit with all nested data.
  Future<VisitDetail?> getById(String visitId) async {
    final data = await _client
        .from('visits')
        .select(_nestedSelect)
        .eq('id', visitId)
        .maybeSingle();
    if (data == null) return null;
    return VisitDetail.fromJson(data);
  }

  // ── Visit mutations ──────────────────────────────────────────────────────

  /// Create a new consultation (returns inserted row).
  Future<Visit> createVisit(Visit visit) async {
    final result = await _client
        .from('visits')
        .insert(visit.toInsertJson())
        .select()
        .single();
    return Visit.fromJson(result);
  }

  /// Update any fields on a visit (e.g. complete it).
  Future<void> updateVisit(String visitId, Map<String, dynamic> changes) =>
      _client.from('visits').update(changes).eq('id', visitId);

  /// Mark a visit as completed.
  Future<void> completeVisit(String visitId) =>
      updateVisit(visitId, {'status': 'complete'});

  /// Delete a visit (cascades to treatments/sittings/payments via FK).
  Future<void> deleteVisit(String visitId) =>
      _client.from('visits').delete().eq('id', visitId);

  // ── Treatment plan mutations ─────────────────────────────────────────────

  /// Fetch all active treatment templates (for picker).
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

  /// Insert a new treatment plan.
  Future<TreatmentPlan> addTreatment(TreatmentPlan plan) async {
    final result = await _client
        .from('treatment_plans')
        .insert(plan.toInsertJson())
        .select()
        .single();
    return TreatmentPlan.fromJson(result);
  }

  /// Update treatment plan status.
  Future<void> updateTreatmentStatus(String id, String status) =>
      _client.from('treatment_plans').update({'status': status}).eq('id', id);

  // ── Sitting mutations ────────────────────────────────────────────────────

  /// Insert a new sitting.
  Future<Sitting> addSitting(Sitting sitting) async {
    final result = await _client
        .from('sittings')
        .insert(sitting.toInsertJson())
        .select()
        .single();
    return Sitting.fromJson(result);
  }

  /// Update a sitting's status.
  Future<void> updateSittingStatus(String id, String status) =>
      _client.from('sittings').update({'status': status}).eq('id', id);

  // ── Prescription mutations ───────────────────────────────────────────────

  /// Insert a prescription.
  Future<Prescription> addPrescription(Prescription prescription) async {
    final result = await _client
        .from('prescriptions')
        .insert(prescription.toInsertJson())
        .select()
        .single();
    return Prescription.fromJson(result);
  }

  Future<void> deletePrescription(String id) =>
      _client.from('prescriptions').delete().eq('id', id);

  // ── Payment mutations ────────────────────────────────────────────────────

  /// Insert a payment.
  Future<Payment> addPayment(Payment payment) async {
    final result = await _client
        .from('payments')
        .insert(payment.toInsertJson())
        .select()
        .single();
    return Payment.fromJson(result);
  }
}
