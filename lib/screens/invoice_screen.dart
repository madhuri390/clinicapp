import 'package:flutter/material.dart';

import '../services/pdf_generator_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// Mock treatment line item for invoice.
class _TreatmentItem {
  const _TreatmentItem({required this.name, required this.amount});

  final String name;
  final double amount;
}

/// Invoice preview screen: patient, visit, treatment summary, amounts, actions.
class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  // Mock data
  static const String _patientName = 'James Chen';
  static final DateTime _visitDate = DateTime(2025, 2, 28);
  static const double _totalAmount = 1515.00;
  static const double _paidAmount = 945.00;
  static const double _balance = _totalAmount - _paidAmount;

  bool _isPaid = false;

  static const List<_TreatmentItem> _treatments = [
    _TreatmentItem(name: 'Root Canal - Molar', amount: 450.00),
    _TreatmentItem(name: 'Dental Crown', amount: 850.00),
    _TreatmentItem(name: 'Teeth Cleaning', amount: 120.00),
    _TreatmentItem(name: 'X-Ray (Full Mouth)', amount: 95.00),
  ];

  Future<void> _onGeneratePdf() async {
    final treatmentsMap = _treatments
        .map((t) => {'name': t.name, 'amount': t.amount})
        .toList();

    await PdfGeneratorService.generateInvoicePdf(
      patientName: _patientName,
      visitDate: _visitDate,
      treatments: treatmentsMap,
      totalAmount: _totalAmount,
      paidAmount: _isPaid ? _totalAmount : _paidAmount,
      balance: _isPaid ? 0.0 : _balance,
    );
  }

  void _onMarkAsPaid() {
    setState(() => _isPaid = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice marked as paid'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _isPaid ? 0.0 : _balance;
    final paidAmount = _isPaid ? _totalAmount : _paidAmount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Invoice',
          style: TextStyle(
            color: AppTokens.ink,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppTokens.body),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InvoiceHeaderCard(
                    patientName: _patientName,
                    visitDate: _visitDate,
                  ),
                  const SizedBox(height: 16),
                  _TreatmentSummaryCard(treatments: _treatments),
                  const SizedBox(height: 16),
                  _AmountsCard(
                    totalAmount: _totalAmount,
                    paidAmount: paidAmount,
                    balance: balance,
                    isPaid: _isPaid,
                  ),
                ],
              ),
            ),
          ),
          Material(
            elevation: 8,
            color: AppTokens.subtle,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _onGeneratePdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 22),
                      label: const Text('Generate PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isPaid ? null : _onMarkAsPaid,
                      icon: Icon(
                        _isPaid
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 22,
                      ),
                      label: Text(_isPaid ? 'Paid' : 'Mark as Paid'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceHeaderCard extends StatelessWidget {
  const _InvoiceHeaderCard({
    required this.patientName,
    required this.visitDate,
  });

  final String patientName;
  final DateTime visitDate;

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(visitDate);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTokens.body),
                    ),
                    Text(
                      patientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTokens.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit Date',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTokens.body),
                  ),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTokens.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
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

class _TreatmentSummaryCard extends StatelessWidget {
  const _TreatmentSummaryCard({required this.treatments});

  final List<_TreatmentItem> treatments;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Treatment Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTokens.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...treatments.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t.name,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppTokens.ink),
                    ),
                  ),
                  Text(
                    '₹${t.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTokens.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountsCard extends StatelessWidget {
  const _AmountsCard({
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.isPaid,
  });

  final double totalAmount;
  final double paidAmount;
  final double balance;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          _AmountRow(label: 'Total Amount', value: totalAmount),
          const SizedBox(height: 12),
          _AmountRow(label: 'Paid Amount', value: paidAmount),
          const Divider(height: 24),
          _AmountRow(
            label: 'Balance',
            value: balance,
            valueColor: isPaid ? AppTokens.success : AppTokens.warning,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
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
            color: AppTokens.body,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: valueColor ?? AppTokens.ink,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
