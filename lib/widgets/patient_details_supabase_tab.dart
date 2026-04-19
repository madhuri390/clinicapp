import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/treatment_template_model.dart';
import '../models/visit_detail_model.dart';
import '../repositories/visit_detail_repository.dart';
import '../services/pdf_generator_service.dart';
import '../widgets/patient_details_header.dart';
import '../widgets/patient_details_profile_tab.dart';

// ── Reference design constants ──────────────────────────────────────────
const _cardRadius   = 28.0;
const _cardPadding  = EdgeInsets.all(18);
const _cardBorder   = kRefBorder;
const _cardShadow   = BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 2));

const _badgePlanBg  = Color(0xFFFFF2E0);
const _badgePlanFg  = Color(0xFFC47B2E);
const _badgeCompBg  = Color(0xFFE0F7EF);
const _badgeCompFg  = Color(0xFF1E7B5C);

const _sittingBg    = Color(0xFFF8FAFE);
const _prescBg      = Color(0xFFF1F5F9);
const _treatBg      = Color(0xFFF8FAFE);
const _btnBorder    = Color(0xFFCBD5E1);

// ═══════════════════════════════════════════════════════════════════════════
// ONGOING TAB
// ═══════════════════════════════════════════════════════════════════════════

class OngoingTab extends StatelessWidget {
  const OngoingTab({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.visitDetails,
    required this.isLoading,
    required this.onRefresh,
    required this.onRefreshAll,
    this.onEditVisit,
    this.onComplete,
    this.readOnly = false,
  });

  final String patientId;
  final String patientName;
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
        patientName: patientName,
        isOngoing: true,
        onRefresh: onRefresh,
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
    required this.patientName,
    required this.visitDetails,
    required this.isLoading,
    required this.onRefresh,
    this.readOnly = false,
  });

  final String patientId;
  final String patientName;
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
        patientName: patientName,
        isOngoing: false,
        onRefresh: onRefresh,
        readOnly: readOnly,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// VISIT CARD — the core widget, renders one visit with full hierarchy
