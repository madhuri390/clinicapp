import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/staff_model.dart';
import '../theme/app_tokens.dart';

class StaffFormSheet extends StatefulWidget {
  const StaffFormSheet({super.key, this.staff, required this.onSave});

  final Staff? staff;

  /// Awaited so the button can show progress and stay disabled until the
  /// save resolves — creating staff makes two round trips (auth user, then
  /// doctors row) and a double tap would create a duplicate auth user.
  final Future<void> Function(Staff staff, String? password) onSave;

  @override
  State<StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<StaffFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;

  String _startTimeStr = '09:00:00';
  String _endTimeStr = '17:00:00';
  String _selectedRole = 'General Dentist';
  bool _obscurePassword = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.staff?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.staff?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.staff?.email ?? '');
    _usernameCtrl = TextEditingController(text: widget.staff?.username ?? '');
    _passwordCtrl = TextEditingController();

    if (widget.staff?.role != null) {
      _selectedRole = widget.staff!.role;
    }

    if (widget.staff?.workStartTime != null) {
      _startTimeStr = widget.staff!.workStartTime!;
    }
    if (widget.staff?.workEndTime != null) {
      _endTimeStr = widget.staff!.workEndTime!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final currentStr = isStart ? _startTimeStr : _endTimeStr;
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTokens.accent)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        final timeStr =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
        if (isStart) {
          _startTimeStr = timeStr;
        } else {
          _endTimeStr = timeStr;
        }
      });
    }
  }

  Widget _buildTimeField(String timeStr, VoidCallback onTap) {
    String displayTime = timeStr;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        final hour = tod.hour == 0 ? 12 : (tod.hour > 12 ? tod.hour - 12 : tod.hour);
        final minute = tod.minute.toString().padLeft(2, '0');
        final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
        displayTime = '${hour.toString().padLeft(2, '0')}:$minute $period';
      }
    } catch (_) {}

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTokens.hairline),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            displayTime,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTokens.ink),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTokens.hairline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.staff == null ? 'Add Staff' : 'Edit Staff',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTokens.muted),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Role / Specialisation'),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items:
                          [
                                'General Dentist',
                                'Endodontist',
                                'Orthodontist',
                                'Periodontist',
                                'Prosthodontist',
                                'Pediatric Dentist',
                                'Oral Surgeon',
                                Staff.receptionistRole,
                              ]
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedRole = val);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTokens.hairline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTokens.hairline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Username *'),
                    _buildTextField(
                      _usernameCtrl,
                      'unique_username',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]')),
                      ],
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Username is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(
                      widget.staff == null
                          ? 'Password *'
                          : 'Password (leave blank to keep current)',
                    ),
                    _buildTextField(
                      _passwordCtrl,
                      'Min 6 chars',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppTokens.muted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        final val = v?.trim() ?? '';
                        if (widget.staff == null && val.isEmpty) {
                          return 'Password is required for new staff';
                        }
                        if (val.isNotEmpty && val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Full Name *'),
                    _buildTextField(
                      _nameCtrl,
                      'Staff Name',
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Phone Number (Optional)'),
                    _buildTextField(
                      _phoneCtrl,
                      '+91 98765 43210',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Email Address (Optional)'),
                    _buildTextField(
                      _emailCtrl,
                      'doctor@clinic.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Standard Working Hours',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Start Time'),
                              _buildTimeField(_startTimeStr, () => _pickTime(context, true)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('End Time'),
                              _buildTimeField(_endTimeStr, () => _pickTime(context, false)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                setState(() => _saving = true);
                                try {
                                  await widget.onSave(
                                    Staff(
                                      id: widget.staff?.id ?? '',
                                      name: _nameCtrl.text.trim(),
                                      role: _selectedRole,
                                      phone: _phoneCtrl.text.trim(),
                                      email: _emailCtrl.text.trim(),
                                      username: _usernameCtrl.text.trim(),
                                      workStartTime: _startTimeStr,
                                      workEndTime: _endTimeStr,
                                      authUserId: widget.staff?.authUserId,
                                    ),
                                    _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
                                  );
                                } finally {
                                  // A successful save pops this sheet, so only
                                  // clear the flag if we are still on screen.
                                  if (mounted) setState(() => _saving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.accent,
                          foregroundColor: Colors.white,
                          // Keep the accent while saving so the white spinner
                          // stays legible against the disabled button.
                          disabledBackgroundColor: AppTokens.accent.withValues(alpha: 0.7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                'Save Details',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTokens.body,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    TextInputType? keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: AppTokens.muted, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTokens.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTokens.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTokens.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
