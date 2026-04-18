import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../models/visit_detail_model.dart';
import '../repositories/patient_repository.dart';
import '../repositories/visit_detail_repository.dart';
import '../widgets/patient_details_widgets.dart';
import 'patient_form_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.patientPortalMode = false,
  });

  final String patientId;
  final String patientName;
  final bool patientPortalMode;

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final _patientRepo = PatientRepository();
  final _visitRepo = VisitDetailRepository();

  Patient? _patient;
  List<VisitDetail> _ongoingVisits = [];
  List<VisitDetail> _historyVisits = [];

  bool _loadingPatient = true;
  bool _loadingOngoing = true;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    _loadPatient();
    _loadOngoing();
    _loadHistory();
  }

  Future<void> _loadPatient() async {
    try {
      final p = await _patientRepo.getById(widget.patientId);
      if (!mounted) return;
      setState(() { _patient = p; _loadingPatient = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPatient = false);
    }
  }

  Future<void> _loadOngoing() async {
    if (!mounted) return;
    setState(() => _loadingOngoing = true);
    try {
      final v = await _visitRepo.getOngoing(widget.patientId);
      if (!mounted) return;
      setState(() { _ongoingVisits = v; _loadingOngoing = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingOngoing = false);
    }
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _loadingHistory = true);
    try {
      final v = await _visitRepo.getHistory(widget.patientId);
      if (!mounted) return;
      setState(() { _historyVisits = v; _loadingHistory = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  void _showNewConsultationModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => NewConsultationSheet(
        patientId: widget.patientId,
        onSave: (v) async {
          await _visitRepo.createVisit(v);
          if (mounted) {
            Navigator.pop(context);
            _tabController.animateTo(1);
            _loadOngoing();
          }
        },
      ),
    );
  }

  Future<void> _showEditPatient() async {
    if (_patient == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PatientFormScreen(initialPatient: _patient),
      ),
    );
    if (updated == true && mounted) {
      _loadPatient();
    }
  }

  void _showEditConsultationModal(VisitDetail detail) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => NewConsultationSheet(
        patientId: widget.patientId,
        existingVisit: detail.visit,
        onSave: (v) async {
          await _visitRepo.updateVisit(v.id, v.toUpdateJson());
          if (mounted) {
            Navigator.pop(context);
            _loadOngoing();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Main header (patient-header + new-btn) ──────────────
            _loadingPatient
                ? const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : PatientHeader(
                    patient: _patient,
                    displayName: widget.patientName,
                    onNewConsultation: widget.patientPortalMode
                        ? null
                        : _showNewConsultationModal,
                    onEdit: widget.patientPortalMode ? null : _showEditPatient,
                  ),

            // ── Tab bar (underline style, matching .tab-bar) ────────
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: kRefBorder, width: 1.5),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: kRefPrimary,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: kRefPrimary,
                unselectedLabelColor: kRefTabInactive,
                labelStyle: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 16),
                        SizedBox(width: 6),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14),
                        SizedBox(width: 6),
                        Text('Ongoing'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 16),
                        SizedBox(width: 6),
                        Text('History'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Screen container (#F9FAFE bg) ───────────────────────
            Expanded(
              child: Container(
                color: kRefScreenBg,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProfileTab(patient: _patient, isLoading: _loadingPatient),
                    OngoingTab(
                      patientId: widget.patientId,
                      visitDetails: _ongoingVisits,
                      isLoading: _loadingOngoing,
                      onRefresh: _loadOngoing,
                      onRefreshAll: _loadAll,
                      onEditVisit: widget.patientPortalMode
                          ? null
                          : _showEditConsultationModal,
                      onComplete: widget.patientPortalMode
                          ? null
                          : () {
                              _loadOngoing();
                              _loadHistory();
                              _tabController.animateTo(2);
                            },
                      readOnly: widget.patientPortalMode,
                    ),
                    HistoryTab(
                      patientId: widget.patientId,
                      visitDetails: _historyVisits,
                      isLoading: _loadingHistory,
                      onRefresh: _loadHistory,
                      readOnly: widget.patientPortalMode,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
