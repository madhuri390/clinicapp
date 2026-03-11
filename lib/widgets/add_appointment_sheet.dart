import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../services/appointment_store.dart';
import '../services/notification_service.dart';

// Colors
const _blue600 = Color(0xFF2563EB);
const _blue100 = Color(0xFFDBEAFE);
const _slate50 = Color(0xFFF8FAFC);
const _slate200 = Color(0xFFE2E8F0);
const _slate300 = Color(0xFFCBD5E1);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);

/// Common dental procedure types.
const _procedureTypes = [
  'General Checkup',
  'Teeth Cleaning',
  'Cavity Filling',
  'Root Canal',
  'Crown Placement',
  'Bridge Work',
  'Teeth Whitening',
  'Wisdom Tooth Extraction',
  'Dental Implant',
  'Orthodontics Consultation',
  'X-Ray / CBCT Scan',
  'Dental Veneer',
  'Gum Treatment',
  'Other',
];

/// Duration options in minutes.
const _durationOptions = [
  (label: '30 min', value: 30),
  (label: '1 hour', value: 60),
  (label: '1.5 hours', value: 90),
  (label: '2 hours', value: 120),
];

/// All available 30-min time slots.
const _allTimeSlots = [
  '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
  '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  '18:00', '18:30',
];

/// Bottom sheet to add a new appointment.
class AddAppointmentSheet extends StatefulWidget {
  const AddAppointmentSheet({
    super.key,
    required this.selectedDate,
    this.prefilledTimeSlot,
    required this.onSaved,
  });

  final DateTime selectedDate;
  final String? prefilledTimeSlot;
  final VoidCallback onSaved;

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  late DateTime _date;
  String? _selectedSlot;
  int _duration = 30;
  String _procedure = _procedureTypes.first;
  bool _linkTreatmentPlan = false;
  int _sittingCount = 3;
  int _frequencyDays = 7;

