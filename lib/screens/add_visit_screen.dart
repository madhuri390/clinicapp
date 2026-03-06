import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Screen to add a patient visit with date, doctor, complaint, diagnosis, notes.
class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _chiefComplaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _visitDate;
  DateTime? _nextVisitDate;

  @override
  void initState() {
    super.initState();
    _visitDate = DateTime.now();
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _chiefComplaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _pickNextVisitDate() async {
    final initial = _nextVisitDate ?? _visitDate.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(_visitDate) ? _visitDate : initial,
      firstDate: _visitDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _nextVisitDate = picked);
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Visit saved'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Add Visit',
          style: TextStyle(
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _SectionHeader(title: 'Visit Details'),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickVisitDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Visit Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _formatDate(_visitDate),
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _doctorNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Doctor Name *',
                hintText: 'Enter doctor name',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Doctor name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Clinical'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _chiefComplaintController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Chief Complaint *',
                hintText: 'Reason for visit...',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Chief complaint is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                hintText: 'Findings, diagnosis...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional notes...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Follow-up'),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickNextVisitDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Next Visit Date',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(
                  _nextVisitDate == null
                      ? 'Select date (optional)'
                      : _formatDate(_nextVisitDate!),
                  style: TextStyle(
                    color: _nextVisitDate == null
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Save Visit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
