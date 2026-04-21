import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model.dart';
import '../models/visit_detail_model.dart';
import '../repositories/patient_repository.dart';
import '../repositories/visit_detail_repository.dart';
import '../models/staff_model.dart';
import 'auth_service.dart';
import 'staff_service.dart';

class PdfGeneratorService {
  // Spec: primary blue #0973c1, divider #a1d3e2
  static const _primaryBlue = PdfColor.fromInt(0xFF0973C1);
  static const _dividerBlue = PdfColor.fromInt(0xFFA1D3E2);
  static const _textDark = PdfColor.fromInt(0xFF222222);
  static const _border = PdfColor.fromInt(0xFFD1D1D1);

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
      (await rootBundle.load(
        'assets/images/invoice_logo.png',
      )).buffer.asUint8List(),
    );
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
    final italicFont = await PdfGoogleFonts.interItalic();
    final boldItalicFont = await PdfGoogleFonts.interBoldItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(5),
        header: (_) => buildPdfHeader(
          logo: logoImage,
          bold: boldFont,
          regular: regularFont,
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          _invoicePatientBar(
            patientName: patientName,
            generatedAt: DateTime.now(),
            regularItalic: italicFont,
            boldItalic: boldItalicFont,
            bold: boldFont,
          ),
          pw.SizedBox(height: 12),
          _buildInvoiceHeader(patientName, visitDate, boldFont, regularFont),
          pw.SizedBox(height: 12),
          _buildInvoiceTable(treatments, boldFont, regularFont),
          pw.SizedBox(height: 14),
          _buildInvoiceTotals(
            totalAmount,
            paidAmount,
            balance,
            boldFont,
            regularFont,
          ),
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
      (await rootBundle.load(
        'assets/images/invoice_logo.png',
      )).buffer.asUint8List(),
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
          _buildPrescriptionHeader(
            patientName,
            visitDate,
            boldFont,
            regularFont,
          ),
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

  /// DB-backed dental prescription PDF (A4, single page) for a visit.
  /// Matches the reference design provided by the user.
  static Future<void> generatePrescriptionPdfForVisit({
    required String visitId,
  }) async {
    final client = Supabase.instance.client;
    final visitRepo = VisitDetailRepository();
    final patientRepo = PatientRepository();

    final detail = await visitRepo.getById(visitId);
    if (detail == null) {
      throw Exception('Visit not found');
    }

    final patient = await patientRepo.getById(detail.visit.patientId);
    if (patient == null) {
      throw Exception('Patient not found');
    }

    // Header (STRICT): hardcoded doctor + clinic text to exactly match reference.
    // We still keep doctorName for footer signature label.
    final doctorName = 'DR. SURYA TEJA. S';

    // Investigations from file_attachments for this visit.
    final files = await client
        .from('file_attachments')
        .select('file_name, file_type')
        .eq('visit_id', visitId)
        .order('created_at', ascending: true);
    final investigations = (files as List)
        .map((e) => (e as Map<String, dynamic>))
        .map(
          (e) => (
            name: (e['file_name'] as String?)?.trim() ?? 'Investigation',
            type: (e['file_type'] as String?)?.trim(),
          ),
        )
        .toList();

    // Load assets + fonts.
    // Logo: use existing PNG asset for now.
    // If you want to use the provided PDF logo, we should add a raster (PNG) version
    // to assets and load it here (PDF → image rasterization isn't reliable across all Flutter targets).
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(
        'assets/images/invoice_logo.png',
      )).buffer.asUint8List(),
    );
    final regular = await PdfGoogleFonts.interRegular();
    final bold = await PdfGoogleFonts.interBold();
    final italic = await PdfGoogleFonts.interItalic();
    final boldItalic = await PdfGoogleFonts.interBoldItalic();
    final signatureFont = await PdfGoogleFonts.dancingScriptRegular();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              buildPdfHeader(logo: logoImage, bold: bold, regular: regular),
              pw.SizedBox(height: 10),
              _patientInfoBar(
                patient: patient,
                generatedAt: DateTime.now(),
                regularItalic: italic,
                boldItalic: boldItalic,
                bold: bold,
              ),
              pw.SizedBox(height: 12),
              _rxBody(
                detail: detail,
                patient: patient,
                investigations: investigations,
                bold: bold,
                regular: regular,
              ),
              pw.Spacer(),
              _rxFooterSignature(
                doctorName: doctorName,
                signatureFont: signatureFont,
                bold: bold,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name:
          'Prescription_${patient.fullName.replaceAll(' ', '_')}_${visitId.substring(0, 8)}.pdf',
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

  static pw.Widget _buildLetterhead(
    pw.MemoryImage logo,
    Staff? doctor,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
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
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 18,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  doctor?.role ?? 'General Dentist',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  doctor?.phone ?? '+91 98765 43210',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  doctor?.email ?? 'info@prodontics.in',
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.blue100, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildInvoiceHeader(
    String patientName,
    DateTime visitDate,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INVOICE / RECEIPT',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 14,
                color: _primaryBlue,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Text(
                  'Patient: ',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
                pw.Text(
                  patientName,
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Date: ${DateFormat('dd MMM yyyy').format(visitDate)}',
              style: pw.TextStyle(font: regularFont, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceTable(
    List<Map<String, dynamic>> treatments,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    final headerStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 10,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(
      font: regularFont,
      fontSize: 10.5,
      color: _textDark,
    );

    final rows = treatments.map((t) {
      final name = (t['name'] as String?) ?? '';
      final amount = (t['amount'] as num?)?.toDouble() ?? 0;
      return [name, '₹${amount.toStringAsFixed(0)}'];
    }).toList();

    if (rows.isEmpty) {
      rows.add(['—', '—']);
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primaryBlue),
          children: [
            _th('Treatment Description', headerStyle),
            _th('Amount', headerStyle, center: true),
          ],
        ),
        ...rows.map(
          (r) => pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
            children: [
              _td(r[0], cellStyle),
              _td(r[1], cellStyle, center: true),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceTotals(
    double total,
    double paid,
    double balance,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    pw.Widget line(
      String label,
      String value, {
      PdfColor? valueColor,
      bool isEmphasis = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                font: boldFont,
                fontSize: isEmphasis ? 12 : 11,
                color: _textDark,
              ),
            ),
            pw.SizedBox(width: 36),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: isEmphasis ? boldFont : regularFont,
                fontSize: isEmphasis ? 12 : 11,
                color: valueColor ?? _textDark,
              ),
            ),
          ],
        ),
      );
    }

    final balColor = balance > 0.01
        ? PdfColor.fromInt(0xFFB91C1C)
        : PdfColor.fromInt(0xFF15803D);

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _border, width: 0.5),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            line('Total Amount', '₹${total.toStringAsFixed(0)}'),
            line('Paid Amount', '₹${paid.toStringAsFixed(0)}'),
            pw.Container(height: 0.5, width: 200, color: _border),
            pw.SizedBox(height: 6),
            line(
              'Balance',
              '₹${balance.toStringAsFixed(0)}',
              valueColor: balColor,
              isEmphasis: true,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _invoicePatientBar({
    required String patientName,
    required DateTime generatedAt,
    required pw.Font regularItalic,
    required pw.Font boldItalic,
    required pw.Font bold,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: patientName,
                  style: pw.TextStyle(
                    font: boldItalic,
                    fontSize: 11,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.Text(
          DateFormat('dd/MM/yyyy, HH:mm').format(generatedAt),
          style: pw.TextStyle(font: bold, fontSize: 11, color: _textDark),
          textAlign: pw.TextAlign.right,
        ),
      ],
    );
  }

  static pw.Widget _buildPrescriptionHeader(
    String patientName,
    DateTime visitDate,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Rx.',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 24,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              children: [
                pw.Text(
                  'Patient: ',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
                pw.Text(
                  patientName,
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Date: ${DateFormat('dd MMM yyyy').format(visitDate)}',
              style: pw.TextStyle(font: regularFont, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildMedicinesList(
    List<Map<String, dynamic>> medicines,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: medicines.map((m) {
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                m['name'] as String,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 13,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Dosage: ${m['dosage']}   |   Duration: ${m['duration']}',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 11,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Instructions: ${m['instructions']}',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── New prescription PDF blocks (reference-matching) ──────────────────────

  static int? _calcAgeYears(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    final hadBirthday =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthday) age -= 1;
    return age < 0 ? 0 : age;
  }

  static pw.Widget _labelInline(String label, pw.Font bold) {
    return pw.Text(
      label,
      style: pw.TextStyle(font: bold, fontSize: 11, color: _primaryBlue),
    );
  }

  /// Reusable PDF header widget (STRICT 2-column layout).
  /// Matches the provided dental report header design.
  static pw.Widget buildPdfHeader({
    required pw.MemoryImage logo,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    // Hardcoded text (must not change).
    const doctorBlock = [
      'DR. SURYA TEJA. S',
      'DENTAL SURGEON & IMPLANTOLOGIST,',
      'REGN NO : A16733.',
      'BACHELOR OF DENTAL SURGERY,',
      'MASTERSHIP IN ORAL IMPLANTOLOGY.',
    ];
    const clinicBlock = [
      'PRODONTICS DENTAL SPECIALITIES',
      // Must be wrapped in exactly 4 lines (including phone).
      '1st FLOOR, SAANVI SPACE, LANE BESIDE SUBWAY, SLOKA SCHOOL, GANDIPET MAIN ROAD, KOKAPET HYDERABAD, 500075.',
      'PHONE: 9490556555.',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              flex: 6,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Logo + doctor details in one column
                  pw.Container(
                    width: 132,
                    height: 132,
                    // padding: const pw.EdgeInsets.all(6),
                    // decoration: pw.BoxDecoration(
                    //   color: PdfColor.fromInt(0xFFF2F8FD),
                    //   borderRadius: pw.BorderRadius.circular(10),
                    // ),
                    alignment: pw.Alignment.center,
                    child: pw.Image(logo, fit: pw.BoxFit.fill),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Doctor name (same size as clinic title)
                        pw.Text(
                          doctorBlock.first,
                          style: pw.TextStyle(
                            font: bold,
                            fontSize: 13.5,
                            color: _primaryBlue,
                          ),
                        ),
                        // Bottom margin after doctor name (per spec)
                        pw.SizedBox(height: 6),
                        // Qualifications (same font size as clinic address block)
                        ...doctorBlock
                            .skip(1)
                            .map(
                              (t) => pw.Text(
                                t,
                                style: pw.TextStyle(
                                  font: regular,
                                  fontSize: 10,
                                  color: _textDark,
                                  height: 1.05,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(width: 8),

            pw.Expanded(
              flex: 4,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    clinicBlock.first,
                    style: pw.TextStyle(
                      font: bold,
                      fontSize: 13.5, // same as doctor name
                      color: _primaryBlue,
                    ),
                  ),
                  // Bottom margin after clinic title (per spec)
                  pw.SizedBox(height: 6),
                  ...clinicBlock
                      .skip(1)
                      .map(
                        (t) => pw.Text(
                          t,
                          style: pw.TextStyle(
                            font: regular,
                            fontSize: 9.5, // same as doctor qualifications
                            color: _textDark,
                            height: 1.05,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 2, color: _dividerBlue),
      ],
    );
  }

  static pw.Widget _patientInfoBar({
    required Patient patient,
    required DateTime generatedAt,
    required pw.Font regularItalic,
    required pw.Font boldItalic,
    required pw.Font bold,
  }) {
    final gender = (patient.gender ?? '').toString();
    final age = _calcAgeYears(patient.dateOfBirth);
    final phone = patient.phone;
    final name = patient.fullName.isNotEmpty
        ? patient.fullName
        : patient.firstName;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: name,
                  style: pw.TextStyle(
                    font: boldItalic,
                    fontSize: 11,
                    color: _textDark,
                  ),
                ),
                pw.TextSpan(
                  text:
                      ', ${gender.isNotEmpty ? gender : '—'}, ${age != null ? '$age year(s)' : '—'}, $phone',
                  style: pw.TextStyle(
                    font: regularItalic,
                    fontSize: 11,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.Text(
          DateFormat('dd/MM/yyyy, HH:mm').format(generatedAt),
          style: pw.TextStyle(font: bold, fontSize: 11, color: _textDark),
          textAlign: pw.TextAlign.right,
        ),
      ],
    );
  }

  static pw.Widget _rxBody({
    required VisitDetail detail,
    required Patient patient,
    required List<({String name, String? type})> investigations,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    final visit = detail.visit;

    // Dental procedures table rows (from treatment plans).
    final procedures = detail.treatments;
    final procRows = <List<String>>[];
    for (var i = 0; i < procedures.length; i++) {
      final t = procedures[i];
      final name = (t.treatmentName ?? 'Procedure').trim();
      final teeth = (t.teeth ?? '').trim();
      procRows.add(['${i + 1}', name, teeth.isEmpty ? '—' : teeth]);
    }
    if (procRows.isEmpty) {
      procRows.add(['—', '—', '—']);
    }

    // Findings and diagnosis from visit.
    final findings = (visit.chiefComplaint ?? visit.notes ?? '').trim();
    final diagnosis = (visit.diagnosis ?? '').trim();

    // Treatments prescribed: bullet list from treatment plans (name + description).
    final prescribed = detail.treatments
        .map((t) {
          final n = (t.treatmentName ?? '').trim();
          final d = (t.description ?? '').trim();
          if (n.isEmpty && d.isEmpty) return null;
          if (d.isEmpty) return n;
          if (n.isEmpty) return d;
          return '$n  -   $d';
        })
        .whereType<String>()
        .toList();

    // Treatments done: completed sittings list.
    final done = detail.sittings
        .where((s) => s.status.toLowerCase() == 'completed')
        .map((s) => (s.notes ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Prescription table rows.
    final rxRows = detail.prescriptions;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel('DENTAL PROCEDURES :', bold),
        pw.SizedBox(height: 6),
        _proceduresTable(procRows, bold, regular),
        pw.SizedBox(height: 10),

        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _labelInline('EXAMINATION FINDINGS : ', bold),
            pw.Expanded(
              child: pw.Text(
                findings.isNotEmpty ? findings : '—',
                style: pw.TextStyle(font: bold, fontSize: 11, color: _textDark),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _labelInline('DIAGNOSIS : ', bold),
            pw.Expanded(
              child: pw.Text(
                diagnosis.isNotEmpty ? diagnosis : '—',
                style: pw.TextStyle(
                  font: regular,
                  fontSize: 11,
                  color: _textDark,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),

        _sectionLabel('TREATMENTS PRESCRIBED :', bold),
        pw.SizedBox(height: 6),
        _bullets(prescribed, regular, boldFirst: false),
        pw.SizedBox(height: 10),

        _sectionLabel('TREATMENTS DONE :', bold),
        pw.SizedBox(height: 6),
        _bullets(done, bold, boldFirst: true),
        pw.SizedBox(height: 12),

        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'PRESCRIPTION',
            style: pw.TextStyle(
              font: regular,
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              decoration: pw.TextDecoration.underline,
              color: _textDark,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        _rxTable(rxRows, bold, regular),
        pw.SizedBox(height: 10),

        _sectionLabel('INVESTIGATIONS :', bold),
        pw.SizedBox(height: 6),
        _bullets(
          [
            ...investigations.map(
              (i) => i.type == null || i.type!.isEmpty
                  ? i.name
                  : '${i.name}  -   ${i.type}',
            ),
            if ((visit.notes ?? '').trim().isNotEmpty)
              'Notes  -   ${visit.notes!.trim()}',
          ],
          bold,
          boldFirst: true,
          normalFont: regular,
          splitOnDash: true,
        ),
      ],
    );
  }

  static pw.Widget _sectionLabel(String text, pw.Font bold) {
    return pw.Text(
      text,
      style: pw.TextStyle(font: bold, fontSize: 11, color: _primaryBlue),
    );
  }

  static pw.Widget _proceduresTable(
    List<List<String>> rows,
    pw.Font bold,
    pw.Font regular,
  ) {
    final headerStyle = pw.TextStyle(
      font: bold,
      fontSize: 10,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(
      font: regular,
      fontSize: 10,
      color: _textDark,
    );

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(22),
        1: pw.FlexColumnWidth(4),
        2: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primaryBlue),
          children: [
            _th('#', headerStyle),
            _th('Procedure', headerStyle),
            _th('Teeth', headerStyle),
          ],
        ),
        ...rows.map(
          (r) => pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
            children: [
              _td(r[0], cellStyle, center: true),
              _td(r[1], cellStyle),
              _td(r[2], cellStyle),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _rxTable(List prescriptions, pw.Font bold, pw.Font regular) {
    final headerStyle = pw.TextStyle(
      font: bold,
      fontSize: 10,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(
      font: regular,
      fontSize: 10,
      color: _textDark,
    );

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(22),
        1: pw.FlexColumnWidth(4),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.6),
        4: pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _primaryBlue),
          children: [
            _th('', headerStyle),
            _th('Medications', headerStyle, center: true),
            _th('Dose', headerStyle, center: true),
            _th('Frequency', headerStyle, center: true),
            _th('Duration', headerStyle, center: true),
          ],
        ),
        ...List.generate(prescriptions.length, (i) {
          final rx = prescriptions[i];
          final med = (rx.medicineName ?? '').toString().trim();
          final dose = (rx.dosage ?? '').toString().trim();
          final dur = (rx.duration ?? '').toString().trim();
          final instr = (rx.instructions ?? '').toString().trim();

          // Frequency column: keep instruction line breaks if present.
          final freq = instr.replaceAll('  ', ' ').trim();

          return pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.white),
            children: [
              _td('${i + 1}', cellStyle, center: true),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 5,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      med.split('\n').first,
                      style: pw.TextStyle(
                        font: bold,
                        fontSize: 10,
                        color: _textDark,
                      ),
                    ),
                    if (med.contains('\n'))
                      pw.Text(
                        med.split('\n').skip(1).join('\n'),
                        style: cellStyle.copyWith(
                          color: PdfColor.fromInt(0xFF444444),
                        ),
                      ),
                  ],
                ),
              ),
              _td(dose.isEmpty ? '—' : dose, cellStyle, center: true),
              _td(freq.isEmpty ? '—' : freq, cellStyle, center: true),
              _td(dur.isEmpty ? '—' : dur, cellStyle, center: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _th(String text, pw.TextStyle style, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: style,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _td(String text, pw.TextStyle style, {bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: style,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _bullets(
    List<String> items,
    pw.Font boldFont, {
    required bool boldFirst,
    pw.Font? normalFont,
    bool splitOnDash = false,
  }) {
    final normal = normalFont ?? boldFont;
    if (items.isEmpty) {
      return pw.Text(
        '—',
        style: pw.TextStyle(font: normal, fontSize: 11, color: _textDark),
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((t) {
        if (splitOnDash && t.contains(' -   ')) {
          final parts = t.split(' -   ');
          final left = parts.first.trim();
          final right = parts.skip(1).join(' -   ').trim();
          return pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '•  ',
                  style: pw.TextStyle(
                    font: normal,
                    fontSize: 11,
                    color: _textDark,
                  ),
                ),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: left,
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 11,
                            color: _textDark,
                          ),
                        ),
                        pw.TextSpan(
                          text: '  -   $right',
                          style: pw.TextStyle(
                            font: normal,
                            fontSize: 11,
                            color: _textDark,
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

        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '•  ',
                style: pw.TextStyle(
                  font: normal,
                  fontSize: 11,
                  color: _textDark,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  t,
                  style: pw.TextStyle(
                    font: boldFirst ? boldFont : normal,
                    fontSize: 11,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _rxFooterSignature({
    required String doctorName,
    required pw.Font signatureFont,
    required pw.Font bold,
  }) {
    return pw.Align(
      alignment: pw.Alignment.bottomRight,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Surya Teja',
            style: pw.TextStyle(
              font: signatureFont,
              fontSize: 24,
              color: PdfColor.fromInt(0xFF111111),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            doctorName.replaceAll('DR. ', 'Dr. '),
            style: pw.TextStyle(font: bold, fontSize: 11, color: _textDark),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
}
