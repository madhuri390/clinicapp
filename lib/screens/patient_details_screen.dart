import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';
import '../repositories/patient_repository.dart';
import '../services/local_store.dart';
import '../theme/app_theme.dart';
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
      // Seed rich ongoing mock data for this patient so the Ongoing tab
      // has useful examples (only happens once per patientId).
      LocalStore.instance.seedOngoingForPatient(widget.patientId);

      final refreshedStoreVisits = LocalStore.instance.getVisitsForPatient(
        widget.patientId,
      );

      // Combine and deduplicate visits (DB + local + seeded)
      final allVisits = [...refreshedStoreVisits];
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
      final storeTreatments = LocalStore.instance.getTreatmentsForVisits(
        visitIds,
      );

      if (!mounted) return;
      setState(() {
        _treatments = storeTreatments;
      });
    } catch (_) {}

    try {
      final storePrescriptions = LocalStore.instance.getPrescriptionsForVisits(
        visitIds,
      );

      if (!mounted) return;
      setState(() {
        _prescriptions = storePrescriptions;
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
        onSave: (v) {
          // Generate a mock ID if it's new
          final newVisit = Visit(
            id: 'mock_v_${DateTime.now().millisecondsSinceEpoch}',
            patientId: v.patientId,
            visitDate: v.visitDate,
            chiefComplaint: v.chiefComplaint,
            diagnosis: v.diagnosis,
            notes: v.notes,
          );
          LocalStore.instance.addVisit(newVisit);
          if (mounted) {
            Navigator.pop(context);
            _tabController.animateTo(1);
          }
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
        onSave: (v) {
          LocalStore.instance.updateVisit(v);
          if (mounted) Navigator.pop(context);
          _loadVisits();
        },
      ),
    );
  }

  void _deleteVisit(Visit visit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Consultation?'),
        content: const Text(
          'Are you sure you want to delete this consultation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              LocalStore.instance.deleteVisit(visit.id);
              _loadVisits();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBlueBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBlueBackground,
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
                        backgroundColor: AppTheme.primaryColor,
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
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.primaryColor.withValues(
                  alpha: 0.7,
                ),
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
          color: AppTheme.lightBlueBackground,
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
                onComplete: () {
                  _loadAll();
                  _tabController.animateTo(2);
                },
              ),
              HistoryTabPlaceholder(visits: _visits, onRefresh: _loadVisits),
            ],
          ),
        ),
      ),
    );
  }
}
