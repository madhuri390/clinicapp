import 'payment_model.dart';
import 'prescription_model.dart';
import 'sitting_model.dart';
import 'treatment_plan_model.dart';
import 'visit_model.dart';

/// A fully-loaded visit with all nested relationships.
/// Populated by [VisitDetailRepository.getForPatient].
class VisitDetail {
  const VisitDetail({
    required this.visit,
    required this.doctorName,
    required this.treatments,
    required this.sittings,
    required this.prescriptions,
    required this.payments,
  });

  final Visit visit;
  final String doctorName;
  final List<TreatmentPlan> treatments;
  final List<Sitting> sittings;
  final List<Prescription> prescriptions;
  final List<Payment> payments;

  double get totalPaid =>
      payments.fold(0, (s, p) => s + p.amountPaid);

  double get totalCost {
    double c = 0;
    for (final s in sittings) {
      c += s.cost ?? 0;
    }
    for (final rx in prescriptions) {
      c += rx.price ?? 0;
    }
    return c;
  }

  double get balance => totalCost - totalPaid;

  List<Sitting> sittingsForTreatment(String treatmentPlanId) =>
      sittings.where((s) => s.treatmentPlanId == treatmentPlanId).toList();

  List<Prescription> prescriptionsForTreatment(String treatmentPlanId) =>
      prescriptions
          .where((p) => p.treatmentPlanId == treatmentPlanId)
          .toList();

  /// Returns a copy with refreshed payments/sittings/prescriptions after
  /// a mutation without re-fetching the whole list.
  VisitDetail copyWith({
    Visit? visit,
    String? doctorName,
    List<TreatmentPlan>? treatments,
    List<Sitting>? sittings,
    List<Prescription>? prescriptions,
    List<Payment>? payments,
  }) =>
      VisitDetail(
        visit: visit ?? this.visit,
        doctorName: doctorName ?? this.doctorName,
        treatments: treatments ?? this.treatments,
        sittings: sittings ?? this.sittings,
        prescriptions: prescriptions ?? this.prescriptions,
        payments: payments ?? this.payments,
      );

  /// Parse from Supabase nested select response.
  factory VisitDetail.fromJson(Map<String, dynamic> json) {
    final visit = Visit.fromJson(json);

    // doctor name from joined doctors table
    final doctorJson = json['doctors'] as Map<String, dynamic>?;
    final doctorName = doctorJson != null
        ? 'Dr. ${doctorJson['first_name'] ?? ''} ${doctorJson['last_name'] ?? ''}'.trim()
        : 'Unknown Doctor';

    // treatment_plans array
    final treatmentsList = (json['treatment_plans'] as List? ?? [])
        .map((t) => TreatmentPlan.fromJson(t as Map<String, dynamic>))
        .toList();

    // sittings — nested under each treatment_plan
    final sittingsList = <Sitting>[];
    for (final tp in (json['treatment_plans'] as List? ?? [])) {
      final tpMap = tp as Map<String, dynamic>;
      for (final s in (tpMap['sittings'] as List? ?? [])) {
        sittingsList.add(Sitting.fromJson(s as Map<String, dynamic>));
      }
    }

    // prescriptions
    final prescriptionsList = (json['prescriptions'] as List? ?? [])
        .map((p) => Prescription.fromJson(p as Map<String, dynamic>))
        .toList();

    // payments
    final paymentsList = (json['payments'] as List? ?? [])
        .map((p) => Payment.fromJson(p as Map<String, dynamic>))
        .toList();

    return VisitDetail(
      visit: visit,
      doctorName: doctorName,
      treatments: treatmentsList,
      sittings: sittingsList,
      prescriptions: prescriptionsList,
      payments: paymentsList,
    );
  }
}
