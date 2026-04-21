import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/staff_model.dart';
import 'auth_service.dart';
import 'staff_service.dart';

class PdfGeneratorService {
  static Future<void> generateInvoicePdf({
    required String patientName,
    required DateTime visitDate,
    required List<Map<String, dynamic>> treatments,
    required double totalAmount,
    required double paidAmount,
    required double balance,
  }) async {
    final pdf = pw.Document();
    
    // Load Assets
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/prodontics_logo.png')).buffer.asUint8List(),
    );
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    // Fetch Doctor data
    final docDetails = await _getDoctorDetails();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildLetterhead(logoImage, docDetails, boldFont, regularFont),
          pw.SizedBox(height: 20),
          _buildInvoiceHeader(patientName, visitDate, boldFont, regularFont),
          pw.SizedBox(height: 20),
          _buildInvoiceTable(treatments, boldFont, regularFont),
          pw.SizedBox(height: 20),
          _buildInvoiceTotals(totalAmount, paidAmount, balance, boldFont, regularFont),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${patientName.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> generatePrescriptionPdf({
    required String patientName,
    required DateTime visitDate,
    required List<Map<String, dynamic>> medicines,
  }) async {
    final pdf = pw.Document();

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/prodontics_logo.png')).buffer.asUint8List(),
    );
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    final docDetails = await _getDoctorDetails();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildLetterhead(logoImage, docDetails, boldFont, regularFont),
          pw.SizedBox(height: 20),
          _buildPrescriptionHeader(patientName, visitDate, boldFont, regularFont),
          pw.SizedBox(height: 20),
          _buildMedicinesList(medicines, boldFont, regularFont),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rx_${patientName.replaceAll(' ', '_')}.pdf',
    );
  }

  // --- Helper Methods ---

  static Future<Staff?> _getDoctorDetails() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return null;
      
      final staffList = await StaffService.instance.getStaff();
      for (var staff in staffList) {
        if (staff.authUserId == user.id) {
          return staff;
        }
      }
    } catch (_) {}
    return null;
  }

  static pw.Widget _buildLetterhead(pw.MemoryImage logo, Staff? doctor, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(logo, width: 140),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  doctor?.name ?? 'Doctor',
                  style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  doctor?.role ?? 'General Dentist',
                  style: pw.TextStyle(font: regularFont, fontSize: 12, color: PdfColors.grey700),
                ),
                if (doctor?.phone != null && doctor!.phone!.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    doctor.phone!,
                    style: pw.TextStyle(font: regularFont, fontSize: 11, color: PdfColors.grey600),
                  ),
                ],
                if (doctor?.email != null && doctor!.email!.isNotEmpty) ...[
                  pw.Text(
                    doctor.email!,
                    style: pw.TextStyle(font: regularFont, fontSize: 11, color: PdfColors.grey600),
                  ),
                ],
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.blue100, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildInvoiceHeader(String patientName, DateTime visitDate, pw.Font boldFont, pw.Font regularFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE / RECEIPT', style: pw.TextStyle(font: boldFont, fontSize: 16)),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              pw.Text('Patient: ', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.Text(patientName, style: pw.TextStyle(font: regularFont, fontSize: 12)),
            ]),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Date: ${DateFormat('dd MMM yyyy').format(visitDate)}', style: pw.TextStyle(font: regularFont, fontSize: 12)),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(List<Map<String, dynamic>> treatments, pw.Font boldFont, pw.Font regularFont) {
    return pw.TableHelper.fromTextArray(
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 11),
      cellStyle: pw.TextStyle(font: regularFont, fontSize: 11),
      headers: ['Treatment Description', 'Amount'],
      data: treatments.map((t) => [t['name'] as String, 'Rs. ${(t['amount'] as double).toStringAsFixed(2)}']).toList(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
    );
  }

  static pw.Widget _buildInvoiceTotals(double total, double paid, double balance, pw.Font boldFont, pw.Font regularFont) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Total Amount: ', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.SizedBox(width: 40),
              pw.Text('Rs. ${total.toStringAsFixed(2)}', style: pw.TextStyle(font: regularFont, fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Paid Amount: ', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.SizedBox(width: 40),
              pw.Text('Rs. ${paid.toStringAsFixed(2)}', style: pw.TextStyle(font: regularFont, fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.SizedBox(width: 200, child: pw.Divider()),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
               pw.Text('Balance: ', style: pw.TextStyle(font: boldFont, fontSize: 14)),
               pw.SizedBox(width: 40),
               pw.Text('Rs. ${balance.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 14, color: balance > 0 ? PdfColors.red : PdfColors.green)),
            ],
          ),
        ]
      )
    );
  }

  static pw.Widget _buildPrescriptionHeader(String patientName, DateTime visitDate, pw.Font boldFont, pw.Font regularFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Rx.', style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColors.blue800)),
            pw.SizedBox(height: 8),
            pw.Row(children: [
              pw.Text('Patient: ', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              pw.Text(patientName, style: pw.TextStyle(font: regularFont, fontSize: 12)),
            ]),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Date: ${DateFormat('dd MMM yyyy').format(visitDate)}', style: pw.TextStyle(font: regularFont, fontSize: 12)),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildMedicinesList(List<Map<String, dynamic>> medicines, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: medicines.map((m) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(m['name'] as String, style: pw.TextStyle(font: boldFont, fontSize: 13, color: PdfColors.black)),
              pw.SizedBox(height: 4),
              pw.Text('Dosage: ${m['dosage']}   |   Duration: ${m['duration']}', style: pw.TextStyle(font: regularFont, fontSize: 11, color: PdfColors.grey800)),
              pw.SizedBox(height: 2),
              pw.Text('Instructions: ${m['instructions']}', style: pw.TextStyle(font: regularFont, fontSize: 11, color: PdfColors.grey700)),
            ]
          )
        );
      }).toList(),
    );
  }
}
