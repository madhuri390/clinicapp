import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../models/file_attachment_model.dart';
import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/sitting_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';
import '../repositories/patient_repository.dart';
import '../repositories/prescription_repository.dart';
import '../repositories/treatment_repository.dart';
import '../repositories/visit_repository.dart';
import '../services/local_store.dart';
import '../widgets/patient_details_widgets.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  // Repos
  final _patientRepo = PatientRepository();
  final _visitRepo = VisitRepository();
  final _treatmentRepo = TreatmentRepository();
  final _prescriptionRepo = PrescriptionRepository();

  // Data
  Patient? _patient;
  List<Visit> _visits = [];
  List<TreatmentPlan> _treatments = [];
  List<Prescription> _prescriptions = [];
  List<Payment> _payments = [];

  // Data Loading flags
  bool _loadingPatient = true;

  static const _tabLabels = ['Profile', 'Ongoing', 'History'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    LocalStore.instance.seedIfNeeded();
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _loadPatient();
    _loadVisits();
  }

  Future<void> _loadPatient() async {
    try {
      final p = await _patientRepo.getById(widget.patientId);
      if (!mounted) return;
      setState(() {
        _patient = p;
        _loadingPatient = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingPatient = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadVisits() async {
    try {
      final dbVisits = await _visitRepo.getForPatient(widget.patientId);
      final storeVisits = LocalStore.instance.getVisitsForPatient(
        widget.patientId,
      );

      // Combine and deduplicate visits
      final allVisits = [...dbVisits, ...storeVisits];
      final seenIds = <String>{};
      final uniqueVisits = allVisits.where((v) => seenIds.add(v.id)).toList();
      uniqueVisits.sort((a, b) => (b.visitDate).compareTo(a.visitDate));

      if (!mounted) return;
      setState(() {
        _visits = uniqueVisits;
      });
      // Load treatments + prescriptions after visits
      _loadTreatmentsAndPrescriptions(uniqueVisits.map((v) => v.id).toList());
    } catch (e) {
      if (!mounted) return;
      // If DB fails, still show store visits
      final storeVisits = LocalStore.instance.getVisitsForPatient(
        widget.patientId,
      );
      setState(() {
        _visits = storeVisits;
      });
    }
  }

  Future<void> _loadTreatmentsAndPrescriptions(List<String> visitIds) async {
    try {
      final dbTreatments = await _treatmentRepo.getForPatientVisits(visitIds);
      final storeTreatments = LocalStore.instance.getTreatmentsForVisits(
        visitIds,
      );

      final allTreatments = [...dbTreatments, ...storeTreatments];
      final seenIds = <String>{};
      final uniqueTreatments = allTreatments
          .where((t) => seenIds.add(t.id))
          .toList();

      if (!mounted) return;
      setState(() {
        _treatments = uniqueTreatments;
      });
    } catch (_) {}

    try {
      final dbPrescriptions = await _prescriptionRepo.getForPatientVisits(
        visitIds,
      );
      final storePrescriptions = LocalStore.instance.getPrescriptionsForVisits(
        visitIds,
      );

      final allPrescriptions = [...dbPrescriptions, ...storePrescriptions];
      final seenIds = <String>{};
      final uniquePrescriptions = allPrescriptions
          .where((p) => seenIds.add(p.id))
          .toList();

      if (!mounted) return;
      setState(() {
        _prescriptions = uniquePrescriptions;
      });
    } catch (_) {}

    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final visitIds = _visits.map((v) => v.id).toList();
    if (visitIds.isEmpty) return;

    try {
      final storePayments = LocalStore.instance.getPaymentsForVisits(visitIds);
      if (!mounted) return;
      setState(() {
        _payments = storePayments;
      });
    } catch (_) {}
  }

  // ── Modals / Forms ─────────────────────────────────────────────────────────

  void _showNewConsultationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewConsultationSheet(
        patientId: widget.patientId,
        onSave: (v) async {
          final created = await _visitRepo.create(v);
          // TODO: Replace local store with backend integration
          LocalStore.instance.addVisit(created);
          if (mounted) Navigator.pop(context);
          _loadVisits();
        },
      ),
    );
  }

  void _showEditConsultationModal(Visit visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewConsultationSheet(
        patientId: widget.patientId,
        existingVisit: visit,
        onSave: (v) async {
          // TODO: Replace with backend update call
          LocalStore.instance.updateVisit(v);
          if (mounted) Navigator.pop(context);
          _loadVisits();
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _loadingPatient
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : PatientHeader(
                          patient: _patient,
                          displayName: widget.patientName,
                        ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F0B1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _showNewConsultationModal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'New Consultation',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black54,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
                splashBorderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
        body: Container(
          color: const Color(0xFFF9FAFB),
          child: TabBarView(
            controller: _tabController,
            children: [
              ProfileTab(patient: _patient, isLoading: _loadingPatient),
              OngoingTabPlaceholder(
                visits: _visits,
                treatments: _treatments,
                prescriptions: _prescriptions,
                payments: _payments,
                onRefresh: _loadAll,
                onEditVisit: _showEditConsultationModal,
              ),
              HistoryTabPlaceholder(onRefresh: _loadVisits),
            ],
          ),
        ),
      ),
    );
  }
}
