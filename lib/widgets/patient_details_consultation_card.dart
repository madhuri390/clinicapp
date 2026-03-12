import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/file_attachment_model.dart';
import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';
import '../services/local_store.dart';
import '../theme/app_theme.dart';
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
    this.onComplete,
    required this.onEditVisit,
  });

  final Visit visit;
  final List<TreatmentPlan> treatments;
  final List<Prescription> prescriptions;
  final List<dynamic> sittings;
  final List<Payment> payments;
  final bool isOngoing;
  final VoidCallback onRefresh;
  final VoidCallback? onComplete;
  final ValueChanged<Visit> onEditVisit;

  @override
  Widget build(BuildContext context) {
    // Calculate if all expenses are paid and total cost > 0
    double totalCost = 0;
    bool hasUnpaidItem = false;

    for (var p in prescriptions) {
      if ((p.price ?? 0) > 0) {
        totalCost += p.price!;
        if (p.payment == null) hasUnpaidItem = true;
      }
    }
    final allFiles = treatments
        .expand((t) => LocalStore.instance.getFilesForTreatment(t.id))
        .toList();
    for (var f in allFiles) {
      if ((f.price ?? 0) > 0) {
        totalCost += f.price!;
        if (f.payment == null) hasUnpaidItem = true;
      }
    }
    for (var s in sittings) {
      if ((s.cost ?? 0) > 0) {
        totalCost += s.cost!;
        final sPayments = LocalStore.instance.getPaymentsForSitting(s.id);
        final paid = sPayments.fold<double>(0, (sum, p) => sum + p.amountPaid);
        if (paid < s.cost! - 0.01) hasUnpaidItem = true;
      }
    }

    final bool canComplete = totalCost > 0 && !hasUnpaidItem;

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
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ProfileTab.formatDate(visit.visitDate),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
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
                                  final newTreatment = t.copyWith(
                                    id: 'mock_t_${DateTime.now().millisecondsSinceEpoch}',
                                  );
                                  LocalStore.instance.addTreatment(
                                    newTreatment,
                                  );
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
                      '₹${payments.fold<double>(0, (sum, p) => sum + p.amountPaid).toStringAsFixed(0)}',
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
                      backgroundColor: isOngoing
                          ? (canComplete
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade400)
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isOngoing && !canComplete
                        ? null
                        : () {
                            _showBillPreview(
                              context,
                              visit,
                              onComplete: onComplete ?? onRefresh,
                            );
                          },
                    icon: Icon(
                      isOngoing ? Icons.check_circle : Icons.receipt_long,
                      size: 18,
                    ),
                    label: Text(
                      isOngoing ? 'Complete Consultation' : 'Generate Bill',
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.medication,
                                  color: Color(0xFF7C3AED),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      '₹${p.price?.toStringAsFixed(0) ?? '0'}',
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
                            if (isOngoing) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => _AddPrescriptionSheet(
                                          prescription: p,
                                          onSave: (updated) {
                                            LocalStore.instance
                                                .updatePrescription(updated);
                                            onRefresh();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Edit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ),
                                  if ((p.price ?? 0) > 0 && p.payment == null)
                                    TextButton(
                                      onPressed: () {
                                        LocalStore.instance.addPayment(
                                          Payment(
                                            id: 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
                                            visitId: treatment.visitId,
                                            prescriptionId: p.id,
                                            amountPaid: p.price ?? 0,
                                            paymentMode: 'Cash',
                                            paymentDate: DateTime.now(),
                                          ),
                                        );
                                        onRefresh();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Mark Paid',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file,
                                  size: 16,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f.fileName ?? 'Unnamed File',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                      if ((f.price ?? 0) > 0)
                                        Text(
                                          '₹${f.price!.toStringAsFixed(0)} • ${f.payment != null ? 'Paid' : 'Pending'}',
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
                                  onPressed: () => _downloadFile(
                                    context,
                                    f.fileName ?? 'file',
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  color: const Color(0xFF4F46E5),
                                ),
                              ],
                            ),
                            if (isOngoing)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => _AddFileSheet(
                                          visitId: treatment.visitId,
                                          treatmentId: treatment.id,
                                          file: f,
                                          onSave: (updated) {
                                            LocalStore.instance
                                                .updateFileAttachment(updated);
                                            onRefresh();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Edit',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                  if ((f.price ?? 0) > 0 && f.payment == null)
                                    TextButton(
                                      onPressed: () {
                                        LocalStore.instance.addPayment(
                                          Payment(
                                            id: 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
                                            visitId: treatment.visitId,
                                            fileId: f.id,
                                            amountPaid: f.price ?? 0,
                                            paymentMode: 'Cash',
                                            paymentDate: DateTime.now(),
                                          ),
                                        );
                                        onRefresh();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Mark Paid',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                ],
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
    this.iconColor = const Color(0xFF4F46E5),
    this.textColor = Colors.black87,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

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
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
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
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
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
                  description: _descCtrl.text.trim().isEmpty
                      ? null
                      : _descCtrl.text.trim(),
                  totalCost: null,
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
                lastDate: DateTime.now().add(
                  const Duration(days: 36500),
                ), // Allow up to 100 years in future
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
                  id: 'mock_s_${DateTime.now().millisecondsSinceEpoch}',
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
    this.prescription,
    required this.onSave,
  });

  final String? visitId;
  final String? treatmentPlanId;
  final Prescription? prescription;
  final ValueChanged<Prescription> onSave;

  @override
  State<_AddPrescriptionSheet> createState() => _AddPrescriptionSheetState();
}

class _AddPrescriptionSheetState extends State<_AddPrescriptionSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dosageCtrl;
  late final TextEditingController _instructionCtrl;
  late final TextEditingController _priceCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.prescription?.medicineName);
    _dosageCtrl = TextEditingController(text: widget.prescription?.dosage);
    _instructionCtrl = TextEditingController(
      text: widget.prescription?.instructions,
    );
    _priceCtrl = TextEditingController(
      text: widget.prescription?.price?.toStringAsFixed(0),
    );
  }

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
              final p = widget.prescription;
              widget.onSave(
                p != null
                    ? p.copyWith(
                        medicineName: _nameCtrl.text.trim(),
                        dosage: _dosageCtrl.text.trim().isEmpty
                            ? null
                            : _dosageCtrl.text.trim(),
                        instructions: _instructionCtrl.text.trim().isEmpty
                            ? null
                            : _instructionCtrl.text.trim(),
                        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
                      )
                    : Prescription(
                        id: 'mock_p_${DateTime.now().millisecondsSinceEpoch}',
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
  const _AddFileSheet({
    this.visitId,
    this.treatmentId,
    this.file,
    required this.onSave,
  });

  final String? visitId;
  final String? treatmentId;
  final FileAttachment? file;
  final ValueChanged<FileAttachment> onSave;

  @override
  State<_AddFileSheet> createState() => _AddFileSheetState();
}

class _AddFileSheetState extends State<_AddFileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.file?.fileName);
    _priceCtrl = TextEditingController(
      text: widget.file?.price?.toStringAsFixed(0),
    );
  }

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
              final f = widget.file;
              widget.onSave(
                f != null
                    ? f.copyWith(
                        fileName: _nameCtrl.text.trim(),
                        price: double.tryParse(_priceCtrl.text.trim()) ?? 0.0,
                      )
                    : FileAttachment(
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

void _showBillPreview(
  BuildContext context,
  Visit visit, {
  VoidCallback? onComplete,
}) {
  final store = LocalStore.instance;

  // Fetch all related data directly from store for the freshest state
  final treatments = store.getTreatmentsForVisits([visit.id]);
  final prescriptions = store.getPrescriptionsForVisits([visit.id]);
  final sittings = store.getSittingsForVisits([visit.id]);
  final files = store.getFilesForVisits([visit.id]);
  final payments = store.getPaymentsForVisits([visit.id]);

  sittings.sort((a, b) => a.sittingDate.compareTo(b.sittingDate));

  // Calculate totals consistently
  double totalAmount = 0;
  for (var s in sittings) totalAmount += (s.cost ?? 0);
  for (var p in prescriptions) totalAmount += (p.price ?? 0);
  for (var f in files) totalAmount += (f.price ?? 0);

  final double paidTotal = payments.fold<double>(
    0,
    (sum, p) => sum + p.amountPaid,
  );
  final double balance = totalAmount - paidTotal;
  final isOngoing = visit.status == 'ongoing';
  final canComplete = balance <= 0.01 && totalAmount > 0;

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
              if (treatments.isNotEmpty) ...[
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
                        if (t.description != null)
                          Text(
                            t.description!,
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
              ],
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
                final sPayments = payments.where((p) => p.sittingId == s.id);
                final sPaid = sPayments.fold<double>(
                  0,
                  (sum, p) => sum + p.amountPaid,
                );
                final isPaid = sPaid >= (s.cost ?? 0) - 0.01;
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
                final isPaid = p.payment != null;
                return _invoiceItemRow(
                  'Prescription: ${p.medicineName}',
                  ProfileTab.formatDate(p.createdAt ?? DateTime.now()),
                  p.price ?? 0,
                  isPaid ? 'Paid' : 'Pending',
                  isPaid ? Colors.green : Colors.red,
                );
              }),
              ...files.where((f) => (f.price ?? 0) > 0).map((f) {
                final isPaid = f.payment != null;
                return _invoiceItemRow(
                  'File: ${f.fileName}',
                  ProfileTab.formatDate(visit.visitDate),
                  f.price ?? 0,
                  isPaid ? 'Paid' : 'Pending',
                  isPaid ? Colors.green : Colors.red,
                );
              }),
              const Divider(height: 48),
              _invoiceSummaryRow('Total Amount:', totalAmount),
              _invoiceSummaryRow(
                'Amount Paid:',
                paidTotal,
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
                  Text(
                    '₹${(balance.abs() < 0.01 ? 0 : balance).toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: balance <= 0.01
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (isOngoing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: !canComplete
                          ? null
                          : () {
                              // Finalize Consultation
                              for (final t in treatments) {
                                store.updateTreatment(
                                  t.copyWith(status: 'Completed'),
                                );
                              }
                              store.updateVisit(
                                visit.copyWith(status: 'complete'),
                              );
                              Navigator.pop(context);
                              if (onComplete != null) onComplete();
                            },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Complete Consultation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
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
              '₹${amount.toStringAsFixed(0)}',
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
          '₹${amount.toStringAsFixed(0)}',
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
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${sitting.cost?.toStringAsFixed(0) ?? '0'}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C1D95),
              ),
            ),
            if ((sitting.cost ?? 0) > 0)
              Text(
                balance <= 0 ? 'Paid' : 'Pending',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: balance <= 0 ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sitting.notes != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      sitting.notes!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                if (balance > 0 && isOngoing)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          foregroundColor: Colors.green,
                        ),
                        onPressed: () {
                          LocalStore.instance.addPayment(
                            Payment(
                              id: 'mock_pay_${DateTime.now().millisecondsSinceEpoch}',
                              visitId: visitId,
                              sittingId: sitting.id,
                              amountPaid: balance,
                              paymentMode: 'Cash',
                              paymentDate: DateTime.now(),
                            ),
                          );
                          onRefresh();
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark Paid'),
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
