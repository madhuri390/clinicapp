import 'package:flutter/material.dart';

import '../models/patient_model.dart';
import '../repositories/patient_repository.dart';
import '../theme/app_theme.dart';

/// Form screen to add a new patient with validation and scrollable layout.
class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key, this.initialPatient});

  final Patient? initialPatient;

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _dentalHistoryController = TextEditingController();
  final _emailController = TextEditingController();

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    _dentalHistoryController.dispose();
    _emailController.dispose();
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
      final patient = Patient(
        id: '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
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
      );
      if (_isEditing) {
        await _repo.update(widget.initialPatient!.id, patient.toUpdateJson());
      } else {
        await _repo.create(patient);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
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
          _isEditing ? 'Edit Patient' : 'Add Patient',
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
                labelText: 'Phone *',
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
                final email = _emailController.text.trim();
                
                if (phone.isEmpty && email.isEmpty) {
                  return 'Phone or Email is required';
                }
                
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
                labelText: 'Email Address',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                final email = v?.trim() ?? '';
                final phone = _phoneController.text.trim();

                if (email.isEmpty && phone.isEmpty) {
                  return 'Phone or Email is required';
                }

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
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
