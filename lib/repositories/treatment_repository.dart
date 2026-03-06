import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/treatment_plan_model.dart';
import '../models/payment_model.dart';

class TreatmentRepository {
  final _db = Supabase.instance.client.from('treatment_plans');
  final _payments = Supabase.instance.client.from('payments');

  Future<List<TreatmentPlan>> getForVisit(String visitId) async {
    final data = await _db
        .select()
        .eq('visit_id', visitId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => TreatmentPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns all treatment plans for all visits of a patient.
  Future<List<TreatmentPlan>> getForPatientVisits(
      List<String> visitIds) async {
    if (visitIds.isEmpty) return [];
    final data = await _db
        .select()
        .inFilter('visit_id', visitIds)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => TreatmentPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TreatmentPlan> create(TreatmentPlan plan) async {
    final result =
        await _db.insert(plan.toInsertJson()).select().single();
    return TreatmentPlan.fromJson(result);
  }

  Future<void> updateStatus(String id, String status) async {
    await _db.update({'status': status}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _db.delete().eq('id', id);
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  Future<List<Payment>> getPaymentsForPlan(String treatmentPlanId) async {
    final data = await _payments
        .select()
        .eq('treatment_plan_id', treatmentPlanId)
        .order('payment_date', ascending: false);
    return (data as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Payment> addPayment(Payment payment) async {
    final result =
        await _payments.insert(payment.toInsertJson()).select().single();
    return Payment.fromJson(result);
  }
}
