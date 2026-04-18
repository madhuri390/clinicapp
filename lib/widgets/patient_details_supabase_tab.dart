import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_detail_model.dart';
import '../repositories/visit_detail_repository.dart';
import '../widgets/patient_details_header.dart';
import '../widgets/patient_details_profile_tab.dart';

// ── Reference design constants (from referencedesign.html CSS) ────────────
const _cardRadius   = 28.0;
const _cardPadding  = EdgeInsets.all(18);
const _cardBorder   = kRefBorder;         // #EDF2F7
const _cardShadow   = BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 2));

const _badgePlanBg  = Color(0xFFFFF2E0);  // .badge-plan
const _badgePlanFg  = Color(0xFFC47B2E);
const _badgeCompBg  = Color(0xFFE0F7EF);  // .badge-complete
const _badgeCompFg  = Color(0xFF1E7B5C);

const _sittingBg    = Color(0xFFF8FAFE);  // .sitting-item
const _prescBg      = Color(0xFFF1F5F9);  // .prescription-chip
const _treatBg      = Color(0xFFF8FAFE);  // .treatment-chip

const _btnBorder    = Color(0xFFCBD5E1);  // .btn-outline-sm border
// ═══════════════════════════════════════════════════════════════════════════
// ONGOING TAB
// ═══════════════════════════════════════════════════════════════════════════

class OngoingTab extends StatelessWidget {
  const OngoingTab({
    super.key,
    required this.patientId,
    required this.visitDetails,
    required this.isLoading,
    required this.onRefresh,
    required this.onRefreshAll,
    this.onEditVisit,
    this.onComplete,
    this.readOnly = false,
  });

