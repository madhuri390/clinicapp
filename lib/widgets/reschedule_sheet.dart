import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../services/appointment_store.dart';
import '../services/notification_service.dart';

// Colors
const _blue600 = Color(0xFF2563EB);
const _slate50 = Color(0xFFF8FAFC);
const _slate200 = Color(0xFFE2E8F0);
const _slate300 = Color(0xFFCBD5E1);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);

const _allTimeSlots = [
  '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
  '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  '18:00', '18:30',
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
  final _store = AppointmentStore.instance;

  @override
  void initState() {
    super.initState();
    _newDate = widget.appointment.date;
    _newSlot = null; // Force doctor to pick new slot
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  List<String> get _bookedSlots => _store.getBookedSlotsForDate(_newDate);

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _blue600),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _newDate = picked;
        if (_newSlot != null && _bookedSlots.contains(_newSlot)) {
          _newSlot = null;
        }
      });
    }
  }

  void _save() {
    if (_newSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a new time slot'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a message for the patient'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final oldAppt = widget.appointment;
    final msg = _messageCtrl.text.trim();

    _store.rescheduleAppointment(
      id: oldAppt.id,
      newDate: _newDate,
      newTimeSlot: _newSlot!,
      doctorMessage: msg,
    );

    // Find the newly created appointment to pass to notification
    final newAppt = _store.all.last;
    NotificationService.instance.onAppointmentRescheduled(
      oldAppt: oldAppt,
      newAppt: newAppt,
      doctorMessage: msg,
    );

    widget.onSaved();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment rescheduled'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final booked = _bookedSlots;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reschedule Appointment', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: _slate900)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: _slate400)),
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _slate200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20, color: _blue600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.patientName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _slate900)),
                              Text('${a.type} • ${a.timeRange}', style: GoogleFonts.inter(fontSize: 13, color: _slate600)),
                              Text('Current: ${DateFormat('dd MMM yyyy').format(a.date)}', style: GoogleFonts.inter(fontSize: 12, color: _slate500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // New date
                  Text('New Date', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _slate700)),
                  const SizedBox(height: 6),
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
                          Text(DateFormat('EEEE, dd MMM yyyy').format(_newDate),
                              style: GoogleFonts.inter(fontSize: 14, color: _slate700)),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: _slate400),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New time slot
                  Text('New Time Slot', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _slate700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allTimeSlots.map((slot) {
                      final isBooked = booked.contains(slot);
                      final isSelected = _newSlot == slot;
                      return GestureDetector(
                        onTap: isBooked ? null : () => setState(() => _newSlot = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isBooked ? _slate50 : isSelected ? _blue600 : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isBooked ? _slate200 : isSelected ? _blue600 : _slate300),
                          ),
                          child: Text(
                            Appointment.to12Hour(slot),
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: isBooked ? _slate300 : isSelected ? Colors.white : _slate700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Doctor message
                  Text("Doctor's Message *", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _slate700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _messageCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Reason for rescheduling (sent to patient via WhatsApp)',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: _slate400),
                      filled: true,
                      fillColor: _slate50,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _slate200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _slate200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _blue600, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: _blue600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'This message will be sent to the patient via WhatsApp',
                          style: GoogleFonts.inter(fontSize: 11, color: _blue600),
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
                      label: Text('Reschedule', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
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
        ],
      ),
    );
  }
}
