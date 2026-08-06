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
import '../theme/app_tokens.dart';

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
    this.readOnly = false,
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

  /// Patient portal: hide edit / add / complete / payment actions.
  final bool readOnly;

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
                      style: GoogleFonts.plusJakartaSans(
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
                    color: isOngoing ? Colors.black : AppTokens.hairline,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isOngoing ? 'Ongoing' : 'Completed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOngoing ? Colors.white : AppTokens.ink,
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlueBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnosis',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              visit.diagnosis ?? 'Pending diagnosis',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: AppTheme.primaryColor.withValues(alpha: 0.8),
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
          const SizedBox(height: 24),
          Divider(height: 1, color: AppTokens.hairline),
          if (treatments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Treatments planned',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Column(
                    children: treatments
                        .map(
                          (t) => _TreatmentAccordion(
                            treatment: t,
                            prescriptions: prescriptions
                                .where((p) => p.treatmentPlanId == t.id)
                                .toList(),
                            files:
                                LocalStore.instance.getFilesForTreatment(t.id),
                            sittings: sittings
                                .where((s) => s.treatmentPlanId == t.id)
                                .toList(),
                            payments: payments,
                            onRefresh: onRefresh,
                            isOngoing: isOngoing,
                            readOnly: readOnly,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isOngoing && !readOnly) ...[
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
                  Divider(height: 1, color: AppTokens.hairline),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount Paid:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink,
                      ),
                    ),
                    Text(
                      '₹${payments.fold<double>(0, (sum, p) => sum + p.amountPaid).toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.success,
                      ),
                    ),
                  ],
                ),
                if (!readOnly) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOngoing
                            ? (canComplete
                                  ? AppTokens.success
                                  : AppTokens.muted)
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
                                readOnly: readOnly,
                              );
                            },
                      icon: Icon(
                        isOngoing ? Icons.check_circle : Icons.receipt_long,
                        size: 18,
                      ),
                      label: Text(
                        isOngoing ? 'Complete Consultation' : 'Generate Bill',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
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
    this.readOnly = false,
  });

  final TreatmentPlan treatment;
  final List<Prescription> prescriptions;
  final List<FileAttachment> files;
  final List<dynamic> sittings;
  final List<Payment> payments;
  final VoidCallback onRefresh;
  final bool isOngoing;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTokens.hairline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: AppTokens.muted,
          iconColor: AppTokens.muted,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTokens.successSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: AppTokens.success,
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink,
                      ),
                    ),
                    Text(
                      '${sittings.length} sittings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTokens.muted,
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
                  color: AppTokens.subtle,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  treatment.status ?? 'planned',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTokens.body,
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTokens.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    treatment.description ?? 'No description provided.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppTokens.body,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isOngoing && !readOnly) ...[
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
                            label: const Text('Add Medication'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: AppTokens.hairline),
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...prescriptions.map(
                      (p) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTokens.accentSofter,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.medication,
                                  color: AppTokens.accentDark,
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
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        p.dosage ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppTokens.accentDark,
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
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTokens.accentDeep,
                                      ),
                                    ),
                                    if ((p.price ?? 0) > 0)
                                      Text(
                                        p.payment != null ? 'Paid' : 'Pending',
                                        style: GoogleFonts.plusJakartaSans(
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
                            if (isOngoing && !readOnly) ...[
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
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTokens.accentDark,
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
                                        style: GoogleFonts.plusJakartaSans(
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
                    readOnly: readOnly,
                  ),
                  const SizedBox(height: 8),
                  _SittingsList(
                    visitId: treatment.visitId,
                    sittings: sittings,
                    onRefresh: onRefresh,
                    isOngoing: isOngoing,
                    readOnly: readOnly,
                  ),
                  if (files.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Attached Files',
                      style: GoogleFonts.plusJakartaSans(
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
                                  color: AppTokens.warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        f.fileName ?? 'Unnamed File',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                        ),
                                      ),
                                      if ((f.price ?? 0) > 0)
                                        Text(
                                          '₹${f.price!.toStringAsFixed(0)} • ${f.payment != null ? 'Paid' : 'Pending'}',
                                          style: GoogleFonts.plusJakartaSans(
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
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                            if (isOngoing && !readOnly)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

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
                                        style: GoogleFonts.plusJakartaSans(
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
        backgroundColor: AppTheme.primaryColor,
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
    this.iconColor = AppTheme.primaryColor,
    this.textColor = AppTokens.ink,
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTokens.subtle,
          border: Border.all(color: AppTokens.hairline),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
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
      title: 'Add Medication',
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
            label: 'Save Medication',
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


void _showBillPreview(
  BuildContext context,
  Visit visit, {
  VoidCallback? onComplete,
  bool readOnly = false,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  color: AppTheme.lightBlueBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Prodontics Clinic',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'Professional Dental Care',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
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
                  _invoiceInfoRow('Doctor', 'Doctor'),
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.ink,
                  ),
                ),
                const SizedBox(height: 12),
                ...treatments.map(
                  (t) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTokens.subtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.treatmentName ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.ink,
                          ),
                        ),
                        if (t.description != null)
                          Text(
                            t.description!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTokens.body,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.ink,
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
                color: AppTokens.success,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance Due:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.ink,
                    ),
                  ),
                  Text(
                    '₹${(balance.abs() < 0.01 ? 0 : balance).toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: balance <= 0.01
                          ? AppTokens.success
                          : AppTokens.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (isOngoing && !readOnly)
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
                        backgroundColor: AppTokens.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
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
                        backgroundColor: AppTokens.ink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTokens.muted),
      ),
      Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTokens.ink,
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.ink,
                ),
              ),
              Text(
                date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTokens.muted,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTokens.body,
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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTokens.ink,
              ),
            ),
            Text(
              status,
              style: GoogleFonts.plusJakartaSans(
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
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTokens.body),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color ?? AppTokens.ink,
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
          backgroundColor: AppTokens.ink,
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
                style: GoogleFonts.plusJakartaSans(
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: AppTokens.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTokens.ink,
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
    this.readOnly = false,
  });

  final String visitId;
  final String treatmentId;
  final VoidCallback onRefresh;
  final bool isOngoing;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Sittings',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTokens.ink,
          ),
        ),
        if (isOngoing && !readOnly)
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
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
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
    this.readOnly = false,
  });

  final String visitId;
  final List<dynamic> sittings;
  final VoidCallback onRefresh;
  final bool isOngoing;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (sittings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No sittings recorded yet.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTokens.muted),
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
              readOnly: readOnly,
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
    this.readOnly = false,
  });

  final String visitId;
  final Sitting sitting;
  final VoidCallback onRefresh;
  final bool isOngoing;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final payments = LocalStore.instance.getPaymentsForSitting(sitting.id);
    final paidAmount = payments.fold<double>(0, (sum, p) => sum + p.amountPaid);
    final balance = (sitting.cost ?? 0) - paidAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.subtle),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          'Sitting - ${ProfileTab.formatDate(sitting.sittingDate)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTokens.ink,
          ),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${sitting.cost?.toStringAsFixed(0) ?? '0'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTokens.accentDeep,
              ),
            ),
            if ((sitting.cost ?? 0) > 0)
              Text(
                balance <= 0 ? 'Paid' : 'Pending',
                style: GoogleFonts.plusJakartaSans(
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTokens.body,
                      ),
                    ),
                  ),
                if (balance > 0 && isOngoing && !readOnly)
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
