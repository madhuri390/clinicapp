import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/file_attachment_model.dart';
import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';
import '../repositories/prescription_repository.dart';
import '../repositories/treatment_repository.dart';
import '../services/local_store.dart';
import 'patient_details_profile_tab.dart';

class ConsultationCard extends StatelessWidget {
  const ConsultationCard({
    super.key,
    required this.visit,
    required this.treatments,
    required this.prescriptions,
    required this.sittings,
    required this.payments,
    required this.isOngoing,
    required this.onRefresh,
    required this.onEditVisit,
  });

  final Visit visit;
  final List<TreatmentPlan> treatments;
  final List<Prescription> prescriptions;
  final List<dynamic> sittings;
  final List<Payment> payments;
  final bool isOngoing;
  final VoidCallback onRefresh;
  final ValueChanged<Visit> onEditVisit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ProfileTab.formatDate(visit.visitDate),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOngoing ? Colors.black : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOngoing ? 'Ongoing' : 'Completed',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOngoing ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.chiefComplaint ?? 'General Checkup',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Dr. Emily Chen',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnosis',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF3730A3),
                              ),
                            ),
                            Text(
                              visit.diagnosis ?? 'Pending diagnosis',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF312E81),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          if (treatments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: treatments
                    .map(
                      (t) => _TreatmentAccordion(
                        treatment: t,
                        prescriptions: prescriptions
                            .where((p) => p.treatmentPlanId == t.id)
                            .toList(),
                        files: LocalStore.instance.getFilesForTreatment(t.id),
                        sittings: sittings
                            .where((s) => s.treatmentPlanId == t.id)
                            .toList(),
                        payments: payments,
                        onRefresh: onRefresh,
                        isOngoing: isOngoing,
                      ),
                    )
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isOngoing) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ActionChip(
                          label: 'Edit',
                          icon: Icons.edit,
                          onTap: () => onEditVisit(visit),
                        ),
                        if (treatments.isEmpty)
                          _ActionChip(
                            label: 'Add Treatment',
                            icon: Icons.healing,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _AddTreatmentSheet(
                                  visitId: visit.id,
                                  onSave: (t) async {
                                    final created =
                                        await TreatmentRepository().create(t);
                                    LocalStore.instance.addTreatment(created);
                                    if (context.mounted) Navigator.pop(context);
                                    onRefresh();
                                  },
                                ),
                              );
                            },
                          ),
                        _ActionChip(
                          label: 'Add Prescription',
                          icon: Icons.medication,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _AddPrescriptionSheet(
                                visitId: visit.id,
                                treatmentPlanId:
                                    treatments.length == 1 ? treatments.first.id : null,
                                onSave: (p) async {
                                  final created =
                                      await PrescriptionRepository().create(p);
                                  LocalStore.instance.addPrescription(created);
                                  if (context.mounted) Navigator.pop(context);
                                  onRefresh();
                                },
                              ),
                            );
                          },
                        ),
                        _ActionChip(
                          label: 'Add File',
                          icon: Icons.attach_file,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _AddFileSheet(
                                visitId: visit.id,
                                onSave: (f) async {
                                  LocalStore.instance.addFile(f);
                                  if (context.mounted) Navigator.pop(context);
                                  onRefresh();
                                },
                              ),
                            );
                          },
                        ),
                        _ActionChip(
                          label: 'Add Payment',
                          icon: Icons.payment,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => _AddPaymentSheet(
                                visitId: visit.id,
                                onSave: (payment) async {
                                  LocalStore.instance.addPayment(payment);
                                  if (context.mounted) Navigator.pop(context);
                                  onRefresh();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount Paid:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${payments.fold<double>(0, (sum, p) => sum + p.amountPaid).toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F0B1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final allFiles = treatments
                          .expand(
                            (t) => LocalStore.instance.getFilesForTreatment(t.id),
                          )
                          .toList();
                      _showBillPreview(
                        context,
                        visit,
                        treatments,
                        prescriptions,
                        payments,
                        allFiles,
                      );
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: Text(
                      'Generate Bill',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentAccordion extends StatelessWidget {
  const _TreatmentAccordion({
    required this.treatment,
    required this.prescriptions,
    required this.files,
    required this.sittings,
    required this.payments,
    required this.onRefresh,
    required this.isOngoing,
  });

  final TreatmentPlan treatment;
  final List<Prescription> prescriptions;
  final List<FileAttachment> files;
  final List<dynamic> sittings;
  final List<Payment> payments;
  final VoidCallback onRefresh;
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.grey.shade500,
          iconColor: Colors.grey.shade500,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF065F46),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      treatment.treatmentName ?? 'Treatment',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${sittings.length} sittings',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  treatment.status ?? 'planned',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Treatment Description',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    treatment.description ?? 'No description provided.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isOngoing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _AddPrescriptionSheet(
                                  visitId: treatment.visitId,
                                  treatmentPlanId: treatment.id,
                                  onSave: (p) {
                                    LocalStore.instance.addPrescription(p);
                                    onRefresh();
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.medication_outlined,
                              size: 20,
                            ),
                            label: const Text('Add Prescription'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => _AddFileSheet(
                                  visitId: treatment.visitId,
                                  treatmentId: treatment.id,
                                  onSave: (file) {
                                    LocalStore.instance.addFile(file);
                                    onRefresh();
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.attach_file, size: 20),
                            label: const Text('Add File'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (prescriptions.isNotEmpty) ...[
                    Text(
                      'Treatment Prescriptions',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...prescriptions.map(
                      (p) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.medication,
                              color: Color(0xFF7C3AED),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.medicineName ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    p.dosage ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${p.price?.toStringAsFixed(0) ?? '0'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4C1D95),
                                  ),
                                ),
                                if ((p.price ?? 0) > 0)
                                  Text(
                                    p.payment != null ? 'Paid' : 'Pending',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: p.payment != null
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _SittingsHeader(
                    visitId: treatment.visitId,
                    treatmentId: treatment.id,
                    onRefresh: onRefresh,
                    isOngoing: isOngoing,
                  ),
                  const SizedBox(height: 8),
                  _SittingsList(
                    visitId: treatment.visitId,
                    sittings: sittings,
                    onRefresh: onRefresh,
                    isOngoing: isOngoing,
                  ),
                  if (files.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Attached Files',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...files.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.fileName ?? 'Unnamed File',
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  if ((f.price ?? 0) > 0)
                                    Text(
                                      '\$${f.price!.toStringAsFixed(0)} • ${f.payment != null ? 'Paid' : 'Pending'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: f.payment != null
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download, size: 18),
                              onPressed: () =>
                                  _downloadFile(context, f.fileName ?? 'file'),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              color: const Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadFile(BuildContext context, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        backgroundColor: const Color(0xFF4F46E5),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTreatmentSheet extends StatefulWidget {
  const _AddTreatmentSheet({required this.visitId, required this.onSave});

  final String visitId;
  final ValueChanged<TreatmentPlan> onSave;

  @override
  State<_AddTreatmentSheet> createState() => _AddTreatmentSheetState();
}

class _AddTreatmentSheetState extends State<_AddTreatmentSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Add Treatment',
      child: Column(
        children: [
          _SheetField(controller: _nameCtrl, label: 'Treatment Name *'),
          const SizedBox(height: 12),
          _SheetField(controller: _descCtrl, label: 'Description', maxLines: 2),
          const SizedBox(height: 12),
          _SheetField(controller: _costCtrl, label: 'Total Cost (Optional)'),
          const SizedBox(height: 20),
          _SaveButton(
            isSaving: _saving,
            label: 'Save Treatment',
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              setState(() => _saving = true);
              widget.onSave(
                TreatmentPlan(
                  id: '',
                  visitId: widget.visitId,
                  treatmentName: _nameCtrl.text.trim(),
                  description:
                      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
                  totalCost: double.tryParse(_costCtrl.text),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddSittingSheet extends StatefulWidget {
  const _AddSittingSheet({
    this.visitId,
    required this.treatmentPlanId,
    required this.onSave,
  });

  final String? visitId;
  final String treatmentPlanId;
  final ValueChanged<Sitting> onSave;

  @override
  State<_AddSittingSheet> createState() => _AddSittingSheetState();
}

class _AddSittingSheetState extends State<_AddSittingSheet> {
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Add Sitting',
      child: Column(
        children: [
          _SheetField(controller: _costCtrl, label: 'Cost *'),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month),
            title: Text('Date: ${_date.day}/${_date.month}/${_date.year}'),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _date = d);
            },
          ),
          const SizedBox(height: 12),
          _SheetField(controller: _notesCtrl, label: 'Notes', maxLines: 2),
          const SizedBox(height: 20),
          _SaveButton(
            isSaving: _saving,
            label: 'Save Sitting',
            onPressed: () {
              final cost = double.tryParse(_costCtrl.text.trim()) ?? 0;
              setState(() => _saving = true);
              widget.onSave(
                Sitting(
                  id: '',
                  visitId: widget.visitId ?? '',
                  treatmentPlanId: widget.treatmentPlanId,
                  sittingDate: _date,
                  durationStr: '30 mins',
                  notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
                  cost: cost,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddPrescriptionSheet extends StatefulWidget {
  const _AddPrescriptionSheet({
    this.visitId,
    this.treatmentPlanId,
    required this.onSave,
  });

  final String? visitId;
  final String? treatmentPlanId;
  final ValueChanged<Prescription> onSave;

  @override
  State<_AddPrescriptionSheet> createState() => _AddPrescriptionSheetState();
}

class _AddPrescriptionSheetState extends State<_AddPrescriptionSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instructionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Add Prescription',
      child: Column(
        children: [
          _SheetField(controller: _nameCtrl, label: 'Medicine Name *'),
          const SizedBox(height: 12),
          _SheetField(controller: _dosageCtrl, label: 'Dosage (e.g. 1-0-1)'),
          const SizedBox(height: 12),
          _SheetField(
            controller: _instructionCtrl,
            label: 'Instructions',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _priceCtrl,
            label: 'Price (Optional)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _SaveButton(
            isSaving: _saving,
            label: 'Save Prescription',
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              setState(() => _saving = true);
              widget.onSave(
                Prescription(
                  id: '',
                  visitId: widget.visitId,
                  treatmentPlanId: widget.treatmentPlanId,
                  medicineName: _nameCtrl.text.trim(),
                  dosage: _dosageCtrl.text.trim().isEmpty
                      ? null
                      : _dosageCtrl.text.trim(),
                  instructions: _instructionCtrl.text.trim().isEmpty
                      ? null
                      : _instructionCtrl.text.trim(),
                  price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddFileSheet extends StatefulWidget {
  const _AddFileSheet({this.visitId, this.treatmentId, required this.onSave});

  final String? visitId;
  final String? treatmentId;
  final ValueChanged<FileAttachment> onSave;

  @override
  State<_AddFileSheet> createState() => _AddFileSheetState();
}

class _AddFileSheetState extends State<_AddFileSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Upload File (Mock)',
      child: Column(
        children: [
          _SheetField(controller: _nameCtrl, label: 'File Name *'),
          const SizedBox(height: 12),
          _SheetField(
            controller: _priceCtrl,
            label: 'Price (Optional)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _SaveButton(
            isSaving: _saving,
            label: 'Save File',
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              setState(() => _saving = true);
              widget.onSave(
                FileAttachment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  visitId: widget.visitId,
                  treatmentPlanId: widget.treatmentId,
                  fileName: _nameCtrl.text.trim(),
                  fileType: 'image/jpeg',
                  fileUrl: 'mock_url',
                  price: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet({
    required this.visitId,
    this.sittingId,
    required this.onSave,
  });

  final String visitId;
  final String? sittingId;
  final ValueChanged<Payment> onSave;

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMode = 'Cash';
  bool _saving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Add Payment',
      child: Column(
        children: [
          _SheetField(controller: _amountCtrl, label: 'Amount *'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _paymentMode,
            decoration: const InputDecoration(labelText: 'Payment Mode'),
            items: [
              'Cash',
              'UPI',
              'Card',
              'Insurance',
            ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMode = v ?? 'Cash'),
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _notesCtrl,
            label: 'Notes (Optional)',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          _SaveButton(
            isSaving: _saving,
            label: 'Save Payment',
            onPressed: () {
              final amount = double.tryParse(_amountCtrl.text.trim());
              if (amount == null || amount <= 0) return;
              setState(() => _saving = true);
              widget.onSave(
                Payment(
                  id: '',
                  visitId: widget.visitId,
                  sittingId: widget.sittingId,
                  amountPaid: amount,
                  paymentMode: _paymentMode,
                  paymentDate: DateTime.now(),
                  notes: _notesCtrl.text.trim().isEmpty
                      ? null
                      : _notesCtrl.text.trim(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showBillPreview(
  BuildContext context,
  Visit visit,
  List<TreatmentPlan> treatments,
  List<Prescription> prescriptions,
  List<Payment> payments,
  List<FileAttachment> files,
) {
  final sittings = LocalStore.instance.getSittingsForVisits([visit.id]);
  sittings.sort((a, b) => a.sittingDate.compareTo(b.sittingDate));

  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Prodontics Clinic',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                      Text(
                        'Professional Dental Care',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1E40AF).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _invoiceInfoRow('Patient Name', 'Sarah Johnson'),
                  _invoiceInfoRow(
                    'Consultation Date',
                    ProfileTab.formatDate(visit.visitDate),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _invoiceInfoRow('Doctor', 'Dr. Emily Chen'),
                  _invoiceInfoRow(
                    'Invoice Date',
                    ProfileTab.formatDate(DateTime.now()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Treatment Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...treatments.map(
                (t) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.treatmentName ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        t.description ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Itemized Charges',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...sittings.asMap().entries.map((entry) {
                final index = entry.key;
                final s = entry.value;
                final isPaid = payments.any((p) => p.sittingId == s.id);
                return _invoiceItemRow(
                  'Sitting ${index + 1}',
                  ProfileTab.formatDate(s.sittingDate),
                  s.cost ?? 0,
                  isPaid ? 'Paid' : 'Pending',
                  isPaid ? Colors.green : Colors.red,
                  subtitle: s.notes,
                );
              }),
              ...prescriptions.map((p) {
                return _invoiceItemRow(
                  'Prescription: ${p.medicineName}',
                  ProfileTab.formatDate(p.createdAt ?? DateTime.now()),
                  p.price ?? 0,
                  p.payment != null ? 'Paid' : 'Pending',
                  p.payment != null ? Colors.green : Colors.red,
                );
              }),
              ...files.where((f) => (f.price ?? 0) > 0).map((f) {
                return _invoiceItemRow(
                  'File: ${f.fileName}',
                  ProfileTab.formatDate(visit.visitDate),
                  f.price ?? 0,
                  f.payment != null ? 'Paid' : 'Pending',
                  f.payment != null ? Colors.green : Colors.red,
                );
              }),
              const Divider(height: 48),
              _invoiceSummaryRow(
                'Total Amount:',
                sittings.fold<double>(0, (sum, s) => sum + (s.cost ?? 0)) +
                    prescriptions.fold<double>(
                      0,
                      (sum, p) => sum + (p.price ?? 0),
                    ) +
                    files.fold<double>(0, (sum, f) => sum + (f.price ?? 0)),
              ),
              _invoiceSummaryRow(
                'Amount Paid:',
                payments.fold<double>(0, (sum, p) => sum + p.amountPaid),
                color: const Color(0xFF059669),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance Due:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final totalAmount =
                          sittings.fold<double>(
                                0,
                                (sum, s) => sum + (s.cost ?? 0),
                              ) +
                              prescriptions.fold<double>(
                                0,
                                (sum, p) => sum + (p.price ?? 0),
                              ) +
                              files.fold<double>(
                                0,
                                (sum, f) => sum + (f.price ?? 0),
                              );
                      final paidTotal = payments.fold<double>(
                        0,
                        (sum, p) => sum + p.amountPaid,
                      );
                      final balance = totalAmount - paidTotal;

                      return Text(
                        '\$${balance.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: balance <= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.print_outlined),
                      label: const Text('Print'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F0B1A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _invoiceInfoRow(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
      ),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    ],
  );
}

Widget _invoiceItemRow(
  String title,
  String date,
  double amount,
  String status,
  Color statusColor, {
  String? subtitle,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _invoiceSummaryRow(String label, double amount, {Color? color}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    ),
  );
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isSaving,
    required this.label,
    required this.onPressed,
  });

  final bool isSaving;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        onPressed: isSaving ? null : onPressed,
        child: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

class _BottomSheetWrapper extends StatelessWidget {
  const _BottomSheetWrapper({required this.title, required this.child});

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
        20 + MediaQuery.paddingOf(context).bottom,
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
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _SittingsHeader extends StatelessWidget {
  const _SittingsHeader({
    required this.visitId,
    required this.treatmentId,
    required this.onRefresh,
    required this.isOngoing,
  });

  final String visitId;
  final String treatmentId;
  final VoidCallback onRefresh;
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sittings',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isOngoing)
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _AddSittingSheet(
                  visitId: visitId,
                  treatmentPlanId: treatmentId,
                  onSave: (s) {
                    LocalStore.instance.addSitting(s);
                    onRefresh();
                    Navigator.pop(context);
                  },
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Add Sitting',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _SittingsList extends StatelessWidget {
  const _SittingsList({
    required this.visitId,
    required this.sittings,
    required this.onRefresh,
    required this.isOngoing,
  });

  final String visitId;
  final List<dynamic> sittings;
  final VoidCallback onRefresh;
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    if (sittings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No sittings recorded yet.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
      );
    }
    return Column(
      children: sittings
          .map(
            (s) => _SittingItem(
              visitId: visitId,
              sitting: s,
              onRefresh: onRefresh,
              isOngoing: isOngoing,
            ),
          )
          .toList(),
    );
  }
}

class _SittingItem extends StatelessWidget {
  const _SittingItem({
    required this.visitId,
    required this.sitting,
    required this.onRefresh,
    required this.isOngoing,
  });

  final String visitId;
  final Sitting sitting;
  final VoidCallback onRefresh;
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    final payments = LocalStore.instance.getPaymentsForSitting(sitting.id);
    final paidAmount = payments.fold<double>(0, (sum, p) => sum + p.amountPaid);
    final balance = (sitting.cost ?? 0) - paidAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          'Sitting - ${ProfileTab.formatDate(sitting.sittingDate)}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: balance <= 0
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '\$${sitting.cost?.toStringAsFixed(0) ?? '0'}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: balance <= 0
                  ? const Color(0xFF065F46)
                  : const Color(0xFFB91C1C),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sitting.notes != null)
                  Text(
                    sitting.notes!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid: \$${paidAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Balance: \$${balance.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: balance > 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                if (balance > 0 && isOngoing)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _AddPaymentSheet(
                              visitId: visitId,
                              sittingId: sitting.id,
                              onSave: (p) {
                                LocalStore.instance.addPayment(p);
                                onRefresh();
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Add Payment'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

