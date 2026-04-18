import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/visit_model.dart';
import 'patient_details_header.dart';

/// Centered modal dialog for creating / editing a consultation.
/// [onSave] is async — the dialog stays open (shows spinner) until the
/// future resolves, then closes itself on success or resets on error.
class NewConsultationSheet extends StatefulWidget {
  const NewConsultationSheet({
    super.key,
    required this.patientId,
    required this.onSave,
    this.existingVisit,
    this.doctorId,
  });

  final String patientId;
  final Future<void> Function(Visit) onSave;
  final Visit? existingVisit;
  final String? doctorId;

  @override
  State<NewConsultationSheet> createState() => _NewConsultationSheetState();
}

class _NewConsultationSheetState extends State<NewConsultationSheet> {
  final _complaintCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl     = TextEditingController();
  DateTime _visitDate  = DateTime.now();
  bool _saving         = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existingVisit;
    if (e != null) {
      _complaintCtrl.text = e.chiefComplaint ?? '';
      _diagnosisCtrl.text = e.diagnosis ?? '';
      _notesCtrl.text     = e.notes ?? '';
      _visitDate          = e.visitDate;
    }
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    debugPrint('[NewConsultation] _save() called');
    final complaint = _complaintCtrl.text.trim();
    if (complaint.isEmpty) {
      setState(() => _error = 'Chief complaint is required');
      debugPrint('[NewConsultation] Validation failed: complaint empty');
      return;
    }
    setState(() { _saving = true; _error = null; });
    debugPrint('[NewConsultation] Saving started, spinner shown');

    final visit = Visit(
      id: widget.existingVisit?.id ?? '',
      patientId: widget.patientId,
      doctorId: widget.existingVisit?.doctorId ?? widget.doctorId,
      visitDate: _visitDate,
      chiefComplaint: complaint,
      diagnosis: _diagnosisCtrl.text.trim().isEmpty
          ? null
          : _diagnosisCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      nextVisitDate: widget.existingVisit?.nextVisitDate,
      createdAt: widget.existingVisit?.createdAt,
    );
    debugPrint('[NewConsultation] Visit object built: complaint=$complaint, patientId=${widget.patientId}');

    try {
      debugPrint('[NewConsultation] Calling onSave...');
      await widget.onSave(visit);
      debugPrint('[NewConsultation] onSave completed — popping dialog with result=true');
      // Pop with explicit result so showDialog's Future resolves with `true`.
      // Use rootNavigator: true to match how showDialog pushes the route
      // (rootNavigator: true by default), avoiding any nested-navigator confusion.
      if (mounted) Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e) {
      debugPrint('[NewConsultation] onSave threw error: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Failed to save: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingVisit != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20, 24, 20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.medical_services_outlined, size: 22, color: kRefPrimary),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Edit Consultation' : 'New Consultation',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kRefDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _ModalInput(
                controller: _complaintCtrl,
                placeholder: 'Chief complaint *',
              ),
              _ModalInput(
                controller: _diagnosisCtrl,
                placeholder: 'Diagnosis (optional)',
              ),
              _ModalInput(
                controller: _notesCtrl,
                placeholder: 'Notes (optional)',
                maxLines: 2,
              ),

              // Date picker
              GestureDetector(
                onTap: _saving ? null : () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _visitDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 36500)),
                  );
                  if (d != null) setState(() => _visitDate = d);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: kRefPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${_visitDate.day}/${_visitDate.month}/${_visitDate.year}',
                        style: GoogleFonts.lato(fontSize: 14, color: kRefDark),
                      ),
                    ],
                  ),
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(
                  _error!,
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.red),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _OutlineBtn(
                    label: 'Cancel',
                    enabled: !_saving,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  _PrimaryBtn(
                    label: isEditing ? 'Update' : 'Save',
                    saving: _saving,
                    onTap: _save,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input field ────────────────────────────────────────────────────────────

class _ModalInput extends StatelessWidget {
  const _ModalInput({
    required this.controller,
    required this.placeholder,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String placeholder;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.lato(fontSize: 14, color: kRefDark),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.lato(fontSize: 14, color: kRefMuted),
          contentPadding: const EdgeInsets.all(12),
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kRefPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Buttons ────────────────────────────────────────────────────────────────

class _OutlineBtn extends StatelessWidget {
  const _OutlineBtn({required this.label, required this.onTap, this.enabled = true});
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? kRefDark : kRefMuted,
          ),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({
    required this.label,
    required this.onTap,
    this.saving = false,
  });
  final String label;
  final Future<void> Function() onTap;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: saving ? const Color(0xFFCBD5E1) : kRefPrimary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: saving
              ? []
              : [
                  BoxShadow(
                    color: kRefPrimary.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: saving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
