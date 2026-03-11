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

  List<Visit> getVisitsForPatient(String patientId) {
    // If we have global mock visits, assign them to this patient so they
    // show up in the UI for testing purposes.
    final globalMocks = _mockVisits.where((v) => v.patientId == '_global_').toList();
    for (var mock in globalMocks) {
      final idx = _mockVisits.indexOf(mock);
      _mockVisits[idx] = Visit(
        id: mock.id,
        patientId: patientId, // Bind to the requested patient
        visitDate: mock.visitDate,
        chiefComplaint: mock.chiefComplaint,
        diagnosis: mock.diagnosis,
        notes: mock.notes,
        nextVisitDate: mock.nextVisitDate,
        createdAt: mock.createdAt,
      );
    }
    
    return _mockVisits.where((v) => v.patientId == patientId).toList();
  }

  void addVisit(Visit visit) => _mockVisits.add(visit);
  void updateVisit(Visit updated) {
    final idx = _mockVisits.indexWhere((v) => v.id == updated.id);
    if (idx >= 0) _mockVisits[idx] = updated;
  }
  void deleteVisit(String id) {
    _mockVisits.removeWhere((v) => v.id == id);
  }

  // ── Treatments ──────────────────────────────────────────────────────────
  List<TreatmentPlan> getTreatmentsForVisit(String visitId) {
    return _mockTreatments.where((t) => t.visitId == visitId).toList();
  }

  List<TreatmentPlan> getTreatmentsForVisits(List<String> visitIds) {
    return _mockTreatments.where((t) => visitIds.contains(t.visitId)).toList();
  }

  void addTreatment(TreatmentPlan t) => _mockTreatments.add(t);
  void updateTreatment(TreatmentPlan updated) {
    final idx = _mockTreatments.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) _mockTreatments[idx] = updated;
  }

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
    // Link sittings directly to visits so that sittings created
    // for treatments that only exist in the backend (not in the
    // local mock treatments list) still show up correctly.
    return _mockSittings.where((s) => visitIds.contains(s.visitId)).toList();
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
  final Set<String> _seededOngoingPatients = {};

  void seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;

    final now = DateTime.now();

    // ── Case 1: Fresh Consultation (Today) ──
    const visitId1 = 'mock_v1';
    _mockVisits.add(
      Visit(
        id: visitId1,
        patientId: '_global_',
        visitDate: now,
        chiefComplaint: 'Severe toothache in lower left jaw',
        diagnosis: 'Suspected deep caries on 36, needs X-Ray',
      ),
    );

    // ── Case 2: Treatment Planned (2 days ago) ──
    const visitId2 = 'mock_v2';
    _mockVisits.add(
      Visit(
        id: visitId2,
        patientId: '_global_',
        visitDate: now.subtract(const Duration(days: 2)),
        chiefComplaint: 'Broken tooth from eating hard food',
        diagnosis: 'Fractured premolar (24). Requires extraction.',
      ),
    );

    const treatId2 = 'mock_t2';
    _mockTreatments.add(
      const TreatmentPlan(
        id: treatId2,
        visitId: visitId2,
        treatmentName: 'Tooth Extraction',
        description: 'Surgical extraction of fractured premolar with local anesthesia',
        totalCost: 1500,
        status: 'Planned',
      ),
    );
    
    _mockPrescriptions.add(
      const Prescription(
        id: 'mock_rx2',
        visitId: visitId2,
        treatmentPlanId: treatId2,
        medicineName: 'Amoxicillin 500mg',
        dosage: '1 tab every 8 hours',
        duration: '5 days',
        price: 150,
      ),
    );

    _mockFiles.add(
      const FileAttachment(
        id: 'mock_f2',
        visitId: visitId2,
        treatmentPlanId: treatId2,
        fileName: 'Initial X-Ray',
        fileType: 'IOPA X-Ray',
        price: 200.0,
      ),
    );

    // Initial consultation and X-ray paid
    _mockPayments.add(
      Payment(
        id: 'mock_p2_1',
        visitId: visitId2,
        fileId: 'mock_f2',
        amountPaid: 200,
        paymentMode: 'UPI',
        paymentDate: now.subtract(const Duration(days: 2)),
      ),
    );


    // ── Case 3: In-Progress Treatment (10 days ago) ──
    const visitId3 = 'mock_v3';
    _mockVisits.add(
      Visit(
        id: visitId3,
        patientId: '_global_',
        visitDate: now.subtract(const Duration(days: 10)),
        chiefComplaint: 'Sensitivity to hot/cold, dull throbbing pain',
        diagnosis: 'Irreversible pulpitis on 46',
      ),
    );

    const treatId3 = 'mock_t3';
    _mockTreatments.add(
      const TreatmentPlan(
        id: treatId3,
        visitId: visitId3,
        treatmentName: 'Root Canal Treatment (RCT)',
        description: 'Access opening, BMW, and obturation for lower right first molar',
        totalCost: 4500,
        status: 'In Progress',
      ),
    );

    _mockSittings.add(
      Sitting(
        id: 'mock_s3_1',
        visitId: visitId3,
        treatmentPlanId: treatId3,
        sittingDate: now.subtract(const Duration(days: 10)),
        durationStr: '45 mins',
        notes: 'Access opening done. Canals located and extirpation completed. Calcium hydroxide dressing given.',
        cost: 2000,
        status: 'Completed',
      ),
    );

    _mockPayments.add(
      Payment(
        id: 'mock_p3_1',
        visitId: visitId3,
        sittingId: 'mock_s3_1',
        amountPaid: 2000,
        paymentMode: 'Card',
        paymentDate: now.subtract(const Duration(days: 10)),
        notes: 'Adv. for RCT Phase 1',
      ),
    );

    _mockSittings.add(
      Sitting(
        id: 'mock_s3_2',
        visitId: visitId3,
        treatmentPlanId: treatId3,
        sittingDate: now.add(const Duration(days: 2)),
        durationStr: '60 mins',
        notes: 'Scheduled for BMP and Obturation',
        cost: 2500,
        status: 'Scheduled',
      ),
    );

    // ── Case 4: Orthodontic Braces - Ongoing Monthly Follow-up ──
    const visitId4 = 'mock_v4';
    _mockVisits.add(
      Visit(
        id: visitId4,
        patientId: '_global_',
        visitDate: now.subtract(const Duration(days: 60)),
        chiefComplaint: 'Crooked front teeth',
        diagnosis: 'Class II Malocclusion',
      ),
    );

    const treatId4 = 'mock_t4';
    _mockTreatments.add(
      const TreatmentPlan(
        id: treatId4,
        visitId: visitId4,
        treatmentName: 'Orthodontic Braces (Metal)',
        description: 'Correction of malocclusion with metal brackets. Estimated duration: 18 months.',
        totalCost: 35000,
        status: 'In Progress',
      ),
    );

    // Initial Bracket placement
    _mockSittings.add(
      Sitting(
        id: 'mock_s4_1',
        visitId: visitId4,
        treatmentPlanId: treatId4,
        sittingDate: now.subtract(const Duration(days: 60)),
        durationStr: '2 hours',
        notes: 'Initial bonding of upper and lower arches with 0.14 NiTi wire.',
        cost: 15000, // Down payment
        status: 'Completed',
      ),
    );
    
    _mockPayments.add(
      Payment(
        id: 'mock_p4_1',
        visitId: visitId4,
        sittingId: 'mock_s4_1',
        amountPaid: 15000,
        paymentMode: 'UPI',
        paymentDate: now.subtract(const Duration(days: 60)),
        notes: 'Down payment for braces',
      ),
    );

    // First follow up
    _mockSittings.add(
      Sitting(
        id: 'mock_s4_2',
        visitId: visitId4,
        treatmentPlanId: treatId4,
        sittingDate: now.subtract(const Duration(days: 30)),
        durationStr: '30 mins',
        notes: 'Review. Wire upgraded to 0.16 NiTi upper and lower. Ligature ties changed (Blue).',
        cost: 1000, // Monthly installment
        status: 'Completed',
      ),
    );

    _mockPayments.add(
      Payment(
        id: 'mock_p4_2',
        visitId: visitId4,
        sittingId: 'mock_s4_2',
        amountPaid: 1000,
        paymentMode: 'Cash',
        paymentDate: now.subtract(const Duration(days: 30)),
        notes: 'Monthly Installment 1',
      ),
    );
  }

  /// Seed rich ongoing data for a specific patient so the Ongoing tab
  /// can showcase different lifecycle stages (planned, in‑progress, completed).
  void seedOngoingForPatient(String patientId) {
    if (_seededOngoingPatients.contains(patientId)) return;
    _seededOngoingPatients.add(patientId);

    final now = DateTime.now();

    // Visit 1: Planned consultation, treatment defined but no sittings/payments yet.
    final plannedVisitId = 'ongoing_${patientId}_planned';
    final vPlanned = Visit(
      id: plannedVisitId,
      patientId: patientId,
      visitDate: now.subtract(const Duration(days: 1)),
      chiefComplaint: 'Mild tooth sensitivity to cold drinks',
      diagnosis: 'Early enamel wear (planned evaluation)',
    );
    _mockVisits.add(vPlanned);

    const tPlannedId = 'ongoing_t_planned';
    _mockTreatments.add(
      TreatmentPlan(
        id: tPlannedId,
        visitId: plannedVisitId,
        treatmentName: 'Fluoride Varnish Application',
        description: 'Topical fluoride to strengthen enamel and reduce sensitivity.',
        totalCost: 150,
        status: 'Planned',
      ),
    );

    // Visit 2: Active treatment with multiple sittings and partial payments.
    final activeVisitId = 'ongoing_${patientId}_active';
    final vActive = Visit(
      id: activeVisitId,
      patientId: patientId,
      visitDate: now.subtract(const Duration(days: 7)),
      chiefComplaint: 'Crowding in lower front teeth',
      diagnosis: 'Class I malocclusion – mild crowding',
    );
    _mockVisits.add(vActive);

    const tActiveId = 'ongoing_t_active';
    _mockTreatments.add(
      TreatmentPlan(
        id: tActiveId,
        visitId: activeVisitId,
        treatmentName: 'Clear Aligner Therapy',
        description:
            'Series of clear aligners to correct mild lower anterior crowding.',
        totalCost: 2400,
        status: 'In Progress',
      ),
    );

    final sActive1 = Sitting(
      id: 'ongoing_s_active_1',
      visitId: vActive.id,
      treatmentPlanId: tActiveId,
      sittingDate: now.subtract(const Duration(days: 7)),
      durationStr: '45 mins',
      notes: 'Initial records, impressions, and treatment planning.',
      cost: 600,
    );
    final sActive2 = Sitting(
      id: 'ongoing_s_active_2',
      visitId: vActive.id,
      treatmentPlanId: tActiveId,
      sittingDate: now.subtract(const Duration(days: 2)),
      durationStr: '30 mins',
      notes: 'Aligner delivery and instructions.',
      cost: 800,
    );
    _mockSittings.addAll([sActive1, sActive2]);

    _mockPayments.addAll([
      Payment(
        id: 'ongoing_p_active_deposit',
        visitId: vActive.id,
        sittingId: sActive1.id,
        amountPaid: 400,
        paymentMode: 'UPI',
        paymentDate: now.subtract(const Duration(days: 7)),
        notes: 'Initial deposit for aligner therapy',
      ),
      // Second sitting still partially unpaid to show a balance.
      Payment(
        id: 'ongoing_p_active_partial',
        visitId: vActive.id,
        sittingId: sActive2.id,
        amountPaid: 300,
        paymentMode: 'Card',
        paymentDate: now.subtract(const Duration(days: 1)),
        notes: 'Partial payment for aligner delivery visit',
      ),
    ]);

    // Visit 3: Recently completed single‑visit treatment with full payment.
    final completedVisitId = 'ongoing_${patientId}_completed';
    final vCompleted = Visit(
      id: completedVisitId,
      patientId: patientId,
      visitDate: now.subtract(const Duration(days: 3)),
      chiefComplaint: 'Coffee stains on front teeth',
      diagnosis: 'Extrinsic staining',
    );
    _mockVisits.add(vCompleted);

    const tCompletedId = 'ongoing_t_completed';
    _mockTreatments.add(
      TreatmentPlan(
        id: tCompletedId,
        visitId: completedVisitId,
        treatmentName: 'In‑office Teeth Whitening',
        description: 'Single‑visit whitening session with custom shade matching.',
        totalCost: 500,
        status: 'Completed',
      ),
    );

    final sCompleted = Sitting(
      id: 'ongoing_s_completed_1',
      visitId: vCompleted.id,
      treatmentPlanId: tCompletedId,
      sittingDate: now.subtract(const Duration(days: 3)),
      durationStr: '60 mins',
      notes: 'Full whitening session completed. Post‑op sensitivity instructions given.',
      cost: 500,
    );
    _mockSittings.add(sCompleted);

    _mockPayments.add(
      Payment(
        id: 'ongoing_p_completed_full',
        visitId: vCompleted.id,
        sittingId: sCompleted.id,
        amountPaid: 500,
        paymentMode: 'Cash',
        paymentDate: now.subtract(const Duration(days: 3)),
        notes: 'Full payment for whitening session',
      ),
    );
  }
}
