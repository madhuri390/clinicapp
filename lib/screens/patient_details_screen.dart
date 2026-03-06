import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../models/prescription_model.dart';
import '../models/treatment_plan_model.dart';
import '../models/visit_model.dart';
import '../repositories/patient_repository.dart';
import '../repositories/prescription_repository.dart';
import '../repositories/treatment_repository.dart';
import '../repositories/visit_repository.dart';
import '../theme/app_theme.dart';

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
  bool _loadingPatient = true;
  bool _loadingVisits = true;
  bool _loadingTreatments = true;
  bool _loadingPrescriptions = true;

  static const _tabLabels = [
    'Profile',
    'Visits',
    'Treatments',
    'Prescriptions',
    'Files',
    'Billing',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
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
      if (!mounted) return;
      setState(() => _loadingPatient = false);
    }
  }

  Future<void> _loadVisits() async {
    try {
      final visits = await _visitRepo.getForPatient(widget.patientId);
      if (!mounted) return;
      setState(() {
        _visits = visits;
        _loadingVisits = false;
      });
      // Load treatments + prescriptions after visits
      _loadTreatmentsAndPrescriptions(visits.map((v) => v.id).toList());
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingVisits = false);
    }
  }

  Future<void> _loadTreatmentsAndPrescriptions(List<String> visitIds) async {
    try {
      final treatments = await _treatmentRepo.getForPatientVisits(visitIds);
      if (!mounted) return;
      setState(() {
        _treatments = treatments;
        _loadingTreatments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTreatments = false);
    }

    try {
      final prescriptions = await _prescriptionRepo.getForPatientVisits(
        visitIds,
      );
      if (!mounted) return;
      setState(() {
        _prescriptions = prescriptions;
        _loadingPrescriptions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPrescriptions = false);
    }
  }

  // ── Computed financials ────────────────────────────────────────────────────

  double get _totalCost =>
      _treatments.fold(0, (s, t) => s + (t.totalCost ?? 0));

  // ── Add Visit ──────────────────────────────────────────────────────────────

  void _showAddVisitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddVisitSheet(
        patientId: widget.patientId,
        onSave: (v) async {
          await _visitRepo.create(v);
          Navigator.pop(context);
          _loadVisits();
        },
      ),
    );
  }

  // ── Add Treatment ──────────────────────────────────────────────────────────

  void _showAddTreatmentSheet() {
    if (_visits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a visit first before adding treatments'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTreatmentSheet(
        visits: _visits,
        onSave: (t) async {
          await _treatmentRepo.create(t);
          Navigator.pop(context);
          _loadTreatmentsAndPrescriptions(_visits.map((v) => v.id).toList());
        },
      ),
    );
  }

  // ── Add Prescription ───────────────────────────────────────────────────────

  void _showAddPrescriptionSheet() {
    if (_visits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a visit first before adding prescriptions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPrescriptionSheet(
        visits: _visits,
        onSave: (p) async {
          await _prescriptionRepo.create(p);
          Navigator.pop(context);
          _loadTreatmentsAndPrescriptions(_visits.map((v) => v.id).toList());
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: _loadingPatient ? 100 : 180,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: AppTheme.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _loadingPatient
                  ? _buildLoadingHeader()
                  : _PatientHeader(
                      patient: _patient,
                      displayName: widget.patientName,
                      totalCost: _totalCost,
                    ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                  tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ProfileTab(patient: _patient, isLoading: _loadingPatient),
            _VisitsTab(
              visits: _visits,
              isLoading: _loadingVisits,
              onAdd: _showAddVisitSheet,
            ),
            _TreatmentsTab(
              treatments: _treatments,
              isLoading: _loadingTreatments,
              onAdd: _showAddTreatmentSheet,
              onStatusChange: (id, status) async {
                await _treatmentRepo.updateStatus(id, status);
                _loadTreatmentsAndPrescriptions(
                  _visits.map((v) => v.id).toList(),
                );
              },
            ),
            _PrescriptionsTab(
              prescriptions: _prescriptions,
              isLoading: _loadingPrescriptions,
              onAdd: _showAddPrescriptionSheet,
            ),
            const _FilesTab(),
            _BillingTab(treatments: _treatments, isLoading: _loadingTreatments),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3142C5), Color(0xFF4F63D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          widget.patientName,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Patient header ────────────────────────────────────────────────────────────

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({
    this.patient,
    required this.displayName,
    required this.totalCost,
  });

  final Patient? patient;
  final String displayName;
  final double totalCost;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final name = patient?.fullName ?? displayName;
    final gender = patient?.gender;
    final age = patient?.age;
    final phone = patient?.phone;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3142C5), Color(0xFF4F63D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, topPad + 52, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (gender != null) ...[
                          _InfoChip(Icons.person_outline, gender),
                          const SizedBox(width: 10),
                        ],
                        if (age != null) ...[
                          _InfoChip(Icons.cake_outlined, '$age yrs'),
                          const SizedBox(width: 10),
                        ],
                        if (phone != null)
                          _InfoChip(Icons.phone_outlined, phone),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FinStat('Total Cost', '₹${_fmt(totalCost)}', Colors.white),
              _FinStat('Visits', '${0}', Colors.lightBlueAccent),
              _FinStat('Treatments', '${0}', Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class _FinStat extends StatelessWidget {
  const _FinStat(this.label, this.value, this.valueColor);
  final String label, value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({this.patient, required this.isLoading});
  final Patient? patient;
  final bool isLoading;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  int _section = 0;

  static const _sections = [
    'Personal Details',
    'Contact Details',
    'Medical History',
  ];

  static const _conditions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Allergies',
    'Pregnancy',
    'Blood Disorder',
    'Thyroid',
  ];

  final Map<String, bool?> _conditionValues = {
    for (final c in const [
      'Diabetes',
      'Hypertension',
      'Heart Disease',
      'Asthma',
      'Allergies',
      'Pregnancy',
      'Blood Disorder',
      'Thyroid',
    ])
      c: null,
  };

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final p = widget.patient;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Section selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: List.generate(_sections.length, (i) {
                final sel = _section == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _section = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _sections[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel ? AppTheme.primaryColor : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          if (_section == 0) _buildPersonal(p),
          if (_section == 1) _buildContact(p),
          if (_section == 2) _buildMedical(),
        ],
      ),
    );
  }

  Widget _buildPersonal(Patient? p) {
    return _SectionCard(
      title: 'Patient Details',
      child: Column(
        children: [
          _DetailRow('First Name', p?.firstName ?? '—'),
          _DetailRow('Last Name', p?.lastName ?? '—'),
          _DetailRow('Gender', p?.gender ?? '—'),
          _DetailRow(
            'Date of Birth',
            p?.dateOfBirth == null ? '—' : _fmtDate(p!.dateOfBirth!),
          ),
          _DetailRow('Age', p?.age == null ? '—' : '${p!.age} years'),
          _DetailRow('Blood Group', p?.bloodGroup ?? '—'),
          _DetailRow('Dental History', p?.dentalHistory ?? '—'),
        ],
      ),
    );
  }

  Widget _buildContact(Patient? p) {
    return _SectionCard(
      title: 'Contact Information',
      child: Column(
        children: [
          _DetailRow('Phone', p?.phone ?? '—'),
          _DetailRow('Email', p?.email ?? '—'),
          _DetailRow('Address', p?.address ?? '—'),
        ],
      ),
    );
  }

  Widget _buildMedical() {
    return _SectionCard(
      title: 'Medical History',
      child: Column(
        children: _conditions.map((c) {
          final val = _conditionValues[c];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    c,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _TriStateToggle(
                  value: val,
                  onChanged: (v) => setState(() => _conditionValues[c] = v),
                ),
              ],
            ),
          );
        }).toList(),
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

// ── Visits Tab ────────────────────────────────────────────────────────────────

class _VisitsTab extends StatelessWidget {
  const _VisitsTab({
    required this.visits,
    required this.isLoading,
    required this.onAdd,
  });

  final List<Visit> visits;
  final bool isLoading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visits',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              _AddButton(label: 'Add Visit', onTap: onAdd),
            ],
          ),
          const SizedBox(height: 12),
          if (visits.isEmpty)
            _EmptyState(
              icon: Icons.event_note_outlined,
              message: 'No visits recorded yet',
              sub: 'Tap Add Visit to record a new visit',
            )
          else
            ...visits.asMap().entries.map(
              (e) => _AnimatedCard(
                delay: e.key * 80,
                child: _VisitCard(visit: e.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});
  final Visit visit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _fmtDateTime(visit.visitDate),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          if (visit.chiefComplaint != null) ...[
            const SizedBox(height: 8),
            _LabelValue('Chief Complaint', visit.chiefComplaint!),
          ],
          if (visit.diagnosis != null) ...[
            const SizedBox(height: 4),
            _LabelValue('Diagnosis', visit.diagnosis!),
          ],
          if (visit.notes != null) ...[
            const SizedBox(height: 4),
            _LabelValue('Notes', visit.notes!),
          ],
          if (visit.nextVisitDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Next visit: ${_fmtDateTime(visit.nextVisitDate!)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtDateTime(DateTime d) {
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

// ── Treatments Tab ────────────────────────────────────────────────────────────

class _TreatmentsTab extends StatelessWidget {
  const _TreatmentsTab({
    required this.treatments,
    required this.isLoading,
    required this.onAdd,
    required this.onStatusChange,
  });

  final List<TreatmentPlan> treatments;
  final bool isLoading;
  final VoidCallback onAdd;
  final void Function(String id, String status) onStatusChange;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Treatments',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              _AddButton(label: 'Add Treatment', onTap: onAdd),
            ],
          ),
          const SizedBox(height: 12),
          if (treatments.isEmpty)
            _EmptyState(
              icon: Icons.healing_outlined,
              message: 'No treatments yet',
              sub: 'Tap Add Treatment to begin',
            )
          else
            ...treatments.asMap().entries.map(
              (e) => _AnimatedCard(
                delay: e.key * 80,
                child: _TreatmentCard(
                  plan: e.value,
                  onStatusTap: () => _pickStatus(context, e.value),
                ),
              ),
            ),
          if (treatments.isNotEmpty) ...[
            const SizedBox(height: 8),
            _CostSummaryCard(treatments: treatments),
          ],
        ],
      ),
    );
  }

  void _pickStatus(BuildContext context, TreatmentPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusPickerSheet(
        current: plan.status ?? 'planned',
        onSelected: (s) {
          onStatusChange(plan.id, s);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.plan, required this.onStatusTap});
  final TreatmentPlan plan;
  final VoidCallback onStatusTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plan.treatmentName ?? 'Untitled Treatment',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onStatusTap,
                child: _StatusBadge(plan.status ?? 'planned'),
              ),
            ],
          ),
          if (plan.description != null) ...[
            const SizedBox(height: 6),
            Text(
              plan.description!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          if (plan.totalCost != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.currency_rupee_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                Text(
                  plan.totalCost!.toStringAsFixed(0),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({required this.treatments});
  final List<TreatmentPlan> treatments;

  @override
  Widget build(BuildContext context) {
    final total = treatments.fold<double>(0, (s, t) => s + (t.totalCost ?? 0));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(
            Icons.summarize_outlined,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Total Treatment Cost',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '₹${total.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final String status;

  static const _labels = {
    'planned': 'Planned',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'discontinued': 'Discontinued',
  };

  static const _colors = {
    'planned': Color(0xFFFFA000),
    'in_progress': AppTheme.primaryColor,
    'completed': Color(0xFF388E3C),
    'discontinued': Color(0xFF9E9E9E),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _labels[status] ?? status,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, size: 14, color: color),
        ],
      ),
    );
  }
}

class _StatusPickerSheet extends StatelessWidget {
  const _StatusPickerSheet({required this.current, required this.onSelected});
  final String current;
  final ValueChanged<String> onSelected;

  static const _options = [
    'planned',
    'in_progress',
    'completed',
    'discontinued',
  ];

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Update Status',
      child: Column(
        children: _options.map((s) {
          return ListTile(
            leading: _StatusBadge(s),
            trailing: s == current
                ? const Icon(Icons.check, color: AppTheme.primaryColor)
                : null,
            onTap: () => onSelected(s),
          );
        }).toList(),
      ),
    );
  }
}

// ── Prescriptions Tab ─────────────────────────────────────────────────────────

class _PrescriptionsTab extends StatelessWidget {
  const _PrescriptionsTab({
    required this.prescriptions,
    required this.isLoading,
    required this.onAdd,
  });

  final List<Prescription> prescriptions;
  final bool isLoading;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prescriptions',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              _AddButton(label: 'Add Prescription', onTap: onAdd),
            ],
          ),
          const SizedBox(height: 12),
          if (prescriptions.isEmpty)
            _EmptyState(
              icon: Icons.medication_outlined,
              message: 'No prescriptions yet',
              sub: 'Tap Add Prescription to begin',
            )
          else
            ...prescriptions.asMap().entries.map(
              (e) => _AnimatedCard(
                delay: e.key * 80,
                child: _PrescriptionCard(prescription: e.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.prescription});
  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medication_outlined,
                size: 18,
                color: Colors.teal.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prescription.medicineName ?? 'Medicine',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (prescription.dosage != null) _Chip(prescription.dosage!),
              if (prescription.duration != null) _Chip(prescription.duration!),
              if (prescription.instructions != null)
                _Chip(prescription.instructions!),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
      ),
    );
  }
}

