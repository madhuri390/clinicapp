import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/visit_model.dart';
import '../services/local_store.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/patient_details_profile_tab.dart';
import '../widgets/patient_portal_logo.dart';

/// Lists prescriptions linked to the signed-in patient's visits (local + seeded data).
class PatientPrescriptionsScreen extends StatelessWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = PatientSession.portalPatientId;
    if (patientId == null) {
      return Scaffold(
        backgroundColor: PatientPortalTheme.surface,
        appBar: AppBar(
          title: Text(
            'Prescriptions',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Text(
            'No patient context',
            style: PatientPortalTheme.body(context),
          ),
        ),
      );
    }

    final store = LocalStore.instance;
    final visits = store.getVisitsForPatient(patientId);
    final visitIds = visits.map((v) => v.id).toList();
    final prescriptions = store.getPrescriptionsForVisits(visitIds);

    return Scaffold(
      backgroundColor: PatientPortalTheme.surface,
      appBar: AppBar(
        backgroundColor: PatientPortalTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: PatientPortalTheme.navyBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const PatientPortalLogo(height: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Prescriptions',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: PatientPortalTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
      body: prescriptions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_information_outlined,
                      size: 56,
                      color: PatientPortalTheme.skyBlue.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No prescriptions on file yet.',
                      textAlign: TextAlign.center,
                      style: PatientPortalTheme.body(context),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: prescriptions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final p = prescriptions[i];
                Visit? visit;
                for (final v in visits) {
                  if (v.id == p.visitId) {
                    visit = v;
                    break;
                  }
                }
                final dateStr =
                    visit != null ? ProfileTab.formatDate(visit.visitDate) : '';
                return Container(
                  decoration: PatientPortalTheme.cardDecoration(context),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: PatientPortalTheme.accentGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medication_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.medicineName ?? 'Medicine',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: PatientPortalTheme.textPrimary,
                                  ),
                                ),
                                if (p.dosage != null && p.dosage!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      p.dosage!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: PatientPortalTheme.skyBlue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (p.instructions != null &&
                          p.instructions!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          p.instructions!,
                          style: PatientPortalTheme.body(context),
                        ),
                      ],
                      if (dateStr.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Visit: $dateStr',
                          style: PatientPortalTheme.label(context),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
