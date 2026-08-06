import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';
import '../theme/app_tokens.dart';

// Colors
const _primaryColor = AppTokens.accent;
const _slate50 = AppTokens.canvas;
const _slate200 = AppTokens.hairline;
const _slate300 = AppTokens.hairline;
const _slate400 = AppTokens.muted;
const _slate500 = AppTokens.body;
const _slate600 = AppTokens.body;
const _slate700 = AppTokens.ink;
const _slate900 = AppTokens.ink;

const _allTimeSlots = [
  '09:00',
  '09:30',
  '10:00',
  '10:30',
  '11:00',
  '11:30',
  '12:00',
  '12:30',
  '13:00',
  '13:30',
  '14:00',
  '14:30',
  '15:00',
  '15:30',
  '16:00',
  '16:30',
  '17:00',
  '17:30',
  '18:00',
  '18:30',
];

/// Bottom sheet for rescheduling an appointment.
class RescheduleSheet extends StatefulWidget {
  const RescheduleSheet({
    super.key,
    required this.appointment,
    required this.onSaved,
  });

  final Appointment appointment;
  final VoidCallback onSaved;

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  final _messageCtrl = TextEditingController();
  late DateTime _newDate;
  String? _newSlot;
  final _repo = AppointmentRepository();
  bool _loadingSlots = false;
  List<Appointment> _doctorDayAppts = [];

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
    var d = _calendarDay(widget.appointment.date);
    if (d.isBefore(today)) d = today;
    _newDate = d;
    _newSlot = null; // Force doctor to pick new slot
    _loadBooked();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  List<String> get _bookedSlots {
    final bookedSlots = <String>[];
    for (final a in _doctorDayAppts) {
      if (a.id == widget.appointment.id) continue;
      if (a.status == AppointmentStatus.cancelled ||
          a.status == AppointmentStatus.rescheduled)
        continue;
      final parts = a.timeSlot.split(':');
      var h = int.parse(parts[0]);
      var m = int.parse(parts[1]);
      var remaining = a.duration;
      while (remaining > 0) {
        bookedSlots.add(
          '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}',
        );
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

  Future<void> _loadBooked() async {
    final did = widget.appointment.doctorId;
    if (did.isEmpty) return;
    setState(() => _loadingSlots = true);
    try {
      final all = await _repo.getForDoctor(did);
      final day = all
          .where(
            (a) =>
                a.date.year == _newDate.year &&
                a.date.month == _newDate.month &&
                a.date.day == _newDate.day,
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _doctorDayAppts = day;
        _loadingSlots = false;
        if (_newSlot != null && _bookedSlots.contains(_newSlot))
          _newSlot = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSlots = false);
    }
  }

  void _pickDate() async {
    final today = _calendarDay(DateTime.now());
    final safeInitial = _newDate.isBefore(today) ? today : _newDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: _primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _newDate = picked;
        if (_newSlot != null && _isSlotStartInPast(_newDate, _newSlot!)) {
          _newSlot = null;
        }
      });
      await _loadBooked();
    }
  }

  Future<void> _save() async {
    if (_newSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a new time slot'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_isSlotStartInPast(_newDate, _newSlot!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That time has already passed. Pick a future slot.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a message for the patient'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final oldAppt = widget.appointment;
    final msg = _messageCtrl.text.trim();

    try {
      await _repo.rescheduleAsDoctor(
        appointment: oldAppt,
        newDate: _newDate,
        newTimeSlot: _newSlot!,
        doctorMessage: msg,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;

    final newAppt = oldAppt.copyWith(
      date: _newDate,
      timeSlot: _newSlot!,
      status: AppointmentStatus.rescheduled,
      doctorMessage: msg,
    );

    widget.onSaved();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment rescheduled'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final booked = _bookedSlots;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _slate300,
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
                  'Reschedule Appointment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _slate900,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: _slate400),
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
                  // Current appointment summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _slate50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _slate200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20, color: _primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.patientName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _slate900,
                                ),
                              ),
                              Text(
                                '${a.type} • ${a.timeRange}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: _slate600,
                                ),
                              ),
                              Text(
                                'Current: ${DateFormat('dd MMM yyyy').format(a.date)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: _slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // New date
                  Text(
                    'New Date',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _slate700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _slate200),
                        borderRadius: BorderRadius.circular(10),
                        color: _slate50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: _primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy').format(_newDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: _slate700,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: _slate400),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New time slot
                  Text(
                    'New Time Slot',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _slate700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingSlots)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allTimeSlots.map((slot) {
                      final isBooked = booked.contains(slot);
                      final isPast = _isSlotStartInPast(_newDate, slot);
                      final blocked = isBooked || isPast;
                      final isSelected = _newSlot == slot;
                      return GestureDetector(
                        onTap: blocked
                            ? null
                            : () => setState(() => _newSlot = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: blocked
                                ? _slate50
                                : isSelected
                                ? _primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: blocked
                                  ? _slate200
                                  : isSelected
                                  ? _primaryColor
                                  : _slate300,
                            ),
                          ),
                          child: Text(
                            Appointment.to12Hour(slot),
                            style: GoogleFonts.plusJakartaSans(
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
                  const SizedBox(height: 20),

                  // Doctor message
                  Text(
                    "Doctor's Message *",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _slate700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _messageCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Reason for rescheduling (sent to patient via WhatsApp)',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _slate400,
                      ),
                      filled: true,
                      fillColor: _slate50,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _slate200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _slate200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: _primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: _primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'This message will be sent to the patient via WhatsApp',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        'Reschedule',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
