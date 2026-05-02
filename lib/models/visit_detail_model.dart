import 'payment_model.dart';
import 'prescription_model.dart';
import 'sitting_model.dart';
import 'treatment_plan_model.dart';
import 'visit_model.dart';

/// A fully-loaded visit with all nested relationships.
/// Populated by [VisitDetailRepository] from a single Supabase nested select.
class VisitDetail {
  const VisitDetail({
    required this.visit,
    required this.doctorName,
    required this.patientName,
    required this.treatments,
    required this.sittings,
    required this.prescriptions,
    required this.payments,
  });

  final Visit visit;
  final String doctorName;
  final String patientName;
  final List<TreatmentPlan> treatments;
  final List<Sitting> sittings;
  final List<Prescription> prescriptions;
  final List<Payment> payments;

  /// Sum of all payments linked to this visit.
  double get totalPaid =>
      payments.fold(0.0, (s, p) => s + p.amountPaid);

  /// Sum of treatment_plans.total_cost (treatment-level cost).
  double get totalTreatmentCost =>
      treatments.fold(0.0, (s, t) => s + (t.totalCost ?? 0));

  /// Sum of individual sitting costs (tracked separately from treatment cost).
  double get totalSittingsCost =>
      sittings.fold(0.0, (s, si) => s + (si.cost ?? 0));

  /// Grand total = treatment costs + sitting costs.
  double get totalCost => totalTreatmentCost + totalSittingsCost;

  double get balance => totalCost - totalPaid;

  /// Sittings belonging to a specific treatment plan.
  List<Sitting> sittingsForTreatment(String treatmentPlanId) =>
      sittings.where((s) => s.treatmentPlanId == treatmentPlanId).toList();

  /// Prescriptions belonging to a specific treatment plan.
  List<Prescription> prescriptionsForTreatment(String treatmentPlanId) =>
      prescriptions
          .where((p) => p.treatmentPlanId == treatmentPlanId)
          .toList();

  VisitDetail copyWith({
    Visit? visit,
    String? doctorName,
    String? patientName,
    List<TreatmentPlan>? treatments,
    List<Sitting>? sittings,
    List<Prescription>? prescriptions,
    List<Payment>? payments,
  }) =>
      VisitDetail(
        visit: visit ?? this.visit,
        doctorName: doctorName ?? this.doctorName,
        patientName: patientName ?? this.patientName,
        treatments: treatments ?? this.treatments,
        sittings: sittings ?? this.sittings,
        prescriptions: prescriptions ?? this.prescriptions,
        payments: payments ?? this.payments,
      );

  /// Parse from Supabase nested select response.
  factory VisitDetail.fromJson(Map<String, dynamic> json) {
    final visit = Visit.fromJson(json);

    // Doctor name from joined doctors table
    final doctorJson = json['doctors'] as Map<String, dynamic>?;
    final fName = doctorJson?['first_name'] as String? ?? '';
    final lName = doctorJson?['last_name'] as String? ?? '';
    final rawName = '$fName $lName'.trim();
    String doctorName = 'Unknown Doctor';
    if (rawName.isNotEmpty) {
      doctorName = rawName.toLowerCase().startsWith('dr.') ? rawName : 'Dr. $rawName';
    }

    // Patient name from joined patients table
    final patientJson = json['patients'] as Map<String, dynamic>?;
    final pfName = patientJson?['first_name'] as String? ?? '';
    final plName = patientJson?['last_name'] as String? ?? '';
    final patientName = '$pfName $plName'.trim();

    // Treatment plans array
    final treatmentsList = (json['treatment_plans'] as List? ?? [])
        .map((t) => TreatmentPlan.fromJson(t as Map<String, dynamic>))
        .toList();

    // Sittings — nested under each treatment_plan in the Supabase response
    final sittingsList = <Sitting>[];
    for (final tp in (json['treatment_plans'] as List? ?? [])) {
      final tpMap = tp as Map<String, dynamic>;
      for (final s in (tpMap['sittings'] as List? ?? [])) {
        sittingsList.add(Sitting.fromJson(s as Map<String, dynamic>));
      }
    }

    // Prescriptions
    final prescriptionsList = (json['prescriptions'] as List? ?? [])
        .map((p) => Prescription.fromJson(p as Map<String, dynamic>))
        .toList();

    // Payments
    final paymentsList = (json['payments'] as List? ?? [])
        .map((p) => Payment.fromJson(p as Map<String, dynamic>))
        .toList();

    return VisitDetail(
      visit: visit,
      doctorName: doctorName,
      patientName: patientName,
      treatments: treatmentsList,
      sittings: sittingsList,
      prescriptions: prescriptionsList,
      payments: paymentsList,
    );
  }
}
