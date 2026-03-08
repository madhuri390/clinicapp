import '../models/file_attachment_model.dart';
import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';

/// In-memory data store for local mock persistence.
class LocalStore {
  LocalStore._();
  static final instance = LocalStore._();

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Visit> _mockVisits = [];
  final List<TreatmentPlan> _mockTreatments = [];
  final List<Prescription> _mockPrescriptions = [];
  final List<Sitting> _mockSittings = [];
  final List<Payment> _mockPayments = [];
  final List<FileAttachment> _mockFiles = [];

  // ── Visits ──────────────────────────────────────────────────────────────
  List<Visit> getVisitsForPatient(String patientId) {
    return _mockVisits.where((v) => v.patientId == patientId).toList();
  }

  void addVisit(Visit visit) => _mockVisits.add(visit);
  void updateVisit(Visit updated) {
    final idx = _mockVisits.indexWhere((v) => v.id == updated.id);
    if (idx >= 0) _mockVisits[idx] = updated;
  }

  // ── Treatments ──────────────────────────────────────────────────────────
  List<TreatmentPlan> getTreatmentsForVisit(String visitId) {
    return _mockTreatments.where((t) => t.visitId == visitId).toList();
  }

  List<TreatmentPlan> getTreatmentsForVisits(List<String> visitIds) {
    return _mockTreatments.where((t) => visitIds.contains(t.visitId)).toList();
  }

  void addTreatment(TreatmentPlan t) => _mockTreatments.add(t);

  // ── Prescriptions ──────────────────────────────────────────────────────
  List<Prescription> getPrescriptionsForVisit(String visitId) {
    return _mockPrescriptions.where((p) => p.visitId == visitId).toList();
  }

  List<Prescription> getPrescriptionsForVisits(List<String> visitIds) {
    return _mockPrescriptions
        .where(
          (p) =>
              visitIds.contains(p.visitId) ||
              visitIds.contains(p.treatmentPlanId),
        )
        .map((p) {
          // Hydrate with payment if it exists
          final payment = _mockPayments.cast<Payment?>().firstWhere(
            (pay) => pay?.prescriptionId == p.id,
            orElse: () => null,
          );
          return p.copyWith(payment: payment);
        })
        .toList();
  }

  List<Prescription> getPrescriptionsForTreatment(String treatmentId) {
    return _mockPrescriptions
        .where((p) => p.treatmentPlanId == treatmentId)
        .map((p) {
          final payment = _mockPayments.cast<Payment?>().firstWhere(
            (pay) => pay?.prescriptionId == p.id,
            orElse: () => null,
          );
          return p.copyWith(payment: payment);
        })
        .toList();
  }

  List<Prescription> getPrescriptionsForSitting(String sittingId) {
    return _mockPrescriptions.where((p) => p.sittingId == sittingId).map((p) {
      final payment = _mockPayments.cast<Payment?>().firstWhere(
        (pay) => pay?.prescriptionId == p.id,
        orElse: () => null,
      );
      return p.copyWith(payment: payment);
    }).toList();
  }

  void addPrescription(Prescription p) => _mockPrescriptions.add(p);

  // ── Sittings ───────────────────────────────────────────────────────────
  List<Sitting> getSittingsForTreatment(String treatmentId) {
    return _mockSittings
        .where((s) => s.treatmentPlanId == treatmentId)
        .toList();
  }

  List<Sitting> getSittingsForVisits(List<String> visitIds) {
    final treatmentIds = _mockTreatments
        .where((t) => visitIds.contains(t.visitId))
        .map((t) => t.id)
        .toSet();
    return _mockSittings
        .where((s) => treatmentIds.contains(s.treatmentPlanId))
        .toList();
  }

  void addSitting(Sitting sitting) => _mockSittings.add(sitting);

  // ── Payments ───────────────────────────────────────────────────────────
  List<Payment> getPaymentsForVisits(List<String> visitIds) {
    // Payments can be linked to treatment or sitting
    final treatmentIds = _mockTreatments
        .where((t) => visitIds.contains(t.visitId))
        .map((t) => t.id)
        .toSet();
    final sittingIds = _mockSittings
        .where((s) => treatmentIds.contains(s.treatmentPlanId))
        .map((s) => s.id)
        .toSet();

    return _mockPayments
        .where(
          (p) =>
              visitIds.contains(p.visitId) ||
              (p.treatmentPlanId != null &&
                  treatmentIds.contains(p.treatmentPlanId)) ||
              (p.sittingId != null && sittingIds.contains(p.sittingId)) ||
              (p.prescriptionId != null &&
                  _mockPrescriptions.any(
                    (rx) =>
                        rx.id == p.prescriptionId &&
                        (visitIds.contains(rx.visitId) ||
                            treatmentIds.contains(rx.treatmentPlanId)),
                  )) ||
              (p.fileId != null &&
                  _mockFiles.any(
                    (f) =>
                        f.id == p.fileId &&
                        (visitIds.contains(f.visitId) ||
                            treatmentIds.contains(f.treatmentPlanId)),
                  )),
        )
        .toList();
  }

