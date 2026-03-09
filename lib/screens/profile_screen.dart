import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reference colors (Tailwind)
const _blue600 = Color(0xFF2563EB);
const _blue500 = Color(0xFF3B82F6);
const _blue400 = Color(0xFF60A5FA);
const _blue100 = Color(0xFFDBEAFE);
const _slate50 = Color(0xFFF8FAFC);
const _slate200 = Color(0xFFE2E8F0);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate900 = Color(0xFF0F172A);
const _green600 = Color(0xFF16A34A);
const _red500 = Color(0xFFEF4444);
const _red50 = Color(0xFFFEF2F2);

/// Profile screen matching PatientTrackingVersion4/src/app/components/profile.tsx
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _totalRevenue = 6850;
  static const _thisMonthRevenue = 2340;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildContactInfo(context),
                const SizedBox(height: 16),
                _buildRevenueStats(context),
                const SizedBox(height: 16),
                _buildSettingsMenu(context),
                const SizedBox(height: 16),
                _buildAccountActions(context),
                const SizedBox(height: 24),
                _buildAppInfo(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      color: _blue600,
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 20),
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
          const SizedBox(height: 8),
          Text(
            'Profile',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _blue500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _blue400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Amanda Foster',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Dental Surgeon',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _blue100,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _slate900,
            ),
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.mail_outline,
            label: 'Email',
            value: 'amanda.foster@dentalcare.com',
          ),
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+1 555-0100',
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: _green600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Revenue Statistics',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Revenue',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _slate500,
                      ),
                    ),
                    Text(
                      '\$${ProfileScreen._totalRevenue}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _slate900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _slate500,
                      ),
                    ),
                    Text(
                      '\$${ProfileScreen._thisMonthRevenue}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _green600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View Detailed Report'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              children: [
                Text(
                  'View Detailed Report',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _blue600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: _blue600, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.settings,
            title: 'General Settings',
            subtitle: 'App preferences and configurations',
            onTap: () => _showComingSoon(context, 'General Settings'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.people,
            title: 'Manage Staff',
            subtitle: 'Add and manage staff members',
            onTap: () => _showComingSoon(context, 'Manage Staff'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Roles & Permissions',
            subtitle: 'Manage user roles and access',
            onTap: () => _showComingSoon(context, 'Roles & Permissions'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            onTap: () => _showComingSoon(context, 'Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.person,
            title: 'Account Settings',
            subtitle: 'Update profile and password',
            onTap: () => _showComingSoon(context, 'Account Settings'),
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            isDestructive: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'Dental Care Management System',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _slate500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _slate500,
            ),
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _slate400, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _slate500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _slate900,
                ),
              ),
            ],
          ),
        ),
      ],
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
    final color = isDestructive ? _red500 : _slate600;
    final subtitleColor = isDestructive ? _red500 : _slate500;

    return Material(
      color: isDestructive ? _red50 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? _red500 : _slate900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _slate400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
