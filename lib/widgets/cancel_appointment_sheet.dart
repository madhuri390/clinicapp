import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../services/appointment_store.dart';
import '../services/notification_service.dart';

// Colors
const _slate50 = Color(0xFFF8FAFC);
const _slate200 = Color(0xFFE2E8F0);
const _slate300 = Color(0xFFCBD5E1);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);
const _red500 = Color(0xFFEF4444);
const _red50 = Color(0xFFFEF2F2);
const _red100 = Color(0xFFFEE2E2);
const _red700 = Color(0xFFB91C1C);

/// Bottom sheet for cancelling an appointment with doctor's message.
class CancelAppointmentSheet extends StatefulWidget {
  const CancelAppointmentSheet({
    super.key,
    required this.appointment,
    required this.onSaved,
  });

  final Appointment appointment;
  final VoidCallback onSaved;

  @override
  State<CancelAppointmentSheet> createState() => _CancelAppointmentSheetState();
}

class _CancelAppointmentSheetState extends State<CancelAppointmentSheet> {
  final _messageCtrl = TextEditingController();
  final _store = AppointmentStore.instance;

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a reason for cancellation'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final msg = _messageCtrl.text.trim();
    final appt = widget.appointment;

    _store.cancelAppointment(id: appt.id, doctorMessage: msg);

    NotificationService.instance.onAppointmentCancelled(
      appt: appt,
      doctorMessage: msg,
    );

    widget.onSaved();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment cancelled'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;

    return Container(
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
                Text(
                  'Cancel Appointment',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: _red700),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: _slate400),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _red50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _red100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: _red500),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This will cancel the appointment and notify the patient via WhatsApp.',
                          style: GoogleFonts.inter(fontSize: 13, color: _red700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Appointment summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: _slate500),
                          const SizedBox(width: 8),
                          Text(a.patientName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _slate900)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.medical_services_outlined, size: 16, color: _slate400),
                          const SizedBox(width: 8),
                          Expanded(child: Text(a.type, style: GoogleFonts.inter(fontSize: 13, color: _slate600))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: _slate400),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd MMM yyyy').format(a.date)} • ${a.timeRange}',
                            style: GoogleFonts.inter(fontSize: 13, color: _slate600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Doctor message
                Text(
                  "Cancellation Reason *",
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: _slate700),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _messageCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Reason for cancellation (sent to patient via WhatsApp)',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: _slate400),
                    filled: true,
                    fillColor: _slate50,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _slate200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _red500, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: _slate200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Keep Appointment',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _slate700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _cancel,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
