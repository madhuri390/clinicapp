import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/ui_kit.dart';
import 'patient_details_screen.dart';
import 'patient_form_screen.dart';
import '../theme/app_tokens.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => PatientListScreenState();
}

class PatientListScreenState extends State<PatientListScreen> {
  final _repo = PatientRepository();
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Patient> _patients = [];
  bool _loading = true;
  String? _error;

  Timer? _searchDebounce;

  /// Bumped on every new query so a slow in-flight response cannot overwrite
  /// the results of a newer one.
  int _requestId = 0;
  bool _loadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchCtrl.addListener(_onSearchChanged);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPatients({String query = ''}) async {
    final requestId = ++_requestId;
    debugPrint('[PatientList] load#$requestId start query="$query"');
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = query.isEmpty
          ? await _repo.getAll()
          : await _repo.search(query);
      debugPrint('[PatientList] load#$requestId got ${list.length} '
          '(current=$_requestId mounted=$mounted)');
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _patients = list;
        _hasMore = list.length == PatientRepository.pageSize;
        _loadingMore = false;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[PatientList] load#$requestId FAILED: $e\n$st');
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Append the next page. Bails out if the query changed while it was in
  /// flight, so pages never get stitched onto a different result set.
  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final requestId = _requestId;
    final query = _searchCtrl.text.trim();
    setState(() => _loadingMore = true);
    try {
      final offset = _patients.length;
      final more = query.isEmpty
          ? await _repo.getAll(offset: offset)
          : await _repo.search(query, offset: offset);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _patients = [..._patients, ...more];
        _hasMore = more.length == PatientRepository.pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loadingMore = false;
        _hasMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) _loadMore();
  }

  Future<void> refresh() => _loadPatients(query: _searchCtrl.text.trim());

  void _onSearchChanged() {
    // Every keystroke used to fire its own round trip; wait for a pause first.
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _loadPatients(query: _searchCtrl.text.trim());
    });
  }

  Future<void> _openDetails(Patient patient) async {
    final result = await Navigator.of(context).push<bool>(
      FadeSlideRoute<bool>(
        page: PatientDetailsScreen(
          patientId: patient.id,
          patientName: patient.fullName,
        ),
      ),
    );

    if (mounted) {
      if (result == true) {
        _searchCtrl.clear();
        _searchDebounce?.cancel(); // clear() already queued a reload
        await _loadPatients();
      } else {
        await refresh();
      }
    }
  }

  Future<void> _onAddPatient() async {
    final added = await Navigator.of(context).push<bool>(
      FadeSlideRoute<bool>(page: const PatientFormScreen()),
    );
    if (added == true && mounted) {
      await _loadPatients(query: _searchCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AnimatedEntrance(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patients',
                                style:
                                    PatientPortalTheme.displayLarge(context)),
                            const SizedBox(height: 2),
                            Text('Manage your patient records',
                                style: PatientPortalTheme.body(context)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedEntrance(
                index: 1,
                child: _SearchBar(controller: _searchCtrl),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: PatientPortalTheme.buttonGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: PatientPortalTheme.glow(PatientPortalTheme.brightSky),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onAddPatient,
            borderRadius: BorderRadius.circular(30),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Add Patient',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HeroIconBadge(
                icon: Icons.wifi_off_rounded,
                size: 72,
                iconSize: 34,
                gradient: LinearGradient(
                  colors: [AppTokens.danger, AppTokens.danger],
                ),
                glowColor: AppTokens.danger,
              ),
              const SizedBox(height: 18),
              Text('Unable to load patients',
                  style: PatientPortalTheme.titleMedium(context)),
              const SizedBox(height: 6),
              Text(
                _error!,
                style: PatientPortalTheme.body(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: () => _loadPatients(),
              ),
            ],
          ),
        ),
      );
    }
    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeroIconBadge(
                icon: Icons.people_rounded, size: 72, iconSize: 34),
            const SizedBox(height: 18),
            Text(
              _searchCtrl.text.isEmpty
                  ? 'No patients yet'
                  : 'No patients match your search',
              style: PatientPortalTheme.titleMedium(context),
              textAlign: TextAlign.center,
            ),
            if (_searchCtrl.text.isEmpty) ...[
              const SizedBox(height: 8),
              Text('Tap “Add Patient” to get started',
                  style: PatientPortalTheme.body(context)),
            ],
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadPatients(query: _searchCtrl.text.trim()),
      color: PatientPortalTheme.brightBlue,
      child: ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        itemCount: _patients.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _patients.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            );
          }
          final p = _patients[i];
          return AnimatedEntrance(
            // Stagger only the first screenful: at 80ms per index, tile 30 was
            // waiting 2.4s to fade in after it scrolled into view.
            index: i < 8 ? i : 0,
            child: _PatientTile(patient: p, onTap: () => _openDetails(p)),
          );
        },
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c, width: w),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: TextField(
        controller: controller,
        style: PatientPortalTheme.titleMedium(context).copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search by name or phone',
          hintStyle: PatientPortalTheme.body(context),
          prefixIcon:
              const Icon(Icons.search_rounded, color: PatientPortalTheme.brightBlue),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: controller.clear,
                  ),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.85),
          border: border(Colors.transparent),
          enabledBorder: border(AppTokens.hairline),
          focusedBorder: border(PatientPortalTheme.brightBlue, 1.8),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Patient tile ──────────────────────────────────────────────────────────────

class _PatientTile extends StatelessWidget {
  const _PatientTile({
    required this.patient,
    required this.onTap,
  });
  final Patient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: PatientPortalTheme.glassDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: PatientPortalTheme.accentGradient,
                    boxShadow:
                        PatientPortalTheme.glow(PatientPortalTheme.brightSky),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    patient.firstName.isNotEmpty
                        ? patient.firstName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: PatientPortalTheme.titleMedium(context),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 13, color: PatientPortalTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            patient.phone,
                            style: PatientPortalTheme.body(context)
                                .copyWith(fontSize: 12),
                          ),
                          if (patient.gender != null) ...[
                            const SizedBox(width: 12),
                            Text(
                              patient.gender!,
                              style: PatientPortalTheme.body(context)
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                          if (patient.age != null)
                            Text(
                              ', ${patient.age}y',
                              style: PatientPortalTheme.body(context)
                                  .copyWith(fontSize: 12),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: PatientPortalTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
