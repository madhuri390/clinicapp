import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/app_role_service.dart';
import 'login_screen.dart';

// ── Reference design colours ──────────────────────────────────────────────
const _primary = Color(0xFF0D8DC4);
const _primaryDk = Color(0xFF0A719D);
const _bg = Color(0xFFF9FAFE);
const _muted = Color(0xFF5B6E8C);
const _dark = Color(0xFF0F172A);
const _slate200 = Color(0xFFE2E8F0);
const _slate600 = Color(0xFF475569);
const _red50 = Color(0xFFFEF2F2);
const _red400 = Color(0xFFEF4444);
const _red500 = Color(0xFFEF4444);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildContactCard(),
                const SizedBox(height: 16),
                _buildSettingsCard(context),
                const SizedBox(height: 16),
                _buildAccountCard(context),
                const SizedBox(height: 24),
                _buildAppInfo(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryDk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Gradient avatar circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF28A0D4), _primaryDk],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Amanda Foster',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'General Dentist · Prodontics Kokapet',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Contact card ────────────────────────────────────────────────────────

  Widget _buildContactCard() {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.badge_outlined, label: 'Contact details'),
          const SizedBox(height: 14),
          _ContactRow(icon: Icons.phone_outlined, value: '+91 98765 43210'),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.email_outlined,
            value: 'dr.foster@prodontics.in',
          ),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.location_on_outlined,
            value: 'Kokapet, Hyderabad',
          ),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.calendar_today_outlined,
            value: 'Joined: Jan 2020',
            muted: true,
          ),
        ],
      ),
    );
  }

  // ── Settings card ───────────────────────────────────────────────────────

  Widget _buildSettingsCard(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.settings_outlined, label: 'Settings'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: 'General Settings',
            subtitle: 'App preferences and configurations',
            onTap: () => _toast(context, 'General Settings coming soon'),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.people_outline,
            title: 'Manage Staff',
            subtitle: 'Add and manage staff members',
            onTap: () => _toast(context, 'Manage Staff coming soon'),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Roles & Permissions',
            subtitle: 'Manage user roles and access',
            onTap: () => _toast(context, 'Roles & Permissions coming soon'),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            onTap: () => _toast(context, 'Notifications coming soon'),
          ),
        ],
      ),
    );
  }

  // ── Account card ────────────────────────────────────────────────────────

  Widget _buildAccountCard(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.person_outline, label: 'Account'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Account Settings',
            subtitle: 'Update profile and password',
            onTap: () => _toast(context, 'Account Settings coming soon'),
          ),
          _divider(),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(color: _slate600),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: _slate600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AuthService.signOut();
    await AppRoleService.setRole(AppRole.staff);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Prodontics Dental Management',
            style: GoogleFonts.lato(fontSize: 13, color: _muted),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.lato(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  static Widget _divider() =>
      Divider(height: 1, color: const Color(0xFFEFF3F8));

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

// ── Shared components ────────────────────────────────────────────────────

/// Card with 24-radius, subtle shadow and border (matches reference 28px style).
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFF3F8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section title with blue left-border accent.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: _primary, width: 3)),
      ),
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact info row — blue icon, label + value.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    this.muted = false,
  });
  final IconData icon;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: muted ? _muted : _dark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Settings / menu list tile.
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
    final color = isDestructive ? _red400 : _primary;

    return Material(
      color: isDestructive ? _red50 : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? _red400 : _dark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.lato(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDestructive ? _red400 : _slate200,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
