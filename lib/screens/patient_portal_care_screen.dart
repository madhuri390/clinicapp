import 'package:flutter/material.dart';

import '../services/patient_session.dart';
import 'patient_details_screen.dart';

/// Patient tab: same as doctor patient view without new consultation (handled in [PatientDetailsScreen]).
class PatientPortalCareScreen extends StatelessWidget {
  const PatientPortalCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = PatientSession.portalPatientId;
    final name = PatientSession.portalPatientName ?? 'Patient';
    if (id == null) {
      return const Scaffold(
        body: Center(child: Text('Could not load your profile.')),
      );
    }
    return PatientDetailsScreen(
      patientId: id,
      patientName: name,
      patientPortalMode: true,
    );
  }
}