// ═══════════════════════════════════════════════════════════════════════════

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.detail,
    required this.patientName,
    required this.isOngoing,
    required this.onRefresh,
    this.onComplete,
    this.readOnly = false,
  });

  final VisitDetail detail;
  final String patientName;
  final bool isOngoing;
  final VoidCallback onRefresh;
  final VoidCallback? onComplete;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final repo = VisitDetailRepository();

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
          // ── Row 1: badge + date ──────────────────────────────────
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

          // ── Row 2: title ──────────────────────────────────────────
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

          // ── Row 3: doctor · diagnosis ─────────────────────────────
          Text(
            '${detail.doctorName} · ${detail.visit.diagnosis ?? 'Pending diagnosis'}',
            style: GoogleFonts.lato(fontSize: 12, color: kRefMuted),
          ),

          // ── Treatment sections (grouped sittings) ─────────────────
          if (detail.treatments.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...detail.treatments.map(
              (t) {
                // Treatment is paid only if there is a direct treatment-level payment
                // (sittingId == null). Sitting-level payments must NOT affect this.
                final treatmentPaid = detail.payments.any(
                  (p) => p.treatmentPlanId == t.id && p.sittingId == null,
                );
                return _TreatmentSection(
                  treatment: t,
                  sittings: detail.sittingsForTreatment(t.id),
                  visitId: detail.visit.id,
                  isPaid: treatmentPaid,
                  repo: repo,
                  onRefresh: onRefresh,
                  readOnly: readOnly,
                );
              },
            ),
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

          // ── Action buttons ────────────────────────────────────────
          if (isOngoing && !readOnly) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _BtnOutlineSm(
                  icon: Icons.add_circle_outline,
                  label: 'Add Treatment',
                  onTap: () => _showAddTreatment(context, repo),
                ),
                if (detail.treatments.isNotEmpty)
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
                _BtnOutlineSm(
                  icon: Icons.payment_outlined,
                  label: 'Add Payment',
                  onTap: () => _showAddPayment(context, repo),
                ),
              ],
            ),
          ],

          // ── Footer: amount chip row ───────────────────────────────
          const SizedBox(height: 16),
          // Amount chip — always full width on its own row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _sittingBg,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              _buildAmountLabel(),
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kRefDark,
              ),
            ),
          ),
          // ── Action button row — right-aligned on its own row ───────
          if (!readOnly) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: isOngoing
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
            ),
          ],
        ],
      ),
    );
  }

  String _buildAmountLabel() {
    final treatCost = detail.totalTreatmentCost;
    final sitCost = detail.totalSittingsCost;
    final grandTotal = treatCost + sitCost;
    final paid = _effectivePaid();
    if (grandTotal > 0) {
      return 'Total: ₹${grandTotal.toStringAsFixed(0)} · Paid: ₹${paid.toStringAsFixed(0)}';
    }
    if (paid > 0) {
      return 'Paid: ₹${paid.toStringAsFixed(0)}';
    }
    return '₹0';
  }

  /// Sums explicit payment records + paid sitting costs that don't yet have
  /// a linked payment record (e.g. sittings toggled before auto-payment).
  double _effectivePaid() {
    final fromPayments = detail.totalPaid;
    // sitting IDs already covered by a payment record
    final coveredSittingIds = detail.payments
        .where((p) => p.sittingId != null)
        .map((p) => p.sittingId!)
        .toSet();
    final fromUnlinkedSittings = detail.sittings
        .where(
          (s) =>
              (s.status.toLowerCase() == 'completed' ||
                  s.status.toLowerCase() == 'paid') &&
              !coveredSittingIds.contains(s.id) &&
              (s.cost ?? 0) > 0,
        )
        .fold(0.0, (sum, s) => sum + s.cost!);
    return fromPayments + fromUnlinkedSittings;
  }

  // ── Dialog helpers ────────────────────────────────────────────────────

  void _showAddTreatment(BuildContext context, VisitDetailRepository repo) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ModalDialog(
        title: 'Add Treatment',
        icon: Icons.add_circle_outline,
        child: _AddTreatmentForm(
          visitId: detail.visit.id,
          repo: repo,
          onSaved: onRefresh,
        ),
      ),
    );
  }

  void _showAddSitting(BuildContext context, VisitDetailRepository repo) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ModalDialog(
        title: 'Add Sitting',
        icon: Icons.calendar_today_outlined,
        child: _AddSittingForm(
          visitId: detail.visit.id,
          treatments: detail.treatments,
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

  void _showAddPayment(BuildContext context, VisitDetailRepository repo) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ModalDialog(
        title: 'Add Payment',
        icon: Icons.payment_outlined,
        child: _AddPaymentForm(
          visitId: detail.visit.id,
          repo: repo,
          onSaved: onRefresh,
        ),
      ),
    );
  }

  Future<void> _onComplete(BuildContext context, VisitDetailRepository repo) async {
    final treatCost = detail.totalTreatmentCost;
    final sitCost = detail.totalSittingsCost;
    final rxCost = detail.prescriptions.fold(0.0, (s, rx) => s + (rx.price ?? 0));
    final grandTotal = treatCost + sitCost + rxCost;
    final paid = _effectivePaid();
    final balance = grandTotal - paid;

    if (balance > 0) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.black54,
          builder: (ctx) => _ModalDialog(
            title: 'Outstanding Balance',
            icon: Icons.error_outline,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cannot complete consultation. There is an outstanding balance of ₹${balance.toStringAsFixed(0)}. Please collect payment first.',
                  style: GoogleFonts.lato(fontSize: 14, color: kRefMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _BtnPrimarySm(
                  label: 'OK',
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      }
      return;
    }

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
              'This will mark the consultation as completed and move it to History.',
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
          const SnackBar(
            content: Text('Consultation completed'),
            backgroundColor: Color(0xFF1E7B5C),
          ),
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
      builder: (_) => _BillDialog(detail: detail, patientName: patientName),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TREATMENT SECTION — one treatment with its sittings grouped below
// ═══════════════════════════════════════════════════════════════════════════

class _TreatmentSection extends StatelessWidget {
  const _TreatmentSection({
    required this.treatment,
    required this.sittings,
    required this.visitId,
    required this.isPaid,
    required this.repo,
    required this.onRefresh,
    this.readOnly = false,
  });
  final TreatmentPlan treatment;
  final List<Sitting> sittings;
  final String visitId;
  final bool isPaid;
  final VisitDetailRepository repo;
  final VoidCallback onRefresh;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final status = treatment.status ?? 'planned';
    final hasCost = (treatment.totalCost ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _treatBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFF3F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Treatment header row: name | status pill | payment toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  treatment.treatmentName ?? 'Treatment',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kRefDark,
                  ),
                ),
              ),
              _StatusPill(label: status),
              if (!readOnly && hasCost) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _togglePayment(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPaid ? _badgeCompBg : _badgePlanBg,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isPaid ? 'Paid' : 'Pending',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPaid ? _badgeCompFg : _badgePlanFg,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Cost + sittings count subtitle
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              hasCost
                  ? '₹${treatment.totalCost!.toStringAsFixed(0)} · ${sittings.length} sitting${sittings.length == 1 ? '' : 's'}'
                  : '${sittings.length} sitting${sittings.length == 1 ? '' : 's'}',
              style: GoogleFonts.lato(fontSize: 11, color: kRefMuted),
            ),
          ),
          // Sittings grouped under this treatment
          if (sittings.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...sittings.map((s) => _SittingItem(
              sitting: s,
              visitId: visitId,
              repo: repo,
              onRefresh: onRefresh,
              readOnly: readOnly,
            )),
          ],
        ],
      ),
    );
  }

  Future<void> _togglePayment(BuildContext context) async {
    if (isPaid) {
      // Already paid — show info snackbar, no reverse action
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment already recorded for ${treatment.treatmentName ?? 'treatment'}'),
            backgroundColor: _badgeCompFg,
          ),
        );
      }
      return;
    }
    // Mark as paid → add a UPI payment for the full treatment cost
    try {
      final payment = Payment(
        id: '',
        visitId: visitId,
        treatmentPlanId: treatment.id,
        amountPaid: treatment.totalCost ?? 0,
        paymentMode: 'UPI',
        paymentDate: DateTime.now(),
      );
      await repo.addPayment(payment);
      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment of ₹${treatment.totalCost!.toStringAsFixed(0)} recorded via UPI',
            ),
            backgroundColor: _badgeCompFg,
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
// STATUS PILL — small pill for treatment status
// ═══════════════════════════════════════════════════════════════════════════

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isComplete = label.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isComplete ? _badgeCompBg : _badgePlanBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1),
        style: GoogleFonts.lato(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isComplete ? _badgeCompFg : _badgePlanFg,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BADGE — .badge-plan / .badge-complete
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
// SITTING ITEM
// ═══════════════════════════════════════════════════════════════════════════

class _SittingItem extends StatelessWidget {
  const _SittingItem({
    required this.sitting,
    required this.visitId,
    required this.repo,
    required this.onRefresh,
    this.readOnly = false,
  });
  final Sitting sitting;
  final String visitId;
  final VisitDetailRepository repo;
  final VoidCallback onRefresh;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isPaid = sitting.status.toLowerCase() == 'completed' ||
        sitting.status.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          GestureDetector(
            onTap: readOnly ? null : () => _toggleStatus(context, isPaid),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? _badgeCompBg : _badgePlanBg,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Pending',
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPaid ? _badgeCompFg : _badgePlanFg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(BuildContext context, bool currentlyPaid) async {
    final newStatus = currentlyPaid ? 'Scheduled' : 'Completed';
    try {
      // 1. Update sitting status
      await repo.updateSittingStatus(sitting.id, newStatus);

      // 2. When marking as Paid, auto-create a UPI payment for this sitting's cost
      if (!currentlyPaid && (sitting.cost ?? 0) > 0) {
        final payment = Payment(
          id: '',
          visitId: visitId,
          treatmentPlanId: sitting.treatmentPlanId,
          sittingId: sitting.id,
          amountPaid: sitting.cost!,
          paymentMode: 'UPI',
          paymentDate: DateTime.now(),
        );
        await repo.addPayment(payment);
      }

      onRefresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentlyPaid
                  ? 'Sitting marked as Pending'
                  : 'Sitting paid via UPI (₹${(sitting.cost ?? 0).toStringAsFixed(0)})',
            ),
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
// PRESCRIPTION CHIP
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
// BUTTON SYSTEM
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
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
  const _BtnPrimarySm({required this.label, this.icon, required this.onTap});
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
// MODAL DIALOG
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
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22, color: kRefPrimary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w700, color: kRefDark),
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
// MODAL INPUT FIELD
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
// ADD TREATMENT FORM — picks from templates or custom entry
// ═══════════════════════════════════════════════════════════════════════════

class _AddTreatmentForm extends StatefulWidget {
  const _AddTreatmentForm({
    required this.visitId,
    required this.repo,
    required this.onSaved,
  });
  final String visitId;
  final VisitDetailRepository repo;
  final VoidCallback onSaved;

  @override
  State<_AddTreatmentForm> createState() => _AddTreatmentFormState();
}

class _AddTreatmentFormState extends State<_AddTreatmentForm> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  List<TreatmentTemplate>? _templates;
  TreatmentTemplate? _selected;
  bool _saving = false;
  bool _loadingTemplates = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final t = await widget.repo.getTreatmentTemplates();
      if (mounted) setState(() { _templates = t; _loadingTemplates = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTemplates = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _selectTemplate(TreatmentTemplate t) {
    setState(() {
      _selected = t;
      _nameCtrl.text = t.name;
      _descCtrl.text = t.description ?? '';
      _costCtrl.text = t.defaultCost > 0 ? t.defaultCost.toStringAsFixed(0) : '';
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final plan = TreatmentPlan(
        id: '',
        visitId: widget.visitId,
        treatmentName: name,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        totalCost: double.tryParse(_costCtrl.text.trim()) ?? 0,
        status: 'planned',
      );
      await widget.repo.addTreatment(plan);
      if (mounted) Navigator.pop(context);
      widget.onSaved();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Template picker
        if (_loadingTemplates)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          )
        else if (_templates != null && _templates!.isNotEmpty) ...[
          Text('Select template:', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _templates!.map((t) {
              final selected = _selected?.id == t.id;
              return GestureDetector(
                onTap: () => _selectTemplate(t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? kRefPrimary : Colors.white,
                    border: Border.all(color: selected ? kRefPrimary : _btnBorder),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    t.name,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : kRefDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text('Or enter custom:', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefMuted)),
          const SizedBox(height: 8),
        ],
        _ModalField(controller: _nameCtrl, placeholder: 'Treatment name *'),
        _ModalField(controller: _descCtrl, placeholder: 'Description (optional)'),
        _ModalField(controller: _costCtrl, placeholder: 'Cost (₹)', keyboardType: TextInputType.number),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _BtnOutlineSm(label: 'Cancel', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
            _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : _BtnPrimarySm(label: 'Add Treatment', onTap: _save),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADD SITTING FORM — requires treatment selection
// ═══════════════════════════════════════════════════════════════════════════

class _AddSittingForm extends StatefulWidget {
  const _AddSittingForm({
    required this.visitId,
    required this.treatments,
    required this.repo,
    required this.onSaved,
  });
  final String visitId;
  final List<TreatmentPlan> treatments;
  final VisitDetailRepository repo;
  final VoidCallback onSaved;

  @override
  State<_AddSittingForm> createState() => _AddSittingFormState();
}

class _AddSittingFormState extends State<_AddSittingForm> {
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  late String _selectedTreatmentId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedTreatmentId = widget.treatments.first.id;
  }

  @override
  void dispose() { _nameCtrl.dispose(); _costCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final sitting = Sitting(
        id: '',
        visitId: widget.visitId,
        treatmentPlanId: _selectedTreatmentId,
        sittingDate: _date,
        notes: _nameCtrl.text.trim(),
        cost: double.tryParse(_costCtrl.text.trim()),
      );
      await widget.repo.addSitting(sitting);
      if (mounted) Navigator.pop(context);
      widget.onSaved();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Treatment selector
        if (widget.treatments.length > 1) ...[
          Text('Under treatment:', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.treatments.map((t) {
              final selected = t.id == _selectedTreatmentId;
              return GestureDetector(
                onTap: () => setState(() => _selectedTreatmentId = t.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? kRefPrimary : Colors.white,
                    border: Border.all(color: selected ? kRefPrimary : _btnBorder),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    t.treatmentName ?? 'Treatment',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : kRefDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],
        _ModalField(controller: _nameCtrl, placeholder: 'Sitting name *'),
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
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: kRefPrimary),
                const SizedBox(width: 8),
                Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: GoogleFonts.lato(fontSize: 14, color: kRefDark),
                ),
              ],
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
// ADD PRESCRIPTION FORM
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
      if (mounted) Navigator.pop(context);
      widget.onSaved();
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
        _ModalField(controller: _nameCtrl, placeholder: 'Medication name *'),
        _ModalField(controller: _dosageCtrl, placeholder: 'Dosage (e.g., 1-0-1)'),
        _ModalField(controller: _instrCtrl, placeholder: 'Instructions', maxLines: 2),
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
// ADD PAYMENT FORM — visit-level payments
// ═══════════════════════════════════════════════════════════════════════════

class _AddPaymentForm extends StatefulWidget {
  const _AddPaymentForm({
    required this.visitId,
    required this.repo,
    required this.onSaved,
  });
  final String visitId;
  final VisitDetailRepository repo;
  final VoidCallback onSaved;

  @override
  State<_AddPaymentForm> createState() => _AddPaymentFormState();
}

class _AddPaymentFormState extends State<_AddPaymentForm> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _paymentMode = 'Cash';
  bool _saving = false;

  @override
  void dispose() { _amountCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    try {
      final payment = Payment(
        id: '',
        visitId: widget.visitId,
        amountPaid: amount,
        paymentMode: _paymentMode,
        paymentDate: DateTime.now(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await widget.repo.addPayment(payment);
      if (mounted) Navigator.pop(context);
      widget.onSaved();
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModalField(
          controller: _amountCtrl,
          placeholder: 'Amount (₹) *',
          keyboardType: TextInputType.number,
        ),
        // Payment mode selector
        Text('Payment mode:', style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Cash', 'UPI', 'Card'].map((mode) {
            final selected = mode == _paymentMode;
            return GestureDetector(
              onTap: () => setState(() => _paymentMode = mode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? kRefPrimary : Colors.white,
                  border: Border.all(color: selected ? kRefPrimary : _btnBorder),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  mode,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : kRefDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _ModalField(controller: _notesCtrl, placeholder: 'Notes (optional)'),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _BtnOutlineSm(label: 'Cancel', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
            _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : _BtnPrimarySm(label: 'Add Payment', onTap: _save),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BILL DIALOG
// ═══════════════════════════════════════════════════════════════════════════

class _BillDialog extends StatelessWidget {
  const _BillDialog({required this.detail, required this.patientName});
  final VisitDetail detail;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    final treatCost = detail.totalTreatmentCost;
    final sitCost = detail.totalSittingsCost;
    final rxCost = detail.prescriptions.fold(0.0, (s, rx) => s + (rx.price ?? 0));
    final grandTotal = treatCost + sitCost + rxCost;
    final paid = _effectivePaidAmount();
    final balance = grandTotal - paid;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Clinic header ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Prodontics Clinic',
                        style: GoogleFonts.lato(
                          fontSize: 18, fontWeight: FontWeight.w700, color: kRefPrimary,
                        ),
                      ),
                      Text(
                        'Professional Dental Care',
                        style: GoogleFonts.lato(fontSize: 12, color: kRefPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Visit meta ────────────────────────────────────────────
                _billRow('Visit Date', ProfileTab.formatDate(detail.visit.visitDate)),
                _billRow('Complaint', detail.visit.chiefComplaint ?? '-'),
                _billRow('Doctor', detail.doctorName),

                // ── Treatments ────────────────────────────────────────────
                const Divider(height: 24),
                _sectionHeader('Treatments', Icons.healing_outlined),
                const SizedBox(height: 8),
                if (detail.treatments.isEmpty)
                  _emptyNote('No treatments added')
                else
                  ...detail.treatments.map((t) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _billRow(
                          t.treatmentName ?? 'Treatment',
                          (t.totalCost ?? 0) > 0
                              ? '₹${t.totalCost!.toStringAsFixed(0)}'
                              : '—',
                          bold: true,
                        ),
                        const SizedBox(height: 2),
                      ],
                    );
                  }),
                if (treatCost > 0)
                  _subtotalRow('Treatment Subtotal', treatCost),

                // ── Sittings ──────────────────────────────────────────────
                const Divider(height: 24),
                _sectionHeader('Sittings', Icons.event_note_outlined),
                const SizedBox(height: 8),
                if (detail.sittings.isEmpty)
                  _emptyNote('No sittings recorded')
                else ...[
                  ...detail.treatments.map((t) {
                    final sittings = detail.sittingsForTreatment(t.id);
                    if (sittings.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            t.treatmentName ?? 'Treatment',
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kRefPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        ...sittings.map((s) {
                          final isPaid = s.status.toLowerCase() == 'completed' ||
                              s.status.toLowerCase() == 'paid';
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 5),
                            child: Row(
                              children: [
                                Icon(
                                  isPaid
                                      ? Icons.check_circle_outline
                                      : Icons.radio_button_unchecked,
                                  size: 13,
                                  color: isPaid ? _badgeCompFg : kRefMuted,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${ProfileTab.formatDate(s.sittingDate)}'
                                    '${s.notes != null ? '  ·  ${s.notes}' : ''}',
                                    style: GoogleFonts.lato(fontSize: 12, color: kRefMuted),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  (s.cost ?? 0) > 0
                                      ? '₹${s.cost!.toStringAsFixed(0)}'
                                      : '—',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: isPaid ? _badgeCompFg : kRefDark,
                                    fontWeight: isPaid ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                      ],
                    );
                  }),
                  if (sitCost > 0) _subtotalRow('Sittings Subtotal', sitCost),
                ],

                // ── Prescriptions ─────────────────────────────────────────
                if (detail.prescriptions.isNotEmpty) ...[
                  const Divider(height: 24),
                  _sectionHeader('Prescriptions', Icons.medication_outlined),
                  const SizedBox(height: 8),
                  ...detail.prescriptions.map((rx) {
                    final name = rx.medicineName ?? 'Medicine';
                    final meta = [
                      if (rx.dosage != null) rx.dosage!,
                      if (rx.duration != null) rx.duration!,
                    ].join(' · ');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 6, color: kRefMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: kRefDark,
                                  ),
                                ),
                                if (meta.isNotEmpty)
                                  Text(
                                    meta,
                                    style: GoogleFonts.lato(fontSize: 11, color: kRefMuted),
                                  ),
                              ],
                            ),
                          ),
                          if ((rx.price ?? 0) > 0)
                            Text(
                              '₹${rx.price!.toStringAsFixed(0)}',
                              style: GoogleFonts.lato(
                                fontSize: 12, fontWeight: FontWeight.w500, color: kRefDark,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],

                // ── Summary ───────────────────────────────────────────────
                const Divider(height: 24),
                _billRow('Grand Total', '₹${grandTotal.toStringAsFixed(0)}'),
                _billRow(
                  'Amount Paid',
                  '₹${paid.toStringAsFixed(0)}',
                  bold: true,
                  color: _badgeCompFg,
                ),
                if (balance > 0.01)
                  _billRow('Balance Due', '₹${balance.toStringAsFixed(0)}', color: Colors.red),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BtnOutlineSm(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Generate PDF',
                      onTap: () async {
                           final lineItems = <Map<String, dynamic>>[];
                           for (final t in detail.treatments) {
                             if ((t.totalCost ?? 0) > 0) {
                               lineItems.add({'name': t.treatmentName ?? 'Treatment', 'amount': t.totalCost!});
                             }
                           }
                           for (final s in detail.sittings) {
                             if ((s.cost ?? 0) > 0) {
                               lineItems.add({'name': 'Sitting: ${s.notes ?? 'Follow-up'}', 'amount': s.cost!});
                             }
                           }
                           for (final rx in detail.prescriptions) {
                             if ((rx.price ?? 0) > 0) {
                               lineItems.add({'name': 'Rx: ${rx.medicineName ?? 'Medicine'}', 'amount': rx.price!});
                             }
                           }
                           
                           await PdfGeneratorService.generateInvoicePdf(
                             patientName: patientName,
                             visitDate: detail.visit.visitDate,
                             treatments: lineItems,
                             totalAmount: grandTotal,
                             paidAmount: paid,
                             balance: balance,
                           );
                      },
                    ),
                    const SizedBox(width: 16),
                    _BtnPrimarySm(
                      label: 'Close',
                      onTap: () => Navigator.pop(context),
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

  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 15, color: kRefPrimary),
      const SizedBox(width: 6),
      Text(
        title,
        style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w700, color: kRefDark),
      ),
    ],
  );

  Widget _emptyNote(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: GoogleFonts.lato(fontSize: 12, color: kRefMuted)),
  );

  Widget _subtotalRow(String label, double amount) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 12, color: kRefMuted, fontStyle: FontStyle.italic)),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, color: kRefMuted),
        ),
      ],
    ),
  );

  /// Payments from records + paid sitting costs with no linked payment record.
  double _effectivePaidAmount() {
    final fromPayments = detail.totalPaid;
    final coveredSittingIds = detail.payments
        .where((p) => p.sittingId != null)
        .map((p) => p.sittingId!)
        .toSet();
    final fromUnlinkedSittings = detail.sittings
        .where(
          (s) =>
              (s.status.toLowerCase() == 'completed' ||
                  s.status.toLowerCase() == 'paid') &&
              !coveredSittingIds.contains(s.id) &&
              (s.cost ?? 0) > 0,
        )
        .fold(0.0, (sum, s) => sum + s.cost!);
    return fromPayments + fromUnlinkedSittings;
  }

  Widget _billRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: GoogleFonts.lato(fontSize: 13, color: kRefMuted))),
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
// EMPTY STATE
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
