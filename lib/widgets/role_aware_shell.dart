import 'package:flutter/material.dart';

import '../services/app_role_service.dart';
import '../screens/main_shell.dart';
import '../screens/patient_main_shell.dart';

/// Routes to staff [MainShell] or [PatientMainShell] from persisted role.
class RoleAwareShell extends StatelessWidget {
  const RoleAwareShell({super.key});

  @override
  Widget build(BuildContext context) {
    return AppRoleService.isPatient
        ? const PatientMainShell()
        : const MainShell();
  }
}