// ── Files Tab ─────────────────────────────────────────────────────────────────

class _FilesTab extends StatelessWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Files & Documents',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload X-rays, scans & reports',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Billing Tab ───────────────────────────────────────────────────────────────

class _BillingTab extends StatelessWidget {
  const _BillingTab({required this.treatments, required this.isLoading});
  final List<TreatmentPlan> treatments;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final total = treatments.fold<double>(0, (s, t) => s + (t.totalCost ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Divider(height: 16),
                _BillRow(
                  'Total Treatment Cost',
                  '₹${total.toStringAsFixed(0)}',
                ),
                _BillRow('Amount Paid', '₹0'),
                _BillRow(
                  'Balance',
                  '₹${total.toStringAsFixed(0)}',
                  isBalance: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (treatments.isEmpty)
            _EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No billing records',
              sub: 'Add treatments to see billing info',
            )
          else
            ...treatments.map(
              (t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.treatmentName ?? 'Treatment',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            t.status ?? 'planned',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${(t.totalCost ?? 0).toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow(this.label, this.value, {this.isBalance = false});
  final String label, value;
  final bool isBalance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isBalance ? Colors.orange.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Visit Sheet ───────────────────────────────────────────────────────────

class _AddVisitSheet extends StatefulWidget {
  const _AddVisitSheet({required this.patientId, required this.onSave});
  final String patientId;
  final ValueChanged<Visit> onSave;

  @override
  State<_AddVisitSheet> createState() => _AddVisitSheetState();
}

class _AddVisitSheetState extends State<_AddVisitSheet> {
  final _complaintCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _visitDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Add Visit',
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
                    'Visit Date: ${_visitDate.day}/${_visitDate.month}/${_visitDate.year}',
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
            label: 'Diagnosis',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _SheetField(controller: _notesCtrl, label: 'Notes', maxLines: 2),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                  : const Text('Save Visit'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    setState(() => _saving = true);
    widget.onSave(
      Visit(
        id: '',
        patientId: widget.patientId,
        visitDate: _visitDate,
        chiefComplaint: _complaintCtrl.text.trim().isEmpty
            ? null
            : _complaintCtrl.text.trim(),
        diagnosis: _diagnosisCtrl.text.trim().isEmpty
            ? null
            : _diagnosisCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ),
    );
  }
}

// ── Add Treatment Sheet ───────────────────────────────────────────────────────

class _AddTreatmentSheet extends StatefulWidget {
  const _AddTreatmentSheet({required this.visits, required this.onSave});
  final List<Visit> visits;
  final ValueChanged<TreatmentPlan> onSave;

  @override
  State<_AddTreatmentSheet> createState() => _AddTreatmentSheetState();
}

class _AddTreatmentSheetState extends State<_AddTreatmentSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String _status = 'planned';
  late String _visitId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _visitId = widget.visits.first.id;
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _visitId,
            decoration: const InputDecoration(labelText: 'Visit'),
            items: widget.visits
                .map(
                  (v) => DropdownMenuItem(
                    value: v.id,
                    child: Text(
                      '${v.visitDate.day}/${v.visitDate.month}/${v.visitDate.year}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _visitId = v!),
          ),
          const SizedBox(height: 12),
          _SheetField(controller: _nameCtrl, label: 'Treatment Name *'),
          const SizedBox(height: 12),
          _SheetField(controller: _descCtrl, label: 'Description', maxLines: 2),
          const SizedBox(height: 12),
          _SheetField(
            controller: _costCtrl,
            label: 'Total Cost (₹)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Text(
            'Status',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['planned', 'in_progress', 'completed', 'discontinued']
                .map(
                  (s) => GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: _status == s
                        ? _StatusBadge(s)
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving || _nameCtrl.text.isEmpty ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Save Treatment'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    widget.onSave(
      TreatmentPlan(
        id: '',
        visitId: _visitId,
        treatmentName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        totalCost: double.tryParse(_costCtrl.text),
        status: _status,
      ),
    );
  }
}

// ── Add Prescription Sheet ────────────────────────────────────────────────────

class _AddPrescriptionSheet extends StatefulWidget {
  const _AddPrescriptionSheet({required this.visits, required this.onSave});
  final List<Visit> visits;
  final ValueChanged<Prescription> onSave;

  @override
  State<_AddPrescriptionSheet> createState() => _AddPrescriptionSheetState();
}

class _AddPrescriptionSheetState extends State<_AddPrescriptionSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  late String _visitId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _visitId = widget.visits.first.id;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _durationCtrl.dispose();
    _instructionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetWrapper(
      title: 'Add Prescription',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _visitId,
            decoration: const InputDecoration(labelText: 'Visit'),
            items: widget.visits
                .map(
                  (v) => DropdownMenuItem(
                    value: v.id,
                    child: Text(
                      '${v.visitDate.day}/${v.visitDate.month}/${v.visitDate.year}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _visitId = v!),
          ),
          const SizedBox(height: 12),
          _SheetField(controller: _nameCtrl, label: 'Medicine Name *'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetField(controller: _dosageCtrl, label: 'Dosage'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetField(
                  controller: _durationCtrl,
                  label: 'Duration',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SheetField(
            controller: _instructionsCtrl,
            label: 'Instructions',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
                  : const Text('Save Prescription'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    widget.onSave(
      Prescription(
        id: '',
        visitId: _visitId,
        medicineName: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim().isEmpty
            ? null
            : _dosageCtrl.text.trim(),
        duration: _durationCtrl.text.trim().isEmpty
            ? null
            : _durationCtrl.text.trim(),
        instructions: _instructionsCtrl.text.trim().isEmpty
            ? null
            : _instructionsCtrl.text.trim(),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
  });
  final IconData icon;
  final String message, sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            icon,
            size: 52,
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

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
    this.keyboardType = TextInputType.text,
  });
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;

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

class _TriStateToggle extends StatelessWidget {
  const _TriStateToggle({required this.value, required this.onChanged});
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TriBtn('Yes', value == true, Colors.green, () => onChanged(true)),
        const SizedBox(width: 4),
        _TriBtn('No', value == false, Colors.red, () => onChanged(false)),
        const SizedBox(width: 4),
        _TriBtn('?', value == null, Colors.grey, () => onChanged(null)),
      ],
    );
  }
}

class _TriBtn extends StatelessWidget {
  const _TriBtn(this.label, this.selected, this.color, this.onTap);
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  const _AnimatedCard({required this.child, this.delay = 0});
  final Widget child;
  final int delay;

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
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
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