  final String patientId;
  final List<VisitDetail> visitDetails;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshAll;
  final void Function(VisitDetail)? onEditVisit;
  final VoidCallback? onComplete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (visitDetails.isEmpty) {
      return _EmptyState(
        icon: Icons.medical_services_outlined,
        message: 'No ongoing consultations',
        subtext: readOnly ? null : 'Tap "New" to start one.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      itemCount: visitDetails.length,
      itemBuilder: (_, i) => _VisitCard(
        detail: visitDetails[i],
        isOngoing: true,
        onRefresh: onRefresh,
        onEditVisit: onEditVisit != null ? () => onEditVisit!(visitDetails[i]) : null,
        onComplete: onComplete,
        readOnly: readOnly,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HISTORY TAB
// ═══════════════════════════════════════════════════════════════════════════

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.patientId,
    required this.visitDetails,
    required this.isLoading,
    required this.onRefresh,
    this.readOnly = false,
  });

  final String patientId;
  final List<VisitDetail> visitDetails;
  final bool isLoading;
  final VoidCallback onRefresh;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (visitDetails.isEmpty) {
      return const _EmptyState(
        icon: Icons.history,
        message: 'No past consultations',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
      itemCount: visitDetails.length,
      itemBuilder: (_, i) => _VisitCard(
        detail: visitDetails[i],
        isOngoing: false,
        onRefresh: onRefresh,
        readOnly: readOnly,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VISIT CARD  — .ongoing-item / .history-item
// ═══════════════════════════════════════════════════════════════════════════

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.detail,
    required this.isOngoing,
    required this.onRefresh,
    this.onEditVisit,
    this.onComplete,
    this.readOnly = false,
  });

  final VisitDetail detail;
  final bool isOngoing;
  final VoidCallback onRefresh;
  final VoidCallback? onEditVisit;
  final VoidCallback? onComplete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final repo = VisitDetailRepository();
    final totalPaid = detail.totalPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: _cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: _cardBorder),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: badge + date (.flex-between) ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Badge(isOngoing: isOngoing),
              Text(
                'Started: ${ProfileTab.formatDate(detail.visit.visitDate)}',
                style: GoogleFonts.lato(fontSize: 12, color: kRefMuted),
              ),
            ],
          ),

          // ── Row 2: title (h3) ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              detail.visit.chiefComplaint ?? 'General Checkup',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kRefDark,
              ),
            ),
          ),

          // ── Row 3: diagnosis (.text-muted) ─────────────────────────
          Text(
            detail.visit.diagnosis ?? 'Pending diagnosis',
            style: GoogleFonts.lato(fontSize: 12, color: kRefMuted),
          ),

          // ── Sittings list ─────────────────────────────────────────
          if (detail.sittings.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...detail.sittings.map((s) => _SittingItem(
              sitting: s,
              repo: repo,
              onRefresh: onRefresh,
              readOnly: readOnly,
            )),
          ],

          // ── Prescriptions as chips ────────────────────────────────
          if (detail.prescriptions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              children: detail.prescriptions
                  .map((rx) => _PrescriptionChip(rx: rx))
                  .toList(),
            ),
          ],

          // ── Treatment chips (per treatment plan) ──────────────────
          if (detail.treatments.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...detail.treatments.map(
              (t) => _TreatmentChip(
                treatment: t,
                sittingCount: detail.sittingsForTreatment(t.id).length,
              ),
            ),
          ],

          // ── Action buttons (.action-buttons) ──────────────────────
          if (isOngoing && !readOnly) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _BtnOutlineSm(
                  icon: Icons.calendar_today_outlined,
                  label: 'Add Sitting',
                  onTap: () => _showAddSitting(context, repo),
                ),
                _BtnOutlineSm(
                  icon: Icons.medication_outlined,
                  label: 'Add Prescription',
                  onTap: () => _showAddPrescription(context, repo),
                ),
              ],
            ),
          ],

          // ── Footer: amount chip + primary button (.card-footer) ───
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // .amount-chip — shows total cost of all sittings
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _sittingBg,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  detail.totalCost > 0
                      ? 'Total: ₹${detail.totalCost.toStringAsFixed(0)}'
                      : totalPaid > 0
                          ? 'Total: ₹${totalPaid.toStringAsFixed(0)}'
                          : '₹0',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kRefDark,
                  ),
                ),
              ),
              if (!readOnly)
                isOngoing
                    ? _BtnPrimarySm(
                        icon: Icons.check_circle_outline,
                        label: 'Complete Treatment',
                        onTap: () => _onComplete(context, repo),
                      )
                    : _BtnPrimarySm(
                        icon: Icons.receipt_long_outlined,
                        label: 'View Bill',
                        onTap: () => _showBill(context),
                      ),
            ],
          ),
        ],
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  void _showAddSitting(BuildContext context, VisitDetailRepository repo) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ModalDialog(
        title: 'Add Sitting',
        icon: Icons.calendar_today_outlined,
        child: _AddSittingForm(
          visitId: detail.visit.id,
          treatmentPlanId: detail.treatments.isNotEmpty
              ? detail.treatments.first.id
              : null,
          repo: repo,
          onSaved: onRefresh,
        ),
      ),
    );
  }

  void _showAddPrescription(BuildContext context, VisitDetailRepository repo) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ModalDialog(
        title: 'Add Prescription',
        icon: Icons.medication_outlined,
        child: _AddPrescriptionForm(
          visitId: detail.visit.id,
          treatmentPlanId: detail.treatments.isNotEmpty
              ? detail.treatments.first.id
              : null,
          repo: repo,
          onSaved: onRefresh,
        ),
      ),
    );
  }

  Future<void> _onComplete(BuildContext context, VisitDetailRepository repo) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _ModalDialog(
        title: 'Complete Consultation?',
        icon: Icons.check_circle_outline,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will mark the consultation as completed.',
              style: GoogleFonts.lato(fontSize: 14, color: kRefMuted),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BtnOutlineSm(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(ctx, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BtnPrimarySm(
                    label: 'Complete',
                    onTap: () => Navigator.pop(ctx, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await repo.completeVisit(detail.visit.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation completed'), backgroundColor: Color(0xFF1E7B5C)),
        );
      }
      onRefresh();
      onComplete?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showBill(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _BillDialog(detail: detail),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BADGE  — .badge-plan / .badge-complete
// ═══════════════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  const _Badge({required this.isOngoing});
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    final bg = isOngoing ? _badgePlanBg : _badgeCompBg;
    final fg = isOngoing ? _badgePlanFg : _badgeCompFg;
    final icon = isOngoing ? Icons.hourglass_top_rounded : Icons.check_circle;
    final text = isOngoing ? 'In Progress' : 'Completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SITTING ITEM  — .sitting-item
// ═══════════════════════════════════════════════════════════════════════════

class _SittingItem extends StatelessWidget {
  const _SittingItem({
    required this.sitting,
    required this.repo,
    required this.onRefresh,
    this.readOnly = false,
  });
  final Sitting sitting;
  final VisitDetailRepository repo;
  final VoidCallback onRefresh;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isPaid = sitting.status.toLowerCase() == 'completed' ||
        sitting.status.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _sittingBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sitting.notes ?? 'Sitting',
                  style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefDark),
                ),
                Text(
                  ProfileTab.formatDate(sitting.sittingDate),
                  style: GoogleFonts.lato(fontSize: 10, color: kRefMuted),
                ),
              ],
            ),
          ),
          if ((sitting.cost ?? 0) > 0) ...[
            Text(
              '₹${sitting.cost!.toStringAsFixed(0)}',
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefPrimary),
            ),
            const SizedBox(width: 12),
          ],
          // Tappable payment status toggle
          GestureDetector(
            onTap: readOnly ? null : () => _togglePayment(context, isPaid),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? _badgeCompBg : _badgePlanBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Pending',
                style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w600, color: isPaid ? _badgeCompFg : _badgePlanFg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePayment(BuildContext context, bool currentlyPaid) async {
    final newStatus = currentlyPaid ? 'Scheduled' : 'Completed';
    try {
      await repo.updateSittingStatus(sitting.id, newStatus);
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment marked as ${currentlyPaid ? 'Pending' : 'Paid'}'),
            backgroundColor: currentlyPaid ? _badgePlanFg : _badgeCompFg,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PRESCRIPTION CHIP  — .prescription-chip
// ═══════════════════════════════════════════════════════════════════════════

class _PrescriptionChip extends StatelessWidget {
  const _PrescriptionChip({required this.rx});
  final Prescription rx;

  @override
  Widget build(BuildContext context) {
    final display = [
      rx.medicineName ?? '',
      if (rx.dosage != null) rx.dosage!,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _prescBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medication_outlined, size: 10, color: kRefPrimary),
          const SizedBox(width: 6),
          Text(
            display,
            style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w500, color: kRefDark),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  TREATMENT CHIP  — .treatment-chip
// ═══════════════════════════════════════════════════════════════════════════

class _TreatmentChip extends StatelessWidget {
  const _TreatmentChip({required this.treatment, required this.sittingCount});
  final TreatmentPlan treatment;
  final int sittingCount;

  @override
  Widget build(BuildContext context) {
    final status = treatment.status ?? 'planned';
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _treatBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${treatment.treatmentName ?? 'Treatment'} · $sittingCount sitting${sittingCount == 1 ? '' : 's'} · ${status[0].toUpperCase()}${status.substring(1)}',
        style: GoogleFonts.lato(fontSize: 12, color: kRefDark),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BUTTON SYSTEM  — .btn-outline-sm / .btn-primary-sm
// ═══════════════════════════════════════════════════════════════════════════

class _BtnOutlineSm extends StatelessWidget {
  const _BtnOutlineSm({required this.label, this.icon, required this.onTap});
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: _btnBorder),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: kRefPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _BtnPrimarySm extends StatelessWidget {
  const _BtnPrimarySm({
    required this.label,
    this.icon,
    required this.onTap,
  });
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kRefPrimary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: kRefPrimary.withValues(alpha: 0.20), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODAL DIALOG  — .modal-overlay + .modal-container (32px radius, centered)
// ═══════════════════════════════════════════════════════════════════════════

class _ModalDialog extends StatelessWidget {
  const _ModalDialog({required this.title, this.icon, required this.child});
  final String title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // .modal-container h3
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: kRefPrimary),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kRefDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODAL INPUT FIELD  — .modal-container input
// ═══════════════════════════════════════════════════════════════════════════

class _ModalField extends StatelessWidget {
  const _ModalField({
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.lato(fontSize: 14, color: kRefDark),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.lato(fontSize: 14, color: kRefMuted),
          filled: false,
          contentPadding: const EdgeInsets.all(12),
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

// ═══════════════════════════════════════════════════════════════════════════
//  ADD SITTING FORM (inside modal)
// ═══════════════════════════════════════════════════════════════════════════

class _AddSittingForm extends StatefulWidget {
  const _AddSittingForm({
    required this.visitId,
    this.treatmentPlanId,
    required this.repo,
    required this.onSaved,
  });
  final String visitId;
  final String? treatmentPlanId;
  final VisitDetailRepository repo;
  final VoidCallback onSaved;

  @override
  State<_AddSittingForm> createState() => _AddSittingFormState();
}

class _AddSittingFormState extends State<_AddSittingForm> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() { _nameCtrl.dispose(); _costCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final sitting = Sitting(
        id: '',
        visitId: widget.visitId,
        treatmentPlanId: widget.treatmentPlanId,
        sittingDate: _date,
        durationStr: '30 mins',
        notes: _nameCtrl.text.trim(),
        cost: double.tryParse(_costCtrl.text.trim()) ?? 0,
      );
      await widget.repo.addSitting(sitting);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModalField(controller: _nameCtrl, placeholder: 'Sitting name (e.g., Fluoride Application)'),
        _ModalField(controller: _costCtrl, placeholder: 'Cost (₹)', keyboardType: TextInputType.number),
        GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d != null) setState(() => _date = d);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Text(
              '${_date.day}/${_date.month}/${_date.year}',
              style: GoogleFonts.lato(fontSize: 14, color: kRefDark),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _BtnOutlineSm(label: 'Cancel', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
            _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : _BtnPrimarySm(label: 'Add Sitting', onTap: _save),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ADD PRESCRIPTION FORM (inside modal)
// ═══════════════════════════════════════════════════════════════════════════

class _AddPrescriptionForm extends StatefulWidget {
  const _AddPrescriptionForm({
    required this.visitId,
    this.treatmentPlanId,
    required this.repo,
    required this.onSaved,
  });
  final String visitId;
  final String? treatmentPlanId;
  final VisitDetailRepository repo;
  final VoidCallback onSaved;

  @override
  State<_AddPrescriptionForm> createState() => _AddPrescriptionFormState();
}

class _AddPrescriptionFormState extends State<_AddPrescriptionForm> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instrCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _nameCtrl.dispose(); _dosageCtrl.dispose(); _instrCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final rx = Prescription(
        id: '',
        visitId: widget.visitId,
        treatmentPlanId: widget.treatmentPlanId,
        medicineName: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
        instructions: _instrCtrl.text.trim().isEmpty ? null : _instrCtrl.text.trim(),
      );
      await widget.repo.addPrescription(rx);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModalField(controller: _nameCtrl, placeholder: 'Medication name'),
        _ModalField(controller: _dosageCtrl, placeholder: 'Dosage (e.g., 1-0-1 = Morning & Night)'),
        _ModalField(controller: _instrCtrl, placeholder: 'Instructions (e.g., after meals)', maxLines: 2),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _BtnOutlineSm(label: 'Cancel', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
            _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : _BtnPrimarySm(label: 'Add Prescription', onTap: _save),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  BILL DIALOG  — .bill-preview
// ═══════════════════════════════════════════════════════════════════════════

class _BillDialog extends StatelessWidget {
  const _BillDialog({required this.detail});
  final VisitDetail detail;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinic header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Prodontics Clinic',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kRefPrimary,
                      ),
                    ),
                    Text(
                      'Professional Dental Care',
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: kRefPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _billRow('Visit Date', ProfileTab.formatDate(detail.visit.visitDate)),
              _billRow('Complaint', detail.visit.chiefComplaint ?? '-'),
              _billRow('Doctor', detail.doctorName),
              const Divider(height: 24),
              Text(
                'Treatments',
                style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, color: kRefDark),
              ),
              const SizedBox(height: 8),
              ...detail.treatments.map(
                (t) => _billRow(
                  t.treatmentName ?? '',
                  '₹${(t.totalCost ?? 0).toStringAsFixed(0)}',
                ),
              ),
              const Divider(height: 24),
              _billRow('Total Sittings', '${detail.sittings.length}'),
              _billRow(
                'Amount Paid',
                '₹${detail.totalPaid.toStringAsFixed(0)}',
                bold: true,
              ),
              if (detail.balance > 0.01)
                _billRow(
                  'Balance Due',
                  '₹${detail.balance.toStringAsFixed(0)}',
                  color: Colors.red,
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.lato(
                      color: kRefPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 13, color: kRefMuted),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? kRefDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message, this.subtext});
  final IconData icon;
  final String message;
  final String? subtext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w600, color: kRefMuted),
              textAlign: TextAlign.center,
            ),
            if (subtext != null) ...[
              const SizedBox(height: 8),
              Text(
                subtext!,
                style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
