import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';
import '../services/local_store.dart';
import 'patient_details_consultation_card.dart';

class OngoingTabPlaceholder extends StatelessWidget {
  const OngoingTabPlaceholder({
    super.key,
    required this.visits,
    required this.treatments,
    required this.prescriptions,
    required this.payments,
    required this.onRefresh,
    this.onComplete,
    required this.onEditVisit,
  });

  final List<Visit> visits;
  final List<TreatmentPlan> treatments;
  final List<Prescription> prescriptions;
  final List<Payment> payments;
  final VoidCallback onRefresh;
  final VoidCallback? onComplete;
  final void Function(Visit) onEditVisit;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Center(
        child: Text(
          'No ongoing consultations',
          style: GoogleFonts.poppins(color: Colors.black54),
        ),
      );
    }

    final store = LocalStore.instance;
    final ongoingTreatments = [
      ...treatments,
      ...store.getTreatmentsForVisits(visits.map((v) => v.id).toList()),
    ];
    final ongoingPrescriptions = [
      ...prescriptions,
      ...store.getPrescriptionsForVisits(visits.map((v) => v.id).toList()),
    ];
    final ongoingSittings = store.getSittingsForVisits(
      visits.map((v) => v.id).toList(),
    );

    final seenTreatments = <String>{};
    final uniqueTreatments = ongoingTreatments
        .where((t) => seenTreatments.add(t.id))
        .toList();
    final seenPrescriptions = <String>{};
    final uniquePrescriptions = ongoingPrescriptions
        .where((p) => seenPrescriptions.add(p.id))
        .toList();

    final ongoingVisits = visits.where((v) => v.status == 'ongoing').toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ongoingVisits.length,
      itemBuilder: (context, index) {
        final visit = ongoingVisits[index];
        final visitPayments = [
          ...payments.where((p) => p.visitId == visit.id),
          ...store.getPaymentsForVisits([visit.id]),
        ];
        final seenPayments = <String>{};
        final uniqueVisitPayments = visitPayments
            .where((p) => seenPayments.add(p.id))
            .toList();

        return ConsultationCard(
          visit: visit,
          treatments: uniqueTreatments
              .where((t) => t.visitId == visit.id)
              .toList(),
          prescriptions: uniquePrescriptions
              .where((p) => p.visitId == visit.id)
              .toList(),
          sittings: ongoingSittings
              .where((s) => s.visitId == visit.id)
              .toList(),
          payments: uniqueVisitPayments,
          isOngoing: true,
          onRefresh: onRefresh,
          onComplete: onComplete,
          onEditVisit: onEditVisit,
        );
      },
    );
  }
}
