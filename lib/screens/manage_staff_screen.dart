import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/staff_model.dart';
import '../services/auth_service.dart';
import '../services/staff_service.dart';
import '../widgets/staff_form_sheet.dart';
import '../theme/app_tokens.dart';

class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  final _service = StaffService.instance;
  
  bool _isLoading = true;
  List<Staff> _staffList = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getStaff();
      setState(() {
        _staffList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load staff: $e')),
        );
      }
    }
  }

  void _showStaffForm([Staff? staff]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StaffFormSheet(
        staff: staff,
        onSave: (updatedStaff, password) async {
          setState(() => _isLoading = true);
          try {
            if (updatedStaff.id.isEmpty) {
              final email = updatedStaff.email;
              final username = updatedStaff.username;
              final authEmail = (email != null && email.isNotEmpty) ? email : '$username@prodontics.local';

              // Phone is deliberately not sent to auth: auth.users.phone is
              // unique project-wide, and clinic numbers are shared across
              // staff and placeholder patient records. Nothing signs in by
              // phone, so the number lives in doctors.phone only.
              final authUserId = await AuthService.adminCreateUser(
                email: authEmail,
                password: password!, // Form validation ensures this is not null for new staff
              );

              // The auth user exists before the doctors row does, so anything
              // the insert rejects would strand it and make every retry fail
              // with email_exists. Undo it before surfacing the real error.
              try {
                final finalStaff = updatedStaff.copyWith(authUserId: authUserId);
                await _service.createStaff(finalStaff);
              } catch (_) {
                try {
                  await AuthService.adminDeleteUser(authUserId);
                } catch (_) {
                  // Rollback failed too — report the original error, which is
                  // the one that explains why saving didn't work.
                }
                rethrow;
              }
            } else {
              final email = updatedStaff.email;
              final username = updatedStaff.username;
              final authEmail = (email != null && email.isNotEmpty) ? email : '$username@prodontics.local';

              if (updatedStaff.authUserId != null) {
                // Phone intentionally omitted — see the create branch above.
                await AuthService.adminUpdateUser(
                  userId: updatedStaff.authUserId!,
                  email: authEmail,
                  password: (password != null && password.isNotEmpty) ? password : null,
                );
              }
              await _service.updateStaff(updatedStaff);
            }
            await _loadStaff();
            if (mounted) Navigator.pop(context); // close sheet only on success
          } catch (e) {
            setState(() => _isLoading = false);
            if (mounted) {
              var msg = e.toString();
              if (msg.startsWith('Exception: ')) msg = msg.replaceFirst('Exception: ', '');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save staff: $msg')),
              );
            }
          }
        },
      ),
    );
  }

  void _confirmDelete(Staff staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Staff', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to remove ${staff.name}?\n\n'
          'Their login will be deleted and they will no longer be able to '
          'sign in. Past visits and prescriptions are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                // Revoke the login first. Deleting only the doctors row left
                // the auth user behind, and an orphaned account could still
                // sign in — and saw every patient, because the patient list
                // has no doctor to scope itself to.
                if (staff.authUserId != null) {
                  await AuthService.adminDeleteUser(staff.authUserId!);
                }
                await _service.deleteStaff(staff.id);
                await _loadStaff();
              } catch (e) {
                setState(() => _isLoading = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete staff: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Manage Staff', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staffList.isEmpty
              ? _buildEmptyState()
              : _buildList(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showStaffForm(),
        backgroundColor: AppTokens.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Staff',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppTokens.hairline),
          const SizedBox(height: 16),
          Text(
            'No staff members found',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppTokens.body),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first doctor.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTokens.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staffList.length,
      itemBuilder: (context, index) {
        final staff = _staffList[index];
        return _buildStaffCard(staff);
      },
    );
  }

  Widget _buildStaffCard(Staff staff) {
    // Generate a mini schedule summary
    String schedulePreview = 'Schedule not set';
    if (staff.workStartTime != null && staff.workEndTime != null) {
      schedulePreview = 'Standard Hours: ${staff.workStartTime!.substring(0, 5)} - ${staff.workEndTime!.substring(0, 5)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTokens.hairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTokens.subtle,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      staff.name.isNotEmpty ? staff.name.substring(0, 1).toUpperCase() : '?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTokens.accentSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          staff.role,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTokens.accentDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (staff.phone != null && staff.phone!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppTokens.muted),
                            const SizedBox(width: 6),
                            Text(
                              staff.phone!,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTokens.body),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppTokens.muted),
                          const SizedBox(width: 6),
                          Text(
                            schedulePreview,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTokens.body),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppTokens.muted),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                  offset: const Offset(0, 40),
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  onSelected: (val) {
                    if (val == 'edit') _showStaffForm(staff);
                    if (val == 'delete') _confirmDelete(staff);
                  },
                  itemBuilder: (context) {
                    final isCurrentUser = staff.authUserId != null && 
                                          AuthService.currentUser != null &&
                                          staff.authUserId == AuthService.currentUser!.id;
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 18, color: AppTokens.body),
                            const SizedBox(width: 10),
                            Text('Edit details', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTokens.ink)),
                          ],
                        ),
                      ),
                      if (!isCurrentUser)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline, size: 18, color: AppTokens.danger),
                              const SizedBox(width: 10),
                              Text('Delete staff', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTokens.danger)),
                            ],
                          ),
                        ),
                    ];
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
