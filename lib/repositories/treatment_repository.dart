import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/treatment_plan_model.dart';
import '../models/payment_model.dart';

class TreatmentRepository {
  final _db = Supabase.instance.client.from('treatment_plans');
  final _payments = Supabase.instance.client.from('payments');

  // Mocks
  final List<Payment> _mockPayments = [];
  final List<dynamic> _mockSittings = [];
  final List<dynamic> _mockFiles = [];

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
  Future<List<TreatmentPlan>> getForPatientVisits(List<String> visitIds) async {
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
    final result = await _db.insert(plan.toInsertJson()).select().single();
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
    try {
      final data = await _payments
          .select()
          .eq('treatment_plan_id', treatmentPlanId)
          .order('payment_date', ascending: false);
      final dbData = (data as List)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList();
      return [
        ...dbData,
        ..._mockPayments.where((p) => p.treatmentPlanId == treatmentPlanId),
      ];
    } catch (_) {
      return _mockPayments
          .where((p) => p.treatmentPlanId == treatmentPlanId)
          .toList();
    }
  }

  Future<Payment> addPayment(Payment payment) async {
    try {
      final result = await _payments
          .insert(payment.toInsertJson())
          .select()
          .single();
      return Payment.fromJson(result);
    } catch (_) {
      final mock = Payment(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        treatmentPlanId: payment.treatmentPlanId,
        visitId: payment.visitId, // Added visitId
        sittingId: payment.sittingId,
        amountPaid: payment.amountPaid,
        paymentDate: payment.paymentDate,
        paymentMode: payment.paymentMode,
        notes: payment.notes,
      );
      _mockPayments.add(mock);
      return mock;
    }
  }

  // ── Sittings (MOCK) ───────────────────────────────────────────────────────

  Future<List<dynamic>> getSittingsForPlan(String treatmentPlanId) async {
    return _mockSittings
        .where((s) => s['treatmentPlanId'] == treatmentPlanId)
        .toList();
  }

  Future<dynamic> addSitting(dynamic sitting) async {
    final mockSitting = {
      ...sitting,
      'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
    };
    _mockSittings.add(mockSitting);
    return mockSitting;
  }

  // ── Files (MOCK) ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getFilesForPlan(String treatmentPlanId) async {
    return _mockFiles
        .where((f) => f['treatmentPlanId'] == treatmentPlanId)
        .toList();
  }

  Future<dynamic> addFile(dynamic fileRecord) async {
    final mockFile = {
      ...fileRecord,
      'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
    };
    _mockFiles.add(mockFile);
    return mockFile;
  }
}
