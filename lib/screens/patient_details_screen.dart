import 'package:flutter/foundation.dart';
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

  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
    _resolveDoctorId();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _resolveDoctorId() async {
    try {
      _doctorId = await _visitRepo.getDoctorIdForCurrentUser();
    } catch (_) {}
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
      setState(() {
        _patient = p;
        _loadingPatient = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPatient = false);
    }
  }

  Future<void> _loadOngoing() async {
    if (!mounted) return;
    debugPrint(
      '[PatientDetails] Loading ongoing visits for ${widget.patientId}',
    );
    setState(() => _loadingOngoing = true);
    try {
      final v = await _visitRepo.getOngoing(widget.patientId);
      debugPrint('[PatientDetails] Loaded ${v.length} ongoing visits');
      if (!mounted) return;
      setState(() {
        _ongoingVisits = v;
        _loadingOngoing = false;
      });
    } catch (e) {
      debugPrint('[PatientDetails] Error loading ongoing: $e');
      if (mounted) setState(() => _loadingOngoing = false);
    }
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    debugPrint(
      '[PatientDetails] Loading history visits for ${widget.patientId}',
    );
    setState(() => _loadingHistory = true);
    try {
      final v = await _visitRepo.getHistory(widget.patientId);
      debugPrint('[PatientDetails] Loaded ${v.length} history visits');
      if (!mounted) return;
      setState(() {
        _historyVisits = v;
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint('[PatientDetails] Error loading history: $e');
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _showNewConsultationModal() async {
    debugPrint('[PatientDetails] Opening new consultation modal');

    // onSave only does the DB insert; the dialog closes itself with result=true.
    // We await the dialog here, so tab animation + refresh happen AFTER the
    // dialog is fully dismissed — avoiding any navigator confusion.
    final saved = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => NewConsultationSheet(
        patientId: widget.patientId,
        doctorId: _doctorId,
        onSave: (v) async {
          debugPrint('[PatientDetails] onSave — inserting visit into Supabase');
          final result = await _visitRepo.createVisit(v);
          debugPrint('[PatientDetails] Visit inserted: id=${result.id}');
        },
      ),
    );

    // Refresh ongoing list and switch to Ongoing tab after save
    if (saved == true && mounted) {
      await _loadOngoing();
      _tabController.animateTo(1);
    }
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

            Expanded(
              child: Container(
                color: kRefScreenBg,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProfileTab(patient: _patient, isLoading: _loadingPatient),
                    OngoingTab(
                      patientId: widget.patientId,
                      patientName: widget.patientName,
                      visitDetails: _ongoingVisits,
                      isLoading: _loadingOngoing,
                      onRefresh: _loadOngoing,
                      onRefreshAll: _loadAll,
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
                      patientName: widget.patientName,
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
