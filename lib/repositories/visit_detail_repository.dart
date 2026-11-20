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

  /// Whether `visits.treatment_advised` exists yet.
  ///
  /// The column arrives in supabase_add_treatment_advised.sql. If the app is
  /// deployed before that migration runs, selecting it would 400 and take the
  /// Ongoing and History tabs down with it — so the first such failure flips
  /// this flag and the query is retried without the column. A clinic losing
  /// the visit tabs is far worse than losing one line of one of them.
  static bool _hasTreatmentAdvised = true;

  /// Whether `visits.receipt_number` exists yet.
  /// Same guarded-retry story as [_hasTreatmentAdvised]: added in
  /// supabase_add_receipt_number.sql, which may not have run yet everywhere.
  static bool _hasReceiptNumber = true;

  static String get _nestedSelect => '''
    id, patient_id, doctor_id, visit_date, chief_complaint,
    diagnosis,${_hasTreatmentAdvised ? ' treatment_advised,' : ''} notes, next_visit_date, status, created_at,${_hasReceiptNumber ? ' receipt_number,' : ''}
    doctors ( id, first_name, last_name ),
    patients ( id, first_name, last_name ),
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

  /// Runs a nested-select query, retrying once without `treatment_advised` if
  /// the column is not in the database yet.
  Future<T> _nested<T>(Future<T> Function(String select) run) async {
    try {
      return await run(_nestedSelect);
    } on PostgrestException catch (e) {
      if (e.code != '42703') rethrow;
      if (_hasTreatmentAdvised && e.message.contains('treatment_advised')) {
        _hasTreatmentAdvised = false;
      } else if (_hasReceiptNumber && e.message.contains('receipt_number')) {
        _hasReceiptNumber = false;
      } else {
        rethrow;
      }
      return run(_nestedSelect);
    }
  }

  // ── Reads ─────────────────────────────────────────────────────────────

  Future<List<VisitDetail>> getOngoing(String patientId) async {
    final data = await _nested((sel) => _client
        .from('visits')
        .select(sel)
        .eq('patient_id', patientId)
        .eq('status', 'ongoing')
        .order('visit_date', ascending: false));
    return (data as List)
        .map((e) => VisitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VisitDetail>> getAllOngoing() async {
    final data = await _nested((sel) => _client
        .from('visits')
        .select(sel)
        .eq('status', 'ongoing')
        .order('visit_date', ascending: false));
    return (data as List)
        .map((e) => VisitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Completed visits, newest first, one page at a time.
  ///
  /// Paged because each row carries its whole nested tree (treatment plans →
  /// sittings, prescriptions, payments); a patient with years of migrated
  /// history would otherwise pull all of it on open.
  Future<List<VisitDetail>> getHistory(
    String patientId, {
    int offset = 0,
    int limit = historyPageSize,
  }) async {
    final data = await _nested((sel) => _client
        .from('visits')
        .select(sel)
        .eq('patient_id', patientId)
        .eq('status', 'complete')
        .order('visit_date', ascending: false)
        .range(offset, offset + limit - 1));
    return (data as List)
        .map((e) => VisitDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Completed visits fetched per page by [getHistory].
  static const historyPageSize = 10;

  Future<VisitDetail?> getById(String visitId) async {
    final data = await _nested((sel) => _client
        .from('visits')
        .select(sel)
        .eq('id', visitId)
        .maybeSingle());
    if (data == null) return null;
    return VisitDetail.fromJson(data);
  }

  // ── Doctor lookup ─────────────────────────────────────────────────────

  // Cached per auth uid: three screens resolve this on open, and it never
  // changes for a given session.
  static String? _doctorIdUid;
  static String? _doctorIdValue;

  /// Returns the doctor row ID for the currently authenticated user.
  /// Returns null if the user is not a doctor or not logged in.
  Future<String?> getDoctorIdForCurrentUser() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    if (_doctorIdUid == uid) return _doctorIdValue;
    final row = await _client
        .from('doctors')
        .select('id')
        .eq('auth_user_id', uid)
        .maybeSingle();
    _doctorIdUid = uid;
    _doctorIdValue = row?['id'] as String?;
    return _doctorIdValue;
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

  Future<void> completeVisit(String visitId) async {
    await updateVisit(visitId, {'status': 'complete'});
    await _maybeAssignReceiptNumber(visitId);
  }

  Future<void> reopenVisit(String visitId) =>
      updateVisit(visitId, {'status': 'ongoing'});

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

  Future<void> deletePaymentsForTreatment(String treatmentPlanId) =>
      _client
          .from('payments')
          .delete()
          .eq('treatment_plan_id', treatmentPlanId)
          .filter('sitting_id', 'is', null);

  Future<void> deletePaymentsForSitting(String sittingId) =>
      _client
          .from('payments')
          .delete()
          .eq('sitting_id', sittingId);

  /// Stamps `visits.receipt_number` when a visit is marked complete.
  /// Assigned once — a visit that already has a number is left alone, so
  /// reprinting a bill never changes it. The UI only allows completing a
  /// visit once its balance is 0, so no balance check is needed here.
  Future<void> _maybeAssignReceiptNumber(String visitId) async {
    if (!_hasReceiptNumber) return;
    try {
      final visitRow = await _client
          .from('visits')
          .select('receipt_number')
          .eq('id', visitId)
          .single();
      if (visitRow['receipt_number'] != null) return;

      await _client
          .from('visits')
          .update({'receipt_number': await _nextReceiptNumber()})
          .eq('id', visitId);
    } on PostgrestException catch (e) {
      if (e.code == '42703' && e.message.contains('receipt_number')) {
        _hasReceiptNumber = false;
        return;
      }
      rethrow;
    }
  }

  /// Next `YYYYMMDD-NN` number for today, NN being how many visits have
  /// already been stamped for the same day.
  Future<String> _nextReceiptNumber() async {
    final now = DateTime.now();
    final datePart = '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final existing = await _client
        .from('visits')
        .select('id')
        .like('receipt_number', '$datePart-%');
    final seq = ((existing as List).length + 1).toString().padLeft(2, '0');
    return '$datePart-$seq';
  }
}
