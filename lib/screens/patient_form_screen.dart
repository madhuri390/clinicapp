import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

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
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.appBarTitle ??
              (_isEditing ? 'Edit Patient' : 'Add Patient'),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.grey.shade700),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            _SectionHeader(title: 'Personal Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username *',
                hintText: 'Enter unique username',
                prefixIcon: Icon(Icons.account_circle_outlined),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                hintText: 'Enter first name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'First name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter last name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone (Optional)',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone_outlined),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) {
                if (_autovalidateMode == AutovalidateMode.always) return;
                // Trigger validation of phone when email changes to clear/show errors
                _formKey.currentState?.validate();
              },
              decoration: const InputDecoration(
                labelText: 'Email Address (Optional)',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email_outlined),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc_outlined),
              ),
              hint: const Text('Select gender'),
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateOfBirth,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _dateOfBirth == null
                      ? 'Select date'
                      : _formatDate(_dateOfBirth!),
                  style: TextStyle(
                    color: _dateOfBirth == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _bloodGroup,
              decoration: const InputDecoration(
                labelText: 'Blood Group',
                prefixIcon: Icon(Icons.bloodtype_outlined),
              ),
              hint: const Text('Select blood group'),
              items: _bloodGroups
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodGroup = v),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Address'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Street, city, state, zip',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Medical & Dental History'),
            const SizedBox(height: 12),
            _buildPillInput(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dentalHistoryController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Dental History',
                hintText: 'Previous treatments, concerns...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: _isEditing ? 'Portal Access' : 'Portal Access *',
            ),
            const SizedBox(height: 4),
            Text(
              _isEditing
                  ? 'Leave blank to keep the current password.'
                  : 'Set a password so this patient can log in to the portal.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: _isEditing ? 'New Password' : 'Password *',
                hintText: _isEditing ? 'Enter new password to change' : 'Min. 6 characters',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade600,
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
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _saving ? null : _onSave,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: _saving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(
          _saving
              ? 'Saving...'
              : (_isEditing ? 'Update Patient' : 'Save Patient'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPillInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medical Conditions',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (_medicalConditions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _medicalConditions.map((condition) {
                return Chip(
                  label: Text(
                    condition,
                    style: const TextStyle(fontSize: 13),
                  ),
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() {
                      _medicalConditions.remove(condition);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _conditionInputController,
                decoration: const InputDecoration(
                  hintText: 'Add condition (e.g. Asthma)',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onFieldSubmitted: (v) => _addCondition(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addCondition,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
