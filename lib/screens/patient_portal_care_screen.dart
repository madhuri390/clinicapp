import 'package:flutter/material.dart';

import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/ui_kit.dart';
import 'patient_details_screen.dart';

/// Patient tab: same as doctor patient view without new consultation (handled in [PatientDetailsScreen]).
class PatientPortalCareScreen extends StatelessWidget {
  const PatientPortalCareScreen({
    super.key,
    required this.careNavSignal,
    required this.careTargetTabResolver,
  });

  final ValueNotifier<int> careNavSignal;
  final int Function() careTargetTabResolver;

  @override
  Widget build(BuildContext context) {
    final id = PatientSession.portalPatientId;
    final name = PatientSession.portalPatientName ?? 'Patient';
    if (id == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: AppGradientBackground(
          child: Center(
            child: Text(
              'Could not load your profile.',
              style: PatientPortalTheme.body(context),
            ),
          ),
        ),
      );
    }
    return PatientDetailsScreen(
      patientId: id,
      patientName: name,
      patientPortalMode: true,
      careNavSignal: careNavSignal,
      careTargetTabResolver: careTargetTabResolver,
    );
  }
}
