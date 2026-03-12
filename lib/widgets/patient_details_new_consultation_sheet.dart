import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/visit_model.dart';

class NewConsultationSheet extends StatefulWidget {
  const NewConsultationSheet({
    super.key,
    required this.patientId,
    required this.onSave,
    this.existingVisit,
  });

  final String patientId;
  final ValueChanged<Visit> onSave;
  final Visit? existingVisit;

  @override
  State<NewConsultationSheet> createState() => _NewConsultationSheetState();
}

class _NewConsultationSheetState extends State<NewConsultationSheet> {
  final _complaintCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _visitDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingVisit;
    if (existing != null) {
      _complaintCtrl.text = existing.chiefComplaint ?? '';
      _diagnosisCtrl.text = existing.diagnosis ?? '';
      _notesCtrl.text = existing.notes ?? '';
      _visitDate = existing.visitDate;
    }
  }

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingVisit != null;
    return _SheetScaffold(
      title: isEditing ? 'Edit Consultation' : 'New Consultation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _visitDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(
                  const Duration(days: 36500),
                ), // Allow up to 100 years in future
              );
              if (d != null) setState(() => _visitDate = d);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Consultation Date: ${_visitDate.day}/${_visitDate.month}/${_visitDate.year}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _complaintCtrl,
            label: 'Chief Complaint',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _diagnosisCtrl,
            label: 'Diagnosis (Optional)',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _SheetField(controller: _notesCtrl, label: 'Notes', maxLines: 2),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F0B1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saving ? null : _save,
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
                      isEditing ? 'Update Consultation' : 'Create Consultation',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_complaintCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final visit = Visit(
      id: widget.existingVisit?.id ?? '',
      patientId: widget.patientId,
      visitDate: _visitDate,
      chiefComplaint: _complaintCtrl.text.trim(),
      diagnosis: _diagnosisCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      nextVisitDate: widget.existingVisit?.nextVisitDate,
      createdAt: widget.existingVisit?.createdAt,
    );
    widget.onSave(visit);
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