  List<Payment> getPaymentsForSitting(String sittingId) {
    return _mockPayments.where((p) => p.sittingId == sittingId).toList();
  }

  void addPayment(Payment p) => _mockPayments.add(p);

  // ── Files ──────────────────────────────────────────────────────────────
  List<FileAttachment> getFilesForVisits(List<String> visitIds) {
    return _mockFiles.where((f) => visitIds.contains(f.visitId)).map((f) {
      // Hydrate with payment if it exists
      final payment = _mockPayments.cast<Payment?>().firstWhere(
        (pay) => pay?.fileId == f.id,
        orElse: () => null,
      );
      return f.copyWith(payment: payment);
    }).toList();
  }

  List<FileAttachment> getFilesForTreatment(String treatmentId) {
    return _mockFiles.where((f) => f.treatmentPlanId == treatmentId).map((f) {
      // Hydrate with payment
      final payment = _mockPayments.cast<Payment?>().firstWhere(
        (pay) => pay?.fileId == f.id,
        orElse: () => null,
      );
      return f.copyWith(payment: payment);
    }).toList();
  }

  void addFile(FileAttachment file) => _mockFiles.add(file);

  // ── Seed ───────────────────────────────────────────────────────────────
  bool _seeded = false;

  void seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;

    // Rich History Mock: Root Canal Treatment
    const visitId = 'seed_v1';
    _mockVisits.add(
      Visit(
        id: visitId,
        patientId: '_global_',
        visitDate: DateTime.now().subtract(const Duration(days: 30)),
        chiefComplaint: 'Tooth Pain - Upper Right Molar',
        diagnosis: 'Deep cavity with possible pulp involvement',
      ),
    );

    // Initial payment for visit itself or registration if any

    const treatId = 'seed_t1';
    _mockTreatments.add(
      const TreatmentPlan(
        id: treatId,
        visitId: visitId,
        treatmentName: 'Root Canal Treatment',
        description:
            'Root canal therapy for upper right first molar with crown placement',
        totalCost: 1100,
        status: 'Completed',
      ),
    );

    _mockPrescriptions.addAll([
      const Prescription(
        id: 'seed_rx1',
        visitId: visitId,
        treatmentPlanId: treatId,
        medicineName: 'Amoxicillin',
        dosage: '500mg - 3x daily',
        duration: '5 days',
        price: 25,
      ),
      const Prescription(
        id: 'seed_rx2',
        visitId: visitId,
        treatmentPlanId: treatId,
        medicineName: 'Ibuprofen',
        dosage: '400mg - As needed',
        duration: '3 days',
        price: 15,
      ),
    ]);

    _mockFiles.addAll([
      const FileAttachment(
        id: 'seed_f1',
        visitId: visitId,
        treatmentPlanId: treatId,
        fileName: 'X-Ray - Right Side',
        fileType: 'Digital X-Ray',
        price: 150.0,
      ),
      const FileAttachment(
        id: 'seed_f2',
        visitId: visitId,
        treatmentPlanId: treatId,
        fileName: 'CBCT Scan',
        fileType: '3D Imaging',
        price: 350.0,
      ),
    ]);

