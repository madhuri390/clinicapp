import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../models/patient_model.dart';
import '../repositories/appointment_repository.dart';
import '../repositories/patient_repository.dart';
import '../services/notification_service.dart';
import '../services/staff_service.dart';
import '../models/staff_model.dart';

// Colors
const _blue600 = Color(0xFF0D8DC4);
const _blue100 = Color(0xFFB4E0F0);
const _slate50 = Color(0xFFF8FAFC);
const _slate200 = Color(0xFFE2E8F0);
const _slate300 = Color(0xFFCBD5E1);
const _slate400 = Color(0xFF94A3B8);
// const _slate500 = Color(0xFF64748B);
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
    this.prefilledPatientId,
    this.prefilledPatientName,
    this.prefilledPatientPhone,
    this.prefilledDoctorId,
    this.prefilledDoctorName,
  });

  final DateTime selectedDate;
  final String? prefilledTimeSlot;
  final VoidCallback onSaved;

  /// Patient portal: lock booking to this profile.
  final String? prefilledPatientId;
  final String? prefilledPatientName;
  final String? prefilledPatientPhone;

  /// Doctor view: lock booking to this doctor.
  final String? prefilledDoctorId;
  final String? prefilledDoctorName;

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _patientFocus = FocusNode();

  late DateTime _date;
  String? _selectedSlot;
  int _duration = 30;
  String _procedure = _procedureTypes.first;
  // Previously supported local auto-scheduling from a treatment plan.
  // DB-backed appointments: keep booking as a single explicit appointment.

  final _repo = AppointmentRepository();
  final _staffService = StaffService.instance;
  final _patientRepo = PatientRepository();

  Timer? _patientDebounce;
  bool _loadingPatients = false;
  List<Patient> _patientResults = const [];
  String? _selectedPatientId;
  String? _selectedPatientPhone;
  String? _selectedPatientName;

  List<Staff>? _doctors;
  bool _loadingDoctors = false;
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  List<Appointment> _doctorDayAppts = [];
  bool _loadingSlots = false;

  DateTime _calendarDay(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSlotStartInPast(DateTime day, String slot) {
    final parts = slot.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final start = DateTime(day.year, day.month, day.day, h, m);
    return start.isBefore(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    final today = _calendarDay(DateTime.now());
    final sel = _calendarDay(widget.selectedDate);
    _date = sel.isBefore(today) ? today : sel;
    _selectedSlot = widget.prefilledTimeSlot;
    if (_selectedSlot != null && _isSlotStartInPast(_date, _selectedSlot!)) {
      _selectedSlot = null;
    }
    if (widget.prefilledPatientId != null) {
      _selectedPatientId = widget.prefilledPatientId;
      _selectedPatientName = widget.prefilledPatientName;
      _selectedPatientPhone = widget.prefilledPatientPhone;
      if (_selectedPatientName != null) _nameCtrl.text = _selectedPatientName!;
    }

    _selectedDoctorId = widget.prefilledDoctorId;
    _selectedDoctorName = widget.prefilledDoctorName;
    _bootstrapDoctorsAndSlots();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _patientDebounce?.cancel();
    _patientFocus.dispose();
    super.dispose();
  }

  void _onPatientQueryChanged(String q) {
    if (widget.prefilledPatientId != null) return;
    _selectedPatientId = null;
    _selectedPatientPhone = null;
    _selectedPatientName = null;
    _patientDebounce?.cancel();
    final query = q.trim();
    if (query.isEmpty) {
      setState(() {
        _loadingPatients = false;
        _patientResults = const [];
      });
      return;
    }
    _patientDebounce = Timer(const Duration(milliseconds: 220), () async {
      if (!mounted) return;
      setState(() => _loadingPatients = true);
      try {
        final results = await _patientRepo.search(query);
        if (!mounted) return;
        setState(() {
          _patientResults = results;
          _loadingPatients = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _loadingPatients = false);
      }
    });
  }

  void _selectPatient(Patient p) {
    setState(() {
      _selectedPatientId = p.id;
      _selectedPatientName = p.fullName.isNotEmpty ? p.fullName : p.firstName;
      _selectedPatientPhone = p.phone;
      _patientResults = const [];
      _loadingPatients = false;
    });
    _nameCtrl.text = _selectedPatientName ?? '';
    _patientFocus.unfocus();
  }

  Future<void> _bootstrapDoctorsAndSlots() async {
    // If doctor is fixed, just load slots.
    if (widget.prefilledDoctorId != null) {
      await _loadBookedForDoctorDay();
      return;
    }
    setState(() => _loadingDoctors = true);
    try {
      final docs = await _staffService.getStaff();
      if (!mounted) return;
      setState(() {
        _doctors = docs;
        _loadingDoctors = false;
        if (_selectedDoctorId == null && docs.isNotEmpty) {
          _selectedDoctorId = docs.first.id;
          _selectedDoctorName = docs.first.name;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDoctors = false);
    }
    await _loadBookedForDoctorDay();
  }

  Future<void> _loadBookedForDoctorDay() async {
    final did = _selectedDoctorId;
    if (did == null || did.isEmpty) return;
    setState(() => _loadingSlots = true);
    try {
      final all = await _repo.getForDoctor(did);
      final day = all.where((a) =>
          a.date.year == _date.year &&
          a.date.month == _date.month &&
          a.date.day == _date.day &&
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.rescheduled).toList();
      if (!mounted) return;
      setState(() {
        _doctorDayAppts = day;
        _loadingSlots = false;
        if (_selectedSlot != null && _bookedSlots.contains(_selectedSlot)) {
          _selectedSlot = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSlots = false);
    }
  }

  List<String> get _bookedSlots {
    final bookedSlots = <String>[];
    for (final a in _doctorDayAppts) {
      final parts = a.timeSlot.split(':');
      var h = int.parse(parts[0]);
      var m = int.parse(parts[1]);
      var remaining = a.duration;
      while (remaining > 0) {
        bookedSlots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
        m += 30;
        if (m >= 60) {
          h += 1;
          m -= 60;
        }
        remaining -= 30;
      }
    }
    return bookedSlots;
  }

  void _pickDate() async {
    final today = _calendarDay(DateTime.now());
    final safeInitial = _date.isBefore(today) ? today : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
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
        if (_selectedSlot != null && _isSlotStartInPast(_date, _selectedSlot!)) {
          _selectedSlot = null;
        }
      });
      await _loadBookedForDoctorDay();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_isSlotStartInPast(_date, _selectedSlot!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That time has already passed. Pick a future slot.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedDoctorId == null || _selectedDoctorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_selectedPatientId == null || _selectedPatientId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_selectedPatientPhone == null || _selectedPatientPhone!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load patient phone'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final id = 'appt_${DateTime.now().millisecondsSinceEpoch}';
    final appt = Appointment(
      id: id,
      patientId: _selectedPatientId!,
      patientName: _selectedPatientName ?? _nameCtrl.text.trim(),
      patientPhone: _selectedPatientPhone!,
      doctorId: _selectedDoctorId!,
      date: _date,
      timeSlot: _selectedSlot!,
      duration: _duration,
      type: _procedure,
      doctorName: _selectedDoctorName ?? widget.prefilledDoctorName ?? 'Doctor',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      final created = await _repo.book(appt);
      NotificationService.instance.onAppointmentCreated(created);
      if (!mounted) return;

      widget.onSaved();
      Navigator.of(context).pop();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment scheduled!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booked = _bookedSlots;
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.92;

    return SizedBox(
      height: sheetHeight,
      child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _blue100.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event_available_outlined, color: _blue600, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Schedule Appointment',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _slate900,
                      ),
                    ),
                  ],
                ),
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
                    // Doctor (required)
                    _label('Doctor'),
                    if (widget.prefilledDoctorId != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: _slate200),
                          borderRadius: BorderRadius.circular(8),
                          color: _slate50,
                        ),
                        child: Text(
                          _selectedDoctorName ?? widget.prefilledDoctorName ?? 'Doctor',
                          style: GoogleFonts.inter(fontSize: 14, color: _slate700),
                        ),
                      ),
                    ] else if (_loadingDoctors) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedDoctorId),
                        initialValue: _selectedDoctorId,
                        decoration: _inputDecor('Select doctor'),
                        items: (_doctors ?? [])
                            .map(
                              (d) => DropdownMenuItem(
                                value: d.id,
                                child: Text(d.name, style: GoogleFonts.inter(fontSize: 14)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          final docs = _doctors ?? const <Staff>[];
                          final selected = docs.where((d) => d.id == v).toList();
                          setState(() {
                            _selectedDoctorId = v;
                            _selectedDoctorName = selected.isNotEmpty ? selected.first.name : null;
                          });
                          await _loadBookedForDoctorDay();
                        },
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Patient (searchable dropdown)
                    _label('Patient'),
                    TextFormField(
                      controller: _nameCtrl,
                      focusNode: _patientFocus,
                      readOnly: widget.prefilledPatientId != null,
                      onChanged: _onPatientQueryChanged,
                      decoration: _inputDecor('Search patient by name or phone'),
                      validator: (v) => (_selectedPatientId == null || _selectedPatientId!.isEmpty)
                          ? 'Please select a patient'
                          : null,
                    ),
                    if (widget.prefilledPatientId == null) ...[
                      const SizedBox(height: 8),
                      if (_loadingPatients)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                      if (_patientResults.isNotEmpty)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _slate200),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _patientResults.take(6).length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final p = _patientResults[i];
                              final name = p.fullName.isNotEmpty ? p.fullName : p.firstName;
                              return ListTile(
                                dense: true,
                                title: Text(name, style: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: 13)),
                                subtitle: Text(p.phone, style: GoogleFonts.lato(fontSize: 12, color: _slate600)),
                                onTap: () => _selectPatient(p),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                    ] else ...[
                      const SizedBox(height: 8),
                    ],

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
                    if (_loadingSlots)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _allTimeSlots.map((slot) {
                        final isBooked = booked.contains(slot);
                        final isPast = _isSlotStartInPast(_date, slot);
                        final blocked = isBooked || isPast;
                        final isSelected = _selectedSlot == slot;
                        return GestureDetector(
                          onTap: blocked ? null : () => setState(() => _selectedSlot = slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: blocked
                                  ? _slate50
                                  : isSelected
                                      ? _blue600
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: blocked
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
                                color: blocked
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

                    const SizedBox(height: 8),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        label: Text(
                          'Schedule Appointment',
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
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w600, color: _slate700)),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.lato(fontSize: 14, color: _slate400),
      filled: true,
      fillColor: _slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _slate200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _slate200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _blue600, width: 1.5)),
    );
  }
}
