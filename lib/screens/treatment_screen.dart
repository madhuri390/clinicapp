import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'payment_screen.dart';

/// Treatment status for a plan item.
enum TreatmentStatus { pending, inProgress, completed }

/// Mock treatment item.
class _Treatment {
  const _Treatment({
    required this.id,
    required this.name,
    required this.totalCost,
    required this.status,
  });

  final String id;
  final String name;
  final double totalCost;
  final TreatmentStatus status;
}

/// Screen to manage treatment plans for a visit. Lists treatments and summary.
class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  static final List<_Treatment> _mockTreatments = [
    const _Treatment(
      id: '1',
      name: 'Root Canal - Molar',
      totalCost: 450.00,
      status: TreatmentStatus.completed,
    ),
    const _Treatment(
      id: '2',
      name: 'Dental Crown',
      totalCost: 850.00,
      status: TreatmentStatus.inProgress,
    ),
    const _Treatment(
      id: '3',
      name: 'Teeth Cleaning',
      totalCost: 120.00,
      status: TreatmentStatus.completed,
    ),
    const _Treatment(
      id: '4',
      name: 'X-Ray (Full Mouth)',
      totalCost: 95.00,
      status: TreatmentStatus.pending,
    ),
  ];

  // Mock: assume 50% of completed + inProgress is paid
  double get _totalCost =>
      _mockTreatments.fold(0, (sum, t) => sum + t.totalCost);

  double get _totalPaid {
    double paid = 0;
    for (final t in _mockTreatments) {
      if (t.status == TreatmentStatus.completed) {
        paid += t.totalCost;
      } else if (t.status == TreatmentStatus.inProgress) {
        paid += t.totalCost * 0.5;
      }
    }
    return paid;
  }

  double get _balance => _totalCost - _totalPaid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Treatment Plan',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.payment_outlined),
            tooltip: 'Payment',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const PaymentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: _mockTreatments.length,
              itemBuilder: (context, index) {
                return _TreatmentCard(treatment: _mockTreatments[index]);
              },
            ),
          ),
          _SummaryCard(
            totalCost: _totalCost,
            totalPaid: _totalPaid,
            balance: _balance,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddTreatment,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Treatment'),
      ),
    );
  }

  void _onAddTreatment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Treatment (coming soon)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.treatment});

  final _Treatment treatment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treatment.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${treatment.totalCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _StatusChip(status: treatment.status),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TreatmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = switch (status) {
      TreatmentStatus.pending => (
        'Pending',
        Colors.orange.shade50,
        Colors.orange.shade800,
      ),
      TreatmentStatus.inProgress => (
        'In Progress',
        Colors.blue.shade50,
        Colors.blue.shade800,
      ),
      TreatmentStatus.completed => (
        'Completed',
        Colors.green.shade50,
        Colors.green.shade800,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalCost,
    required this.totalPaid,
    required this.balance,
  });

  final double totalCost;
  final double totalPaid;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: 'Total Cost', value: totalCost),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Total Paid', value: totalPaid),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Balance',
              value: balance,
              valueColor: balance > 0
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.black54,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? Colors.black87,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
