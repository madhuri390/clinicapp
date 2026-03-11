import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/visit_model.dart';
import '../services/local_store.dart';
import 'patient_details_consultation_card.dart';

class HistoryTabPlaceholder extends StatelessWidget {
  const HistoryTabPlaceholder({
    super.key,
    required this.onRefresh,
    required this.onDeleteVisit,
  });

  final VoidCallback onRefresh;
  final ValueChanged<Visit> onDeleteVisit;

  @override
  Widget build(BuildContext context) {
    final store = LocalStore.instance;
    final historyVisits = store.getVisitsForPatient('_global_');

    if (historyVisits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No past consultations',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: historyVisits.length,
      itemBuilder: (context, index) {
        final visit = historyVisits[index];
        final visitTreatments =
            store.getTreatmentsForVisits([visit.id]).toList();
        final visitPrescriptions =
            store.getPrescriptionsForVisits([visit.id]).toList();
        final visitSittings = store.getSittingsForVisits([visit.id]).toList();
        final visitPayments = store.getPaymentsForVisits([visit.id]).toList();

        return ConsultationCard(
          visit: visit,
          treatments: visitTreatments,
          prescriptions: visitPrescriptions,
          sittings: visitSittings,
          payments: visitPayments,
          isOngoing: false,
          onRefresh: onRefresh,
          onEditVisit: (_) {},
          onDeleteVisit: onDeleteVisit,
        );
      },
    );
  }
}

