import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';
import '../theme/patient_portal_theme.dart';
import '../widgets/ui_kit.dart';

/// Form screen to add a new patient with validation and scrollable layout.
class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key, this.initialPatient, this.appBarTitle});

  final Patient? initialPatient;

  /// When set (e.g. patient portal), overrides the default "Edit Patient" title.
  final String? appBarTitle;

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _dentalHistoryController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  List<String> _medicalConditions = [];
  final _conditionInputController = TextEditingController();

  String? _gender;
  DateTime? _dateOfBirth;
  String? _bloodGroup;
  bool _saving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  /// Whether this patient should have a portal login.
  ///
  /// Off by default: a clinic needs a *record* for everyone who walks in, and a
  /// *login* only for the few who use the portal. Welding the two together is
  /// what made a name correction impossible and blocked two family members from
  /// sharing one phone number.
  bool _portalEnabled = false;

  bool get _isEditing => widget.initialPatient != null;

  /// Whether this patient already has a portal login to update, as opposed to
  /// one that still has to be created. Drives whether the password is required.
  bool get _hasExistingLogin => widget.initialPatient?.authUserId != null;

  final _repo = PatientRepository();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.initialPatient!;
      _usernameController.text = p.username ?? '';
      _firstNameController.text = p.firstName;
      _lastNameController.text = p.lastName ?? '';
      _phoneController.text = p.phone;
      _addressController.text = p.address ?? '';
      _medicalHistoryController.text = p.medicalHistory ?? '';
      _dentalHistoryController.text = p.dentalHistory ?? '';
      _emailController.text = p.email ?? '';
      _gender = p.gender;
      _dateOfBirth = p.dateOfBirth;
      _bloodGroup = p.bloodGroup;
      _portalEnabled = p.authUserId != null;

      if (p.medicalHistory != null && p.medicalHistory!.isNotEmpty) {
        _medicalConditions = p.medicalHistory!
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
  }

  static const List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  static const List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _dentalHistoryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _conditionInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted errors'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _saving = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    try {
      // ── Step 1: Save the patient record ────────────────────────────────
      //
      // This runs FIRST and on its own. A name correction is a change to a
      // dental record; it must never be gated on an identity provider being
      // reachable or its pointer being valid. The previous order called Auth
      // first, so a stale auth_user_id (404) threw before the record was ever
      // written and the edit was silently lost.
      final patient = Patient(
        id: _isEditing ? widget.initialPatient!.id : '',
        username: _portalEnabled && username.isNotEmpty ? username : null,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        phone: phone,
        email: email,
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        bloodGroup: _bloodGroup,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        medicalHistory: _medicalConditions.isEmpty
            ? null
            : _medicalConditions.join(', '),
        dentalHistory: _dentalHistoryController.text.trim().isEmpty
            ? null
            : _dentalHistoryController.text.trim(),
        createdAt: _isEditing ? widget.initialPatient!.createdAt : null,
        authUserId: _isEditing ? widget.initialPatient!.authUserId : null,
      );

      final saved = _isEditing
          ? await _repo.update(widget.initialPatient!.id, patient.toUpdateJson())
          : await _repo.create(patient);

      // ── Step 2: Portal login, only if asked for ────────────────────────
      //
      // Everything below is optional. If it fails the record is already safe,
      // so we report the credential problem without losing the demographics.
      String? portalWarning;
      if (_portalEnabled) {
        final authEmail =
            email.isNotEmpty ? email : '$username@prodontics.local';
        try {
          final existingAuthId = saved.authUserId;
          var linkedId = existingAuthId;

          if (existingAuthId != null) {
            try {
              await AuthService.adminUpdateUser(
                userId: existingAuthId,
                email: authEmail,
                password: password.isEmpty ? null : password,
              );
            } on AuthUserNotFoundException {
              // The pointer is stale — the migration wrote each patient's own
              // row id into auth_user_id, naming accounts that never existed.
              // Treat it as "no login yet" and mint a real one.
              linkedId = null;
            }
          }

          if (linkedId == null) {
            if (password.isEmpty) {
              portalWarning = 'Patient saved, but portal access needs a '
                  'password. Re-open the record and set one.';
            } else {
              // Phone is deliberately NOT sent to Auth: auth.users enforces a
              // unique phone, which is what stopped a second family member on
              // a shared number. The number lives on the patients row, which
              // has no such constraint.
              linkedId = await AuthService.adminCreateUser(
                email: authEmail,
                password: password,
              );
            }
          }

          if (linkedId != null && linkedId != existingAuthId) {
            await _repo.update(saved.id, {'auth_user_id': linkedId});
          }
        } catch (e) {
          portalWarning = 'Patient saved, but portal login failed: '
              '${_cleanError(e)}';
        }
      } else if (saved.authUserId != null) {
        // Portal switched off: drop the link so the record stops claiming a
        // login it does not have.
        await _repo.update(saved.id, {'auth_user_id': null});
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            portalWarning ??
                'Patient ${patient.fullName} '
                    '${_isEditing ? 'updated' : 'saved'} successfully',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              portalWarning != null ? AppTokens.warning : AppTheme.primaryColor,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${_cleanError(e)}'),
          backgroundColor: AppTokens.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _cleanError(Object e) {
    final msg = e.toString();
    return msg.startsWith('Exception: ')
        ? msg.replaceFirst('Exception: ', '')
        : msg;
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.appBarTitle ?? (_isEditing ? 'Edit patient' : 'Add patient');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(title, style: AppTheme.textTheme.titleLarge),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppTokens.ink),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          children: [
            Text(
              _isEditing
                  ? 'Update the record and portal access for this patient.'
                  : 'Create a patient record and their portal login.',
              style: PatientPortalTheme.body(context),
            ),
            const SizedBox(height: 22),
            const _SectionHeader(
              title: 'Personal information',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: 'First name *',
                hint: 'Enter first name',
                icon: Icons.badge_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: 'Last name',
                hint: 'Enter last name',
                icon: Icons.badge_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: 'Phone',
                hint: 'Optional',
                icon: Icons.phone_outlined,
              ),
              onChanged: (v) {
                if (_autovalidateMode == AutovalidateMode.always) return;
                // Trigger validation of email when phone changes to clear/show errors
                _formKey.currentState?.validate();
              },
              validator: (v) {
                final phone = v?.trim() ?? '';
                if (phone.isNotEmpty) {
                  final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                  if (!phoneRegex.hasMatch(phone)) {
                    return 'Enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: _fieldTextStyle(context),
              onChanged: (v) {
                if (_autovalidateMode == AutovalidateMode.always) return;
                // Trigger validation of phone when email changes to clear/show errors
                _formKey.currentState?.validate();
              },
              decoration: _decoration(
                context,
                label: 'Email address',
                hint: 'Optional',
                icon: Icons.email_outlined,
              ),
              validator: (v) {
                final email = v?.trim() ?? '';
                if (email.isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                  );
                  if (!emailRegex.hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              style: _fieldTextStyle(context),
              borderRadius: BorderRadius.circular(18),
              icon: const Icon(Icons.expand_more_rounded,
                  color: AppTokens.muted),
              decoration: _decoration(
                context,
                label: 'Gender',
                hint: 'Select gender',
                icon: Icons.wc_outlined,
              ),
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDateOfBirth,
              borderRadius: BorderRadius.circular(20),
              child: InputDecorator(
                decoration: _decoration(
                  context,
                  label: 'Date of birth',
                  hint: 'Select date',
                  icon: Icons.calendar_today_outlined,
                ),
                child: Text(
                  _dateOfBirth == null
                      ? 'Select date'
                      : _formatDate(_dateOfBirth!),
                  style: _fieldTextStyle(context).copyWith(
                    color: _dateOfBirth == null ? AppTokens.muted : AppTokens.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _bloodGroup,
              style: _fieldTextStyle(context),
              borderRadius: BorderRadius.circular(18),
              icon: const Icon(Icons.expand_more_rounded,
                  color: AppTokens.muted),
              decoration: _decoration(
                context,
                label: 'Blood group',
                hint: 'Select blood group',
                icon: Icons.bloodtype_outlined,
              ),
              items: _bloodGroups
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodGroup = v),
            ),
            const SizedBox(height: 28),
            const _SectionHeader(
              title: 'Address',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: 'Address',
                hint: 'Street, city, state, zip',
                icon: Icons.home_outlined,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            const _SectionHeader(
              title: 'Medical & dental history',
              icon: Icons.medical_information_outlined,
            ),
            const SizedBox(height: 14),
            _buildPillInput(),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dentalHistoryController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: 'Dental history',
                hint: 'Previous treatments, concerns…',
                icon: Icons.notes_outlined,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            const _SectionHeader(
              title: 'Portal access',
              icon: Icons.lock_outline_rounded,
              subtitle: 'Optional. Only needed if this patient will sign in to '
                  'the portal themselves.',
            ),
            const SizedBox(height: 6),
            SwitchListTile.adaptive(
              value: _portalEnabled,
              onChanged: (v) {
                setState(() => _portalEnabled = v);
                _formKey.currentState?.validate();
              },
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppTheme.primaryColor,
              title: Text(
                'Allow this patient to log in',
                style: _fieldTextStyle(context),
              ),
              subtitle: Text(
                _portalEnabled
                    ? 'A login will be created for this patient.'
                    : 'No login. The patient record saves on its own.',
                style: PatientPortalTheme.body(context).copyWith(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            // Credentials only exist when the patient actually has a login, so
            // they only appear — and are only required — when the switch is on.
            if (_portalEnabled) ...[
              TextFormField(
                controller: _usernameController,
                style: _fieldTextStyle(context),
                decoration: _decoration(
                  context,
                  label: 'Login ID *',
                  hint: 'What the patient types to sign in',
                  icon: Icons.account_circle_outlined,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]')),
                ],
                validator: (v) {
                  if (!_portalEnabled) return null;
                  if ((v ?? '').trim().isEmpty) {
                    return 'Login ID is required for portal access';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: _fieldTextStyle(context),
                decoration: _decoration(
                  context,
                  label: _hasExistingLogin ? 'New password' : 'Password *',
                  hint: _hasExistingLogin
                      ? 'Leave blank to keep the current password'
                      : 'Min. 6 characters',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTokens.muted,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (!_portalEnabled) return null;
                  final val = v?.trim() ?? '';
                  // Only an account that already exists can keep its password.
                  if (!_hasExistingLogin && val.isEmpty) {
                    return 'Password is required to create portal access';
                  }
                  if (val.isNotEmpty && val.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        saving: _saving,
        label: _isEditing ? 'Update patient' : 'Save patient',
        onSave: _onSave,
      ),
    );
  }

  // ── Field styling ─────────────────────────────────────────────────────────
  // Mirrors the login form: white pill fields on the gradient canvas, border
  // only as a hairline at rest and in brand blue on focus.

  TextStyle _fieldTextStyle(BuildContext context) =>
      PatientPortalTheme.titleMedium(context).copyWith(fontSize: 15);

  InputDecoration _decoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: PatientPortalTheme.body(context),
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(icon, color: PatientPortalTheme.brightBlue, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.85),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: border(Colors.transparent),
      enabledBorder: border(AppTokens.hairline),
      focusedBorder: border(PatientPortalTheme.brightBlue, 1.8),
      errorBorder: border(AppTokens.danger),
      focusedErrorBorder: border(AppTokens.danger, 1.8),
    );
  }

  Widget _buildPillInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_medicalConditions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medicalConditions.map((condition) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: AppTokens.accentSoft,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppTokens.rPill)),
                    border: Border.all(color: AppTokens.hairline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        condition,
                        style: AppTheme.textTheme.labelLarge?.copyWith(
                          fontSize: 13,
                          color: AppTokens.accentDeep,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(
                            () => _medicalConditions.remove(condition)),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.close_rounded,
                              size: 15, color: AppTokens.accentDark),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _conditionInputController,
                style: _fieldTextStyle(context),
                decoration: _decoration(
                  context,
                  label: 'Medical conditions',
                  hint: 'e.g. Asthma — then tap Add',
                  icon: Icons.monitor_heart_outlined,
                ),
                onFieldSubmitted: (v) => _addCondition(),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 58,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _addCondition,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: PatientPortalTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTokens.accentGlow(),
                    ),
                    child: const SizedBox(
                      width: 58,
                      child: Icon(Icons.add_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addCondition() {
    final text = _conditionInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        if (!_medicalConditions.contains(text)) {
          _medicalConditions.add(text);
        }
        _conditionInputController.clear();
      });
    }
  }

  static String _formatDate(DateTime d) {
    const months = [
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
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

/// Group heading: a small gradient icon tile, the title, and optional helper
/// copy underneath.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HeroIconBadge(icon: icon, size: 32, iconSize: 17),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTokens.ink,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: PatientPortalTheme.body(context)),
        ],
      ],
    );
  }
}

/// Sticky footer holding the primary action, so a long form never hides it.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saving,
    required this.label,
    required this.onSave,
  });

  final bool saving;
  final String label;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: AppTokens.hairline)),
      ),
      child: saving
          ? const SizedBox(
              height: 54,
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      PatientPortalTheme.brightBlue,
                    ),
                  ),
                ),
              ),
            )
          : GradientButton(
              label: label,
              icon: Icons.check_rounded,
              onPressed: onSave,
            ),
    );
  }
}
