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
      builder: (_) => _NewConsultationSheet(
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
      builder: (_) => _NewConsultationSheet(
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
                      : _PatientHeader(
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
            delegate: _SliverAppBarDelegate(
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
              _ProfileTab(patient: _patient, isLoading: _loadingPatient),
              // TODO: Implement OngoingTab with logic
              _OngoingTabPlaceholder(
                visits: _visits,
                treatments: _treatments,
                prescriptions: _prescriptions,
                payments: _payments,
                onRefresh: _loadAll,
                onEditVisit: _showEditConsultationModal,
              ),
              // TODO: Implement HistoryTab with logic
              _HistoryTabPlaceholder(onRefresh: _loadVisits),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      alignment: Alignment.center,
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// ── Patient header ────────────────────────────────────────────────────────────

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({this.patient, required this.displayName});

  final Patient? patient;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final name = patient?.fullName ?? displayName;
    final gender = patient?.gender ?? 'Female';
    final age = patient?.age ?? 34;
    final bloodGroup = patient?.bloodGroup ?? 'O+';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFD6E4FF),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF3366FF),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$age years • $gender',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              bloodGroup,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({this.patient, required this.isLoading});
  final Patient? patient;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final p = patient;
    final phone = p?.phone ?? '+1 (555) 123-4567';
    final email =
        p?.email ??
        '${p?.firstName.toLowerCase() ?? 'sarah.johnson'}@email.com';
    final address =
        p?.address ?? '123 Oak Street, Apartment 4B, Springfield, IL 62701';
    final regDate = p?.createdAt != null
        ? _fmtDate(p!.createdAt!)
        : 'Jan 15, 2024';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Contact Information Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 24),
                _ContactRow(icon: Icons.phone_outlined, text: phone),
                const SizedBox(height: 20),
                _ContactRow(icon: Icons.mail_outlined, text: email),
                const SizedBox(height: 20),
                _ContactRow(icon: Icons.location_on_outlined, text: address),
                const SizedBox(height: 20),
                _ContactRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Registered: $regDate',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Allergies Card (mocked)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Conditions',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _AllergyPill('Penicillin Allergy'),
                    _AllergyPill('Diabetes'),
                    _AllergyPill('Hypertension'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _AllergyPill extends StatelessWidget {
  final String type;
  const _AllergyPill(this.type);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Placeholders for new tabs ─────────────────────────────────────────────────

class _OngoingTabPlaceholder extends StatelessWidget {
  final List<Visit> visits;
  final List<TreatmentPlan> treatments;
  final List<Prescription> prescriptions;
  final List<Payment> payments;
  final VoidCallback onRefresh;
  final void Function(Visit) onEditVisit;

  const _OngoingTabPlaceholder({
    required this.visits,
    required this.treatments,
    required this.prescriptions,
    required this.payments,
    required this.onRefresh,
    required this.onEditVisit,
  });

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Center(
        child: Text(
          'No ongoing consultations',
          style: GoogleFonts.poppins(color: Colors.black54),
        ),
      );
    }

    // Merge DB data with local store data
    final store = LocalStore.instance;
    final ongoingTreatments = [
      ...treatments,
      ...store.getTreatmentsForVisits(visits.map((v) => v.id).toList()),
    ];
    final ongoingPrescriptions = [
      ...prescriptions,
      ...store.getPrescriptionsForVisits(visits.map((v) => v.id).toList()),
    ];
    final ongoingSittings = store.getSittingsForVisits(
      visits.map((v) => v.id).toList(),
    );
    // Deduplicate by id
    final seenTreatments = <String>{};
    final uniqueTreatments = ongoingTreatments
        .where((t) => seenTreatments.add(t.id))
        .toList();
    final seenPrescriptions = <String>{};
    final uniquePrescriptions = ongoingPrescriptions
        .where((p) => seenPrescriptions.add(p.id))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visitPayments = [
          ...payments.where((p) => p.visitId == visits[index].id),
          ...store.getPaymentsForVisits([visits[index].id]),
        ];
        // Deduplicate payments by id
        final seenPayments = <String>{};
        final uniqueVisitPayments = visitPayments
            .where((p) => seenPayments.add(p.id))
            .toList();

        return _ConsultationCard(
          visit: visits[index],
          treatments: uniqueTreatments
              .where((t) => t.visitId == visits[index].id)
              .toList(),
          prescriptions: uniquePrescriptions
              .where((p) => p.visitId == visits[index].id)
              .toList(),
          sittings: ongoingSittings
              .where((s) => s.visitId == visits[index].id)
              .toList(),
          payments: uniqueVisitPayments,
          isOngoing: true,
          onRefresh: onRefresh,
          onEditVisit: onEditVisit,
        );
      },
    );
  }
}

class _HistoryTabPlaceholder extends StatelessWidget {
  final VoidCallback onRefresh;