    // Payments for RX and Files to show it works
    _mockPayments.addAll([
      Payment(
        id: 'seed_p_rx1',
        visitId: visitId,
        prescriptionId: 'seed_rx1',
        amountPaid: 25,
        paymentMode: 'Cash',
        paymentDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Payment(
        id: 'seed_p_f1',
        visitId: visitId,
        fileId: 'seed_f1',
        amountPaid: 150,
        paymentMode: 'UPI',
        paymentDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Payment(
        id: 'seed_p_rx2',
        visitId: visitId,
        prescriptionId: 'seed_rx2',
        amountPaid: 15,
        paymentMode: 'Cash',
        paymentDate: DateTime.now().subtract(const Duration(days: 28)),
      ),
      Payment(
        id: 'seed_p_f2',
        visitId: visitId,
        fileId: 'seed_f2',
        amountPaid: 350,
        paymentMode: 'Card',
        paymentDate: DateTime.now().subtract(const Duration(days: 25)),
      ),
    ]);

    // Sittings for Root Canal
    _mockSittings.add(
      Sitting(
        id: 'seed_s1',
        visitId: visitId,
        treatmentPlanId: treatId,
        sittingDate: DateTime.now().subtract(const Duration(days: 30)),
        durationStr: '1 hour',
        notes:
            'Initial examination, X-rays taken, pulp cavity accessed and cleaned. Temporary filling applied.',
        cost: 500,
      ),
    );

    _mockPayments.add(
      Payment(
        id: 'seed_p1',
        visitId: visitId,
        sittingId: 'seed_s1',
        amountPaid: 500,
        paymentMode: 'Card',
        paymentDate: DateTime.now().subtract(const Duration(days: 30)),
        notes: 'Paid for first sitting',
      ),
    );

    _mockSittings.add(
      Sitting(
        id: 'seed_s1_final',
        visitId: visitId,
        treatmentPlanId: treatId,
        sittingDate: DateTime.now().subtract(const Duration(days: 20)),
        durationStr: '45 mins',
        notes: 'Final crown placement and polishing.',
        cost: 600,
      ),
    );

    _mockPayments.add(
      Payment(
        id: 'seed_p1_final',
        visitId: visitId,
        sittingId: 'seed_s1_final',
        amountPaid: 600,
        paymentMode: 'UPI',
        paymentDate: DateTime.now().subtract(const Duration(days: 20)),
        notes: 'Final payment for Root Canal',
      ),
    );

    _mockPayments.add(
      Payment(
        id: 'seed_p_rx3',
        visitId: visitId,
        prescriptionId: 'seed_rx3',
        amountPaid: 12,
        paymentMode: 'Cash',
        paymentDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    );

    // Second History Mock: Dental Cleaning
    const visitId2 = 'seed_v2';
    _mockVisits.add(
      Visit(
        id: visitId2,
        patientId: '_global_',
        visitDate: DateTime.now().subtract(const Duration(days: 60)),
        chiefComplaint: 'Routine checkup and cleaning',
        diagnosis: 'Mild plaque and tartar buildup',
      ),
    );

    const treatId2 = 'seed_t2';
    _mockTreatments.add(
      const TreatmentPlan(
        id: treatId2,
        visitId: visitId2,
        treatmentName: 'Dental Cleaning & Polishing',
        description: 'Complete scaling and polishing of all teeth surfaces',
        totalCost: 200,
        status: 'Completed',
      ),
    );

    _mockSittings.add(
      Sitting(
        id: 'seed_s2_1',
        visitId: visitId2,
        treatmentPlanId: treatId2,
        sittingDate: DateTime.now().subtract(const Duration(days: 60)),
        durationStr: '45 mins',
        notes:
            'Full scaling and polishing completed. Patient advised on flossing.',
        cost: 200,
      ),
    );

    _mockPayments.addAll([
      Payment(
        id: 'seed_p2_1',
        visitId: visitId2,
        sittingId: 'seed_s2_1',
        amountPaid: 200,
        paymentMode: 'Cash',
        paymentDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ]);

    _mockPrescriptions.add(
      const Prescription(
        id: 'seed_rx3',
        visitId: visitId, // Also seed_v1
        treatmentPlanId: 'seed_t1',
        sittingId: 'seed_s1',
        medicineName: 'Analgesic Gel',
        dosage: 'Apply as needed',
        price: 12,
      ),
    );

    // Additional generic mock data
    const gVisitId = 'v1';
    const gTreatId = 't1';

    _mockSittings.add(
      Sitting(
        id: 's2',
        visitId: gVisitId,
        treatmentPlanId: gTreatId,
        sittingDate: DateTime.now().subtract(const Duration(days: 2)),
        durationStr: '45 mins',
        notes: 'Initial fitting and adjustments.',
        cost: 500,
        status: 'Completed',
      ),
    );
    _mockSittings.add(
      Sitting(
        id: 's3',
        visitId: gVisitId,
        treatmentPlanId: gTreatId,
        sittingDate: DateTime.now(),
        durationStr: '30 mins',
        notes: 'Final adjustment.',
        cost: 300,
        status: 'Scheduled',
      ),
    );

    _mockPayments.add(
      Payment(
        id: 'pay1',
        visitId: gVisitId,
        treatmentPlanId: gTreatId,
        amountPaid: 200,
        paymentMode: 'Cash',
        paymentDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );
    _mockPayments.add(
      Payment(
        id: 'pay2',
        visitId: gVisitId,
        sittingId: 's2',
        amountPaid: 300,
        paymentMode: 'UPI',
        paymentDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
    _mockSittings.add(
      Sitting(
        id: 'seed_s3',
        visitId: visitId,
        treatmentPlanId: treatId,
        sittingDate: DateTime.now().subtract(const Duration(days: 15)),
        durationStr: '1 hour',
        notes: 'Obturation and final restoration.',
        cost: 600,
      ),
    );

    // Sitting 3 Payment (Full payment for history consistency)
    _mockPayments.add(
      Payment(
        id: 'seed_p3',
        visitId: visitId,
        sittingId: 'seed_s3',
        amountPaid: 600,
        paymentMode: 'UPI',
        paymentDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
    );

    // Sitting s3 Payment (Full payment for history consistency)
    _mockPayments.add(
      Payment(
        id: 'pay3',
        visitId: gVisitId,
        sittingId: 's3',
        amountPaid: 300,
        paymentMode: 'Card',
        paymentDate: DateTime.now(),
      ),
    );
  }
}