  final _store = AppointmentStore.instance;

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
    _selectedSlot = widget.prefilledTimeSlot;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<String> get _bookedSlots => _store.getBookedSlotsForDate(_date);

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: _blue600),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        // Reset slot if it's now booked
        if (_selectedSlot != null && _bookedSlots.contains(_selectedSlot)) {
          _selectedSlot = null;
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final id = 'appt_${DateTime.now().millisecondsSinceEpoch}';
    final appt = Appointment(
      id: id,
      patientId: 'manual_${_phoneCtrl.text}',
      patientName: _nameCtrl.text.trim(),
      patientPhone: _phoneCtrl.text.trim(),
      date: _date,
      timeSlot: _selectedSlot!,
      duration: _duration,
      type: _procedure,
      doctorName: 'Dr. Amanda Foster',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    _store.addAppointment(appt);
    NotificationService.instance.onAppointmentCreated(appt);

    // Auto-generate from treatment plan if enabled
    if (_linkTreatmentPlan && _sittingCount > 1) {
      _store.generateAppointmentsFromTreatmentPlan(
        treatmentPlanId: 'tp_$id',
        patientId: appt.patientId,
        patientName: appt.patientName,
        patientPhone: appt.patientPhone,
        treatmentType: _procedure,
        doctorName: 'Dr. Amanda Foster',
        sittingCount: _sittingCount - 1, // -1 because we already added the first
        frequencyDays: _frequencyDays,
        startDate: _date.add(Duration(days: _frequencyDays)),
        preferredTimeSlot: _selectedSlot!,
        duration: _duration,
      );
    }

    widget.onSaved();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_linkTreatmentPlan
            ? 'Appointment + $_sittingCount treatment sittings scheduled!'
            : 'Appointment scheduled!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booked = _bookedSlots;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: _slate300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Schedule Appointment', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: _slate900)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: _slate400)),
              ],
            ),
          ),
          const Divider(),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient name
                    _label('Patient Name'),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _inputDecor('Enter patient name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    _label('Phone Number'),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: _inputDecor('+91 XXXXXXXXXX'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Date
                    _label('Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: _slate200),
                          borderRadius: BorderRadius.circular(8),
                          color: _slate50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: _blue600),
                            const SizedBox(width: 10),
                            Text(DateFormat('EEEE, dd MMM yyyy').format(_date),
                                style: GoogleFonts.inter(fontSize: 14, color: _slate700)),
                            const Spacer(),
                            Icon(Icons.arrow_drop_down, color: _slate400),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Procedure
                    _label('Procedure'),
                    DropdownButtonFormField<String>(
                      initialValue: _procedure,
                      decoration: _inputDecor(''),
                      items: _procedureTypes
                          .map((p) => DropdownMenuItem(value: p, child: Text(p, style: GoogleFonts.inter(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _procedure = v!),
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    _label('Duration'),
                    Wrap(
                      spacing: 8,
                      children: _durationOptions.map((d) {
                        final isSelected = _duration == d.value;
                        return ChoiceChip(
                          label: Text(d.label),
                          selected: isSelected,
                          selectedColor: _blue100,
                          labelStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? _blue600 : _slate600,
                          ),
                          side: BorderSide(color: isSelected ? _blue600 : _slate200),
                          onSelected: (_) => setState(() => _duration = d.value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Time slot picker
                    _label('Time Slot'),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _allTimeSlots.map((slot) {
                        final isBooked = booked.contains(slot);
                        final isSelected = _selectedSlot == slot;
                        return GestureDetector(
                          onTap: isBooked ? null : () => setState(() => _selectedSlot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? _slate50
                                  : isSelected
                                      ? _blue600
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isBooked
                                    ? _slate200
                                    : isSelected
                                        ? _blue600
                                        : _slate300,
                              ),
                            ),
                            child: Text(
                              Appointment.to12Hour(slot),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isBooked
                                    ? _slate300
                                    : isSelected
                                        ? Colors.white
                                        : _slate700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    _label('Notes (optional)'),
                    TextFormField(
                      controller: _notesCtrl,
                      decoration: _inputDecor('Any special notes...'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Treatment plan toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _blue100.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _blue100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 18, color: _blue600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Auto-schedule from Treatment Plan',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _slate900),
                                ),
                              ),
                              Switch.adaptive(
                                value: _linkTreatmentPlan,
                                activeTrackColor: _blue600,
                                onChanged: (v) => setState(() => _linkTreatmentPlan = v),
                              ),
                            ],
                          ),
                          if (_linkTreatmentPlan) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total Sittings', style: GoogleFonts.inter(fontSize: 12, color: _slate500)),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<int>(
                                        initialValue: _sittingCount,
                                        decoration: _inputDecor(''),
                                        isDense: true,
                                        items: List.generate(10, (i) => i + 2)
                                            .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                                            .toList(),
                                        onChanged: (v) => setState(() => _sittingCount = v!),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Every', style: GoogleFonts.inter(fontSize: 12, color: _slate500)),
                                      const SizedBox(height: 4),
                                      DropdownButtonFormField<int>(
                                        initialValue: _frequencyDays,
                                        decoration: _inputDecor(''),
                                        isDense: true,
                                        items: const [
                                          DropdownMenuItem(value: 3, child: Text('3 days')),
                                          DropdownMenuItem(value: 5, child: Text('5 days')),
                                          DropdownMenuItem(value: 7, child: Text('Weekly')),
                                          DropdownMenuItem(value: 14, child: Text('Biweekly')),
                                          DropdownMenuItem(value: 30, child: Text('Monthly')),
                                        ],
                                        onChanged: (v) => setState(() => _frequencyDays = v!),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: Text(
                          _linkTreatmentPlan ? 'Schedule All Sittings' : 'Schedule Appointment',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _slate700)),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: _slate400),
      filled: true,
      fillColor: _slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _slate200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _slate200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _blue600, width: 1.5)),
    );
  }
}