  const _HistoryTabPlaceholder({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final store = LocalStore.instance;
    final historyVisits = store.getVisitsForPatient('_global_');

    if (historyVisits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No past consultations',
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: historyVisits.length,
      itemBuilder: (context, index) {
        final visit = historyVisits[index];
        final visitTreatments = store.getTreatmentsForVisits([visit.id]);
        final visitPrescriptions = store.getPrescriptionsForVisits([visit.id]);
        final visitSittings = store.getSittingsForVisits([visit.id]);
        final visitPayments = store.getPaymentsForVisits([visit.id]);

        return _ConsultationCard(
          visit: visit,
          treatments: visitTreatments,
          prescriptions: visitPrescriptions,
          sittings: visitSittings,
          payments: visitPayments,
          isOngoing: false,
          onRefresh: onRefresh,
          onEditVisit: (_) {},
        );
      },
    );
  }
}

// ── Consultation Card ────────────────────────────────────────────────────────

class _ConsultationCard extends StatelessWidget {
  const _ConsultationCard({
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
  final List<dynamic> sittings; // Assuming dynamic for now
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
          // Header
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
                      _ProfileTab._fmtDate(visit.visitDate),
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
                  'Dr. Emily Chen', // Mocked doctor for now
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

          // Treatments
          if (treatments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: treatments
                    .map<Widget>(
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
                                    // TODO: Replace with backend call
                                    final created = await TreatmentRepository()
                                        .create(t);
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
                                // If there's only one treatment, link to it by default
                                treatmentPlanId: treatments.length == 1
                                    ? treatments.first.id
                                    : null,
                                onSave: (p) async {
                                  // TODO: Replace with backend call
                                  final created = await PrescriptionRepository()
                                      .create(p);
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
                                  // TODO: Replace with backend call
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
                                  // TODO: Replace with backend call
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
                            (t) =>
                                LocalStore.instance.getFilesForTreatment(t.id),
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

// ── Treatment Accordion ──────────────────────────────────────────────────────

class _TreatmentAccordion extends StatelessWidget {
  final TreatmentPlan treatment;
  final List<Prescription> prescriptions;
  final List<FileAttachment> files;
  final List<dynamic> sittings;
  final List<Payment> payments;
  final VoidCallback onRefresh;
  final bool isOngoing;

  const _TreatmentAccordion({
    required this.treatment,
    required this.prescriptions,
    required this.files,
    required this.sittings,
    required this.payments,
    required this.onRefresh,
    required this.isOngoing,
  });

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

// ── Sub-Entity Add Modals ─────────────────────────────────────────────────────

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
                  description: _descCtrl.text.trim().isEmpty
                      ? null
                      : _descCtrl.text.trim(),
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
                  durationStr: '30 mins', // Default
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
              // Header
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
                    _ProfileTab._fmtDate(visit.visitDate),
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
                    _ProfileTab._fmtDate(DateTime.now()),
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

              // Itemized Rows
              ...sittings.asMap().entries.map((entry) {
                final index = entry.key;
                final s = entry.value;
                final isPaid = payments.any((p) => p.sittingId == s.id);
                return _invoiceItemRow(
                  'Sitting ${index + 1}',
                  _ProfileTab._fmtDate(s.sittingDate),
                  s.cost ?? 0,
                  isPaid ? 'Paid' : 'Pending',
                  isPaid ? Colors.green : Colors.red,
                  subtitle: s.notes,
                );
              }),
              ...prescriptions.map((p) {
                return _invoiceItemRow(
                  'Prescription: ${p.medicineName}',
                  _ProfileTab._fmtDate(p.createdAt ?? DateTime.now()),
                  p.price ?? 0,
                  p.payment != null ? 'Paid' : 'Pending',
                  p.payment != null ? Colors.green : Colors.red,
                );
              }),
              ...files.where((f) => (f.price ?? 0) > 0).map((f) {
                return _invoiceItemRow(
                  'File: ${f.fileName}',
                  _ProfileTab._fmtDate(visit.visitDate),
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
                          (sittings.fold<double>(
                            0,
                            (sum, s) => sum + (s.cost ?? 0),
                          )) +
                          (prescriptions.fold<double>(
                            0,
                            (sum, p) => sum + (p.price ?? 0),
                          )) +
                          (files.fold<double>(
                            0,
                            (sum, f) => sum + (f.price ?? 0),
                          ));
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

// ── Shared helpers ────────────────────────────────────────────────────────────

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

// omitted DetailRow

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

// omitted TriStateToggle

class _AnimatedCard extends StatefulWidget {
  const _AnimatedCard({required this.child});
  final Widget child;

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (mounted) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Add/Edit Modals ───────────────────────────────────────────────────────────

class _NewConsultationSheet extends StatefulWidget {
  const _NewConsultationSheet({
    required this.patientId,
    required this.onSave,
    this.existingVisit,
  });
  final String patientId;
  final ValueChanged<Visit> onSave;
  final Visit? existingVisit;

  @override
  State<_NewConsultationSheet> createState() => _NewConsultationSheetState();
}

class _NewConsultationSheetState extends State<_NewConsultationSheet> {
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
    return _BottomSheetWrapper(
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
                lastDate: DateTime.now(),
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
    );
    widget.onSave(visit);
  }
}

// ── Sittings Components ───────────────────────────────────────────────────────

class _SittingsHeader extends StatelessWidget {
  final String visitId;
  final String treatmentId;
  final VoidCallback onRefresh;
  final bool isOngoing;

  const _SittingsHeader({
    required this.visitId,
    required this.treatmentId,
    required this.onRefresh,
    required this.isOngoing,
  });

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
  final String visitId;
  final List<dynamic> sittings;
  final VoidCallback onRefresh;
  final bool isOngoing;

  const _SittingsList({
    required this.visitId,
    required this.sittings,
    required this.onRefresh,
    required this.isOngoing,
  });

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
  final String visitId;
  final Sitting sitting;
  final VoidCallback onRefresh;
  final bool isOngoing;

  const _SittingItem({
    required this.visitId,
    required this.sitting,
    required this.onRefresh,
    required this.isOngoing,
  });

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
          'Sitting - ${_ProfileTab._fmtDate(sitting.sittingDate)}',
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
