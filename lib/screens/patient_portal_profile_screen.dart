import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../repositories/patient_repository.dart';
import '../services/auth_service.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/ui_kit.dart';
import 'login_screen.dart';
import 'patient_form_screen.dart';
import '../theme/app_tokens.dart';

class PatientPortalProfileScreen extends StatefulWidget {
  const PatientPortalProfileScreen({super.key});

  @override
  State<PatientPortalProfileScreen> createState() => _PatientPortalProfileScreenState();
}

class _PatientPortalProfileScreenState extends State<PatientPortalProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final patient = PatientSession.linked;
    final displayName = PatientSession.resolvedPortalDisplayName();
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.paddingOf(context).top + 18, 20, 8),
                child: AnimatedEntrance(
                  child: Text('Profile',
                      style: PatientPortalTheme.displayLarge(context)),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedEntrance(
                    index: 1,
                    child: _buildProfileHeader(context, displayName, initials,
                        patient?.phone, patient?.email),
                  ),
                  const SizedBox(height: 20),
                  AnimatedEntrance(
                    index: 2,
                    child: _buildSettingsSection(context),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String initials, String? phone, String? email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: PatientPortalTheme.glassDecoration(context),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: PatientPortalTheme.accentGradient,
              boxShadow: PatientPortalTheme.glow(PatientPortalTheme.brightSky),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: PatientPortalTheme.titleMedium(context),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: PatientPortalTheme.body(context),
                  ),
                ],
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: PatientPortalTheme.body(context),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: PatientPortalTheme.glassDecoration(context),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.edit_outlined,
            title: 'Edit Personal Details',
            subtitle: 'Update your contact information',
            onTap: () async {
              final patient = PatientSession.linked;
              if (patient == null) return;
              
              final didUpdate = await Navigator.of(context).push<bool>(
                FadeSlideRoute<bool>(
                  page: PatientFormScreen(
                    initialPatient: patient,
                    appBarTitle: 'Edit Personal Details',
                  ),
                ),
              );
              
              if (didUpdate == true) {
                // Fetch updated patient and refresh session
                final repo = PatientRepository();
                final updated = await repo.getById(patient.id);
                if (updated != null) {
                  final name = updated.fullName.isNotEmpty ? updated.fullName : updated.firstName;
                  PatientSession.setPortal(
                    patientId: updated.id,
                    displayName: name,
                    patient: updated,
                  );
                  if (mounted) setState(() {});
                }
              }
            },
          ),
          Divider(height: 1, color: AppTokens.muted.withValues(alpha: 0.1)),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            isDestructive: true,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: PatientPortalTheme.titleMedium(context),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: PatientPortalTheme.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: PatientPortalTheme.label(context)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await AuthService.signOut();
    PatientSession.clear();
    
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppTokens.danger : PatientPortalTheme.navyBlue;
    final badgeGradient = isDestructive
        ? const LinearGradient(colors: [AppTokens.danger, AppTokens.danger])
        : PatientPortalTheme.buttonGradient;
    final badgeGlow =
        isDestructive ? AppTokens.danger : PatientPortalTheme.brightSky;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            HeroIconBadge(
              icon: icon,
              size: 44,
              gradient: badgeGradient,
              glowColor: badgeGlow,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PatientPortalTheme.titleMedium(context).copyWith(
                      color: isDestructive ? color : PatientPortalTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: PatientPortalTheme.body(context).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
