import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Mock medicine item in a prescription.
class _Medicine {
  _Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.duration,
    required this.instructions,
  });

  final String id;
  final String name;
  final String dosage;
  final String duration;
  final String instructions;
}

/// Prescription management screen: list of medicines, add form, Generate PDF (UI only).
class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  int _nextId = 10;

  final List<_Medicine> _medicines = [
    _Medicine(
      id: '1',
      name: 'Amoxicillin 500mg',
      dosage: '1 capsule',
      duration: '7 days',
      instructions: 'Three times daily after meals',
    ),
    _Medicine(
      id: '2',
      name: 'Ibuprofen 400mg',
      dosage: '1 tablet',
      duration: '5 days',
      instructions: 'As needed for pain, max 3 per day',
    ),
    _Medicine(
      id: '3',
      name: 'Chlorhexidine Mouthwash',
      dosage: '15 ml',
      duration: '10 days',
      instructions: 'Rinse twice daily after brushing',
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onAddMedicine() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _medicines.add(_Medicine(
        id: '$_nextId',
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        duration: _durationController.text.trim(),
        instructions: _instructionsController.text.trim(),
      ));
      _nextId++;
    });

    _nameController.clear();
    _dosageController.clear();
    _durationController.clear();
    _instructionsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine added'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _onGeneratePdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generate PDF (coming soon)'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Prescription',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: 'Medicines'),
            const SizedBox(height: 12),
            if (_medicines.isEmpty)
              _EmptyMedicinesCard()
            else
              ..._medicines.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MedicineCard(medicine: m),
                ),
              ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Add Medicine'),
            const SizedBox(height: 12),
            _AddMedicineFormCard(
              formKey: _formKey,
              nameController: _nameController,
              dosageController: _dosageController,
              durationController: _durationController,
              instructionsController: _instructionsController,
              onAdd: _onAddMedicine,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onGeneratePdf,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 22),
              label: const Text('Generate PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

class _EmptyMedicinesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No medicines added yet. Use the form below to add.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine});

  final _Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication_outlined,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(label: 'Dosage', value: medicine.dosage),
                    _DetailRow(label: 'Duration', value: medicine.duration),
                    _DetailRow(label: 'Instructions', value: medicine.instructions),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _AddMedicineFormCard extends StatelessWidget {
  const _AddMedicineFormCard({
    required this.formKey,
    required this.nameController,
    required this.dosageController,
    required this.durationController,
    required this.instructionsController,
    required this.onAdd,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final TextEditingController durationController;
  final TextEditingController instructionsController;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Medicine name *',
                hintText: 'e.g. Amoxicillin 500mg',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Medicine name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage *',
                hintText: 'e.g. 1 tablet, 5 ml',
                prefixIcon: Icon(Icons.science_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Dosage is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration *',
                hintText: 'e.g. 7 days, 2 weeks',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Duration is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: instructionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Instructions *',
                hintText: 'e.g. Take after meals, twice daily',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Instructions are required' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
