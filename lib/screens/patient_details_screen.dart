import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../models/visit_detail_model.dart';
import '../repositories/patient_repository.dart';
import '../repositories/visit_detail_repository.dart';
import '../services/patient_session.dart';
import '../widgets/patient_details_widgets.dart';
import 'patient_form_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.initialTabIndex = 0,
    this.patientPortalMode = false,
    /// Patient shell: fires when Home requests Ongoing (1) or History (2).
    this.careNavSignal,
    this.careTargetTabResolver,
  });

  final String patientId;
  final String patientName;
  final int initialTabIndex;
  final bool patientPortalMode;
  final ValueNotifier<int>? careNavSignal;
  final int Function()? careTargetTabResolver;

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
    _tabController = TabController(
      length: 3, 
      vsync: this, 
      initialIndex: widget.initialTabIndex,
    );
    _loadAll();
    _resolveDoctorId();
    widget.careNavSignal?.addListener(_onCareNavSignal);
    // First open of Patient tab after Home may have bumped the signal before we subscribed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.patientPortalMode) return;
      final s = widget.careNavSignal;
      if (s != null && s.value > 0) _onCareNavSignal();
    });
  }

  @override
  void dispose() {
    widget.careNavSignal?.removeListener(_onCareNavSignal);
    _tabController.dispose();
    super.dispose();
  }

  void _onCareNavSignal() {
    if (!widget.patientPortalMode) return;
    final resolve = widget.careTargetTabResolver;
    if (resolve == null) return;
    final idx = resolve().clamp(0, 2);
    if (_tabController.index != idx) {
      _tabController.animateTo(idx);
    }
  }

  @override
  void didUpdateWidget(PatientDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.careNavSignal != oldWidget.careNavSignal) {
      oldWidget.careNavSignal?.removeListener(_onCareNavSignal);
      widget.careNavSignal?.addListener(_onCareNavSignal);
    }
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
      if (widget.patientPortalMode && p != null) {
        final name = p.fullName.trim().isNotEmpty ? p.fullName : p.firstName;
        PatientSession.setPortal(
          patientId: p.id,
          displayName: name,
          patient: p,
        );
      }
      setState(() {
        _patient = p;
        _loadingPatient = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPatient = false);
    }
  }

  String _headerDisplayName() {
    final p = _patient;
    if (p != null) {
      final full = p.fullName.trim();
      if (full.isNotEmpty) return full;
      return p.firstName;
    }
    return widget.patientName;
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

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
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
        builder: (_) => PatientFormScreen(
          initialPatient: _patient,
          appBarTitle:
              widget.patientPortalMode ? 'Update profile' : null,
        ),
      ),
    );
    if (!mounted || updated != true) return;
    await _loadPatient();
    if (widget.patientPortalMode) await _loadAll();
  }

  Future<void> _deletePatient() async {
    final patient = _patient;
    if (patient == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Patient',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete ${patient.fullName}? This action will permanently remove their records.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _patientRepo.delete(patient.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${patient.fullName} deleted'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          debugPrint('[PatientDetails] Deletion successful, popping with true');
          Navigator.of(context).pop(true); // Go back to PatientListScreen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    }
  }

  void _showEditConsultationModal(VisitDetail detail) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewConsultationSheet(
        patientId: widget.patientId,
        existingVisit: detail.visit,
        onSave: (v) async {
          await _visitRepo.updateVisit(v.id, v.toUpdateJson());
          if (mounted) _loadOngoing();
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
                    displayName: _headerDisplayName(),
                    onBack: Navigator.of(context).canPop()
                        ? () => Navigator.of(context).pop()
                        : null,
                    onNewConsultation: widget.patientPortalMode
                        ? null
                        : _showNewConsultationModal,
                    onEdit: _patient == null ? null : _showEditPatient,
                    editTooltip: widget.patientPortalMode
                        ? 'Update profile'
                        : 'Edit Patient',
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
                    ProfileTab(
                      patient: _patient,
                      isLoading: _loadingPatient,
                      onDelete: widget.patientPortalMode ? null : _deletePatient,
                    ),
                    OngoingTab(
                      patientId: widget.patientId,
                      patientName: widget.patientName,
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
                      patientName: widget.patientName,
                      visitDetails: _historyVisits,
                      isLoading: _loadingHistory,
                      onRefresh: _loadHistory,
                      onEditVisit: widget.patientPortalMode
                          ? null
                          : _showEditConsultationModal,
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
