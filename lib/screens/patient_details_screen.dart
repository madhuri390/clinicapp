import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../models/visit_detail_model.dart';
import '../repositories/patient_repository.dart';
import '../repositories/visit_detail_repository.dart';
import '../services/patient_session.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/patient_details_widgets.dart';
import '../widgets/ui_kit.dart';
import 'patient_form_screen.dart';
import '../theme/app_tokens.dart';

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

  // Visit tabs are fetched the first time they are shown, not on open: the
  // nested visit select is the expensive query and Profile is the landing tab.
  bool _ongoingRequested = false;
  bool _historyRequested = false;

  bool _historyHasMore = true;
  bool _loadingMoreHistory = false;

  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this, 
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_onTabChanged);
    _loadPatient();
    _loadVisibleTab();
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Fires twice per swipe (start + settle); both are cheap because
    // _loadVisibleTab only fetches a tab that has not been requested yet.
    _loadVisibleTab();
  }

  /// Fetch whatever the currently selected tab needs, once.
  void _loadVisibleTab() {
    switch (_tabController.index) {
      case 1:
        if (!_ongoingRequested) _loadOngoing();
      case 2:
        if (!_historyRequested) _loadHistory();
    }
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

  /// Refresh the patient plus any visit tab that has already been opened —
  /// tabs still untouched stay lazy and load when they are first shown.
  Future<void> _loadAll() async {
    _loadPatient();
    if (_ongoingRequested) _loadOngoing();
    if (_historyRequested) _loadHistory();
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
    _ongoingRequested = true;
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

  /// Loads (or reloads) the first page of completed visits.
  Future<void> _loadHistory() async {
    if (!mounted) return;
    _historyRequested = true;
    debugPrint(
      '[PatientDetails] Loading history visits for ${widget.patientId}',
    );
    setState(() {
      _loadingHistory = true;
      _loadingMoreHistory = false;
    });
    try {
      final v = await _visitRepo.getHistory(widget.patientId);
      debugPrint('[PatientDetails] Loaded ${v.length} history visits');
      if (!mounted) return;
      setState(() {
        _historyVisits = v;
        _historyHasMore = v.length == VisitDetailRepository.historyPageSize;
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint('[PatientDetails] Error loading history: $e');
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  /// Appends the next page of older consultations.
  Future<void> _loadMoreHistory() async {
    if (_loadingHistory || _loadingMoreHistory || !_historyHasMore) return;
    setState(() => _loadingMoreHistory = true);
    try {
      final more = await _visitRepo.getHistory(
        widget.patientId,
        offset: _historyVisits.length,
      );
      if (!mounted) return;
      setState(() {
        _historyVisits = [..._historyVisits, ...more];
        _historyHasMore = more.length == VisitDetailRepository.historyPageSize;
        _loadingMoreHistory = false;
      });
    } catch (e) {
      debugPrint('[PatientDetails] Error loading more history: $e');
      if (!mounted) return;
      setState(() {
        _loadingMoreHistory = false;
        _historyHasMore = false;
      });
    }
  }

  Future<void> _showNewConsultationModal() async {
    debugPrint('[PatientDetails] Opening new consultation modal');

    final saved = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierColor: AppTokens.body,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Patient',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete ${patient.fullName}? This action will permanently remove their records.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: AppTokens.body, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
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
              backgroundColor: AppTokens.danger,
            ),
          );
        }
      }
    }
  }

  void _showEditConsultationModal(VisitDetail detail) {
    showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierColor: AppTokens.body,
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
      backgroundColor: Colors.transparent,
      body: _maybeGradient(
        SafeArea(
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
                    editLabel: widget.patientPortalMode
                        ? 'Update profile'
                        : 'Edit details',
                  ),

            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                boxShadow: PatientPortalTheme.cardShadow(context),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: PatientPortalTheme.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: PatientPortalTheme.glow(PatientPortalTheme.brightSky),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: kRefTabInactive,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(20),
                padding: EdgeInsets.zero,
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
                color: Colors.transparent,
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
                      hasMore: _historyHasMore,
                      isLoadingMore: _loadingMoreHistory,
                      onLoadMore: _loadMoreHistory,
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
      ),
    );
  }

  Widget _maybeGradient(Widget child) => AppGradientBackground(child: child);
}
