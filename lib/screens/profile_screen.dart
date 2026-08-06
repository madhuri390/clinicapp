import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/staff_model.dart';
import '../services/staff_service.dart';
import '../services/auth_service.dart';
import '../services/app_role_service.dart';
import 'login_screen.dart';
import 'main_shell.dart';
import 'manage_staff_screen.dart';
import '../theme/app_tokens.dart';

// ── Reference design colours ──────────────────────────────────────────────
const _primary = AppTokens.accent;
const _primaryDk = AppTokens.accentDark;
const _muted = AppTokens.body;
const _dark = AppTokens.ink;
const _slate600 = AppTokens.body;
const _red50 = AppTokens.dangerSoft;
const _red400 = AppTokens.danger;
const _red500 = AppTokens.danger;


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Staff? _me;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = AuthService.currentUser?.id;
      if (uid == null) return;
      
      final staffList = await StaffService.instance.getStaff();
      for (final s in staffList) {
        if (s.authUserId == uid) {
          if (mounted) setState(() => _me = s);
          break;
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
    
    // Fallback if _me not loaded yet
    String name = 'Staff Member';
    String initials = 'ST';
    String role = 'Clinician';
    if (_me != null) {
      final n = _me!.name.trim();
      name = _me!.displayName;
      initials = n.isEmpty ? '?' : n.substring(0, 1).toUpperCase();
      role = _me!.role;
    }

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
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    MainShell.of(context)?.setTabIndex(0);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                ),
              ),
              // Gradient avatar circle
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTokens.accent, _primaryDk],
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
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
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
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: GoogleFonts.plusJakartaSans(
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
          const _SectionTitle(icon: Icons.badge_outlined, label: 'Contact details'),
          const SizedBox(height: 14),
          if (_me?.phone != null && _me!.phone!.isNotEmpty) ...[
            _ContactRow(icon: Icons.phone_outlined, value: _me!.phone!),
            const SizedBox(height: 10),
          ],
          if (_me?.email != null && _me!.email!.isNotEmpty) ...[
            _ContactRow(
              icon: Icons.email_outlined,
              value: _me!.email!,
            ),
            const SizedBox(height: 10),
          ],
          const _ContactRow(
            icon: Icons.location_on_outlined,
            value: 'Kokapet, Hyderabad',
          ),
          const SizedBox(height: 10),
          const _ContactRow(
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
            icon: Icons.people_outline,
            title: 'Manage Staff',
            subtitle: 'Add and manage staff members',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageStaffScreen()),
              );
            },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.plusJakartaSans(color: _slate600),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: _slate600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: GoogleFonts.plusJakartaSans()),
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
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _muted),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted),
          ),
        ],
      ),
    );
  }

  static Widget _divider() =>
      Divider(height: 1, color: AppTokens.subtle);
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTokens.subtle),
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
            style: GoogleFonts.plusJakartaSans(
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
            style: GoogleFonts.plusJakartaSans(
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? _red400 : _dark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
