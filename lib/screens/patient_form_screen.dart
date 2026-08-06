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

  bool get _isEditing => widget.initialPatient != null;

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

    try {
      String patientId = _isEditing ? widget.initialPatient!.id : '';
      String? authUserId = _isEditing ? widget.initialPatient!.authUserId : null;

      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text;

      final authEmail = email.isNotEmpty ? email : '$username@prodontics.local';

      // ── Step 1: Handle Auth (Create or Update) ───────────────────────────
      // We do this BEFORE the SQL update so that if email is taken, 
      // we don't save inconsistent data to our patients table.
      
      if (!_isEditing || authUserId == null) {
        // CASE A: NEW PATIENT OR UPGRADING EXISTING PATIENT TO PORTAL
        // Create the auth user first
        final newAuthId = await AuthService.adminCreateUser(
          email: authEmail,
          phone: phone.isNotEmpty ? phone : null,
          password: password,
        );
        authUserId = newAuthId;
        // If it was a new patient, the SQL ID will also be this.
        // If it was an edit of an existing patient who lacked an ID, 
        // we keep the patientId as is but update the authUserId field.
        if (!_isEditing) {
          patientId = newAuthId;
        }
      } else {
        // CASE B: UPDATING EXISTING PATIENT WHO ALREADY HAS AUTH
        await AuthService.adminUpdateUser(
          userId: authUserId,
          email: authEmail,
          phone: phone.isNotEmpty ? phone : null,
          password: password.isEmpty ? null : password,
        );
      }

      // ── Step 2: Build and Save SQL Record ─────────────────────────────────
      final patient = Patient(
        id: patientId,
        username: username,
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
        authUserId: authUserId,
      );

      if (_isEditing) {
        await _repo.update(widget.initialPatient!.id, patient.toUpdateJson());
      } else {
        // Use upsert for new patients so ID matches Auth
        await _repo.upsert(patient);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Patient ${patient.fullName} ${_isEditing ? 'updated' : 'saved'} successfully',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $errorMsg'),
          backgroundColor: AppTokens.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
              controller: _usernameController,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: 'Username *',
                hint: 'Enter unique username',
                icon: Icons.account_circle_outlined,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Username is required';
                }
                return null;
              },
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
            _SectionHeader(
              title: _isEditing ? 'Portal access' : 'Portal access *',
              icon: Icons.lock_outline_rounded,
              subtitle: _isEditing
                  ? 'Leave blank to keep the current password.'
                  : 'Set a password so this patient can log in to the portal.',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: _fieldTextStyle(context),
              decoration: _decoration(
                context,
                label: _isEditing ? 'New password' : 'Password *',
                hint: _isEditing
                    ? 'Enter new password to change'
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
                final val = v?.trim() ?? '';
                final currentAuthId = widget.initialPatient?.authUserId;
                
                // Password is required if this is a new patient OR 
                // if it's an existing patient who doesn't have an Auth record yet.
                if (currentAuthId == null && val.isEmpty) {
                  return 'Password is required to create portal access';
                }
                if (val.isNotEmpty && val.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
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
