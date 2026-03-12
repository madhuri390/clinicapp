import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'invoice_screen.dart';

/// Mock payment record.
class _PaymentRecord {
  const _PaymentRecord({
    required this.id,
    required this.amount,
    required this.mode,
    required this.date,
    this.notes,
  });

  final String id;
  final double amount;
  final String mode;
  final DateTime date;
  final String? notes;
}

/// Payment screen for a treatment plan: summary, form, and payment history.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _paymentMode;

  static const List<String> _paymentModes = ['Cash', 'UPI', 'Card'];

  // Mock summary
  static const double _totalCost = 1515.00;
  static const double _totalPaid = 945.00;
  static const double _balance = _totalCost - _totalPaid;

  static final List<_PaymentRecord> _previousPayments = [
    _PaymentRecord(
      id: '1',
      amount: 450.00,
      mode: 'Cash',
      date: DateTime(2025, 2, 28),
      notes: 'Root canal payment',
    ),
    _PaymentRecord(
      id: '2',
      amount: 425.00,
      mode: 'Card',
      date: DateTime(2025, 2, 20),
      notes: 'Crown - advance',
    ),
    _PaymentRecord(
      id: '3',
      amount: 120.00,
      mode: 'UPI',
      date: DateTime(2025, 2, 15),
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onRecordPayment() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _amountController.clear();
    _notesController.clear();
    setState(() => _paymentMode = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of ₹${amount.toStringAsFixed(2)} recorded'),
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
          'Payment',
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
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Invoice',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const InvoiceScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryCard(
              totalCost: _totalCost,
              totalPaid: _totalPaid,
              balance: _balance,
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Record Payment'),
            const SizedBox(height: 12),
            _PaymentFormCard(
              formKey: _formKey,
              amountController: _amountController,
              notesController: _notesController,
              paymentMode: _paymentMode,
              paymentModes: _paymentModes,
              onModeChanged: (v) => setState(() => _paymentMode = v),
              onRecord: _onRecordPayment,
            ),
            const SizedBox(height: 28),
            _SectionHeader(title: 'Previous Payments'),
            const SizedBox(height: 12),
            ..._previousPayments.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PaymentListTile(record: p),
              ),
            ),
          ],
        ),
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
      child: Column(
        children: [
          _SummaryRow(label: 'Total Cost', value: totalCost),
          const SizedBox(height: 12),
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
          '₹${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? Colors.black87,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
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

class _PaymentFormCard extends StatelessWidget {
  const _PaymentFormCard({
    required this.formKey,
    required this.amountController,
    required this.notesController,
    required this.paymentMode,
    required this.paymentModes,
    required this.onModeChanged,
    required this.onRecord,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final String? paymentMode;
  final List<String> paymentModes;
  final ValueChanged<String?> onModeChanged;
  final VoidCallback onRecord;

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
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount *',
                hintText: '0.00',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: paymentMode,
              decoration: const InputDecoration(
                labelText: 'Payment Mode *',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
              hint: const Text('Select mode'),
              items: paymentModes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: onModeChanged,
              validator: (v) => v == null ? 'Select payment mode' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Optional notes...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRecord,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentListTile extends StatelessWidget {
  const _PaymentListTile({required this.record});

  final _PaymentRecord record;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(record.date);
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle_outline,
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
                  '₹${record.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _ModeChip(mode: record.mode),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    record.notes!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        mode,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
