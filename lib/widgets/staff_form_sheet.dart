import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/staff_model.dart';

class StaffFormSheet extends StatefulWidget {
  const StaffFormSheet({super.key, this.staff, required this.onSave});

  final Staff? staff;
  final ValueChanged<Staff> onSave;

  @override
  State<StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<StaffFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  String _startTimeStr = '09:00:00';
  String _endTimeStr = '17:00:00';
  String _selectedRole = 'General Dentist';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.staff?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.staff?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.staff?.email ?? '');

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
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF0D8DC4),
              ),
        ),
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
    // Format "09:00:00" to "09:00 AM" just for UI display
    String displayTime = timeStr;
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        // using simple mapping since we can't easily access context.format
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
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            displayTime,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
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
                  widget.staff == null ? 'Add Staff (Doctor)' : 'Edit Staff (Doctor)',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Role / Specialisation'),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: [
                      'General Dentist',
                      'Endodontist',
                      'Orthodontist',
                      'Periodontist',
                      'Prosthodontist',
                      'Pediatric Dentist',
                      'Oral Surgeon',
                    ].map((role) => DropdownMenuItem(value: role, child: Text(role, style: GoogleFonts.inter(fontSize: 14)))).toList(),
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
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Full Name *'),
                  _buildTextField(_nameCtrl, 'Staff Name'),
                  const SizedBox(height: 16),
                  _buildLabel('Phone Number'),
                  _buildTextField(_phoneCtrl, '+91 98765 43210', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildLabel('Email Address'),
                  _buildTextField(_emailCtrl, 'doctor@clinic.com', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Standard Working Hours',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                      onPressed: () {
                        if (_nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter staff name')),
                          );
                          return;
                        }
                        
                        widget.onSave(
                          Staff(
                            id: widget.staff?.id ?? '',
                            name: _nameCtrl.text.trim(),
                            role: _selectedRole,
                            phone: _phoneCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            workStartTime: _startTimeStr,
                            workEndTime: _endTimeStr,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D8DC4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save Details',
                        style: GoogleFonts.inter(
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
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0D8DC4)),
        ),
      ),
    );
  }
}
