import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'whatsapp_templates.dart';

/// Configuration for Meta Cloud API (WhatsApp Business).
///
/// Replace placeholder values with your real credentials.
class WhatsAppConfig {
  const WhatsAppConfig({
    required this.phoneNumberId,
    required this.accessToken,
    required this.businessAccountId,
    this.apiVersion = 'v21.0',
  });

  final String phoneNumberId;
  final String accessToken;
  final String businessAccountId;
  final String apiVersion;

  String get messagesUrl =>
      'https://graph.facebook.com/$apiVersion/$phoneNumberId/messages';

  /// ──────────────────────────────────────────────────────────────────────
  /// TODO: Replace with your real credentials before going to production.
  /// You can load these from environment / secure storage instead.
  /// ──────────────────────────────────────────────────────────────────────
  static const placeholder = WhatsAppConfig(
    phoneNumberId: 'YOUR_PHONE_NUMBER_ID',
    accessToken: 'YOUR_PERMANENT_ACCESS_TOKEN',
    businessAccountId: 'YOUR_BUSINESS_ACCOUNT_ID',
  );
}

/// Service for sending WhatsApp messages via Meta Cloud API.
class WhatsAppService {
  WhatsAppService({WhatsAppConfig? config})
      : _config = config ?? WhatsAppConfig.placeholder;

  final WhatsAppConfig _config;

  bool get _isConfigured =>
      _config.phoneNumberId != 'YOUR_PHONE_NUMBER_ID' &&
      _config.accessToken != 'YOUR_PERMANENT_ACCESS_TOKEN';

  // ── Core send ──────────────────────────────────────────────────────────

  /// Sends a template message to [phoneNumber] (E.164 format, e.g. +919876543210).
  Future<bool> sendTemplateMessage({
    required String phoneNumber,
    required String templateName,
    required List<Map<String, dynamic>> components,
    String languageCode = 'en',
  }) async {
    if (!_isConfigured) {
      debugPrint(
        '[WhatsApp] ⚠️ Not configured — would send "$templateName" to $phoneNumber',
      );
      return false;
    }

    final body = jsonEncode({
      'messaging_product': 'whatsapp',
      'to': phoneNumber.replaceAll('+', ''),
      'type': 'template',
      'template': {
        'name': templateName,
        'language': {'code': languageCode},
        'components': components,
      },
    });

    try {
      final response = await http.post(
        Uri.parse(_config.messagesUrl),
        headers: {
          'Authorization': 'Bearer ${_config.accessToken}',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[WhatsApp] ✅ Sent "$templateName" to $phoneNumber');
        return true;
      } else {
        debugPrint(
          '[WhatsApp] ❌ Failed ($templateName → $phoneNumber): '
          '${response.statusCode} ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[WhatsApp] ❌ Error sending "$templateName": $e');
      return false;
    }
  }

  // ── Convenience methods ────────────────────────────────────────────────

  Future<bool> sendAppointmentConfirmation({
    required String phone,
    required String patientName,
    required String date,
    required String time,
    required String doctorName,
    String clinicName = 'Prodontics',
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.appointmentConfirmation,
      components: WhatsAppTemplates.confirmationParams(
        patientName: patientName,
        date: date,
        time: time,
        doctorName: doctorName,
        clinicName: clinicName,
      ),
    );
  }

  Future<bool> sendAppointmentReminder({
    required String phone,
    required String patientName,
    required String date,
    required String time,
    required String doctorName,
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.appointmentReminder,
      components: WhatsAppTemplates.reminderParams(
        patientName: patientName,
        date: date,
        time: time,
        doctorName: doctorName,
      ),
    );
  }

  Future<bool> sendRescheduleNotification({
    required String phone,
    required String patientName,
    required String oldDate,
    required String newDate,
    required String newTime,
    required String doctorMessage,
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.appointmentRescheduled,
      components: WhatsAppTemplates.rescheduleParams(
        patientName: patientName,
        oldDate: oldDate,
        newDate: newDate,
        newTime: newTime,
        doctorMessage: doctorMessage,
      ),
    );
  }

  Future<bool> sendCancellationNotification({
    required String phone,
    required String patientName,
    required String date,
    required String doctorMessage,
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.appointmentCancelled,
      components: WhatsAppTemplates.cancelParams(
        patientName: patientName,
        date: date,
        doctorMessage: doctorMessage,
      ),
    );
  }

  Future<bool> sendWelcomeMessage({
    required String phone,
    required String patientName,
    String clinicName = 'Prodontics',
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.welcomeMessage,
      components: WhatsAppTemplates.welcomeParams(
        patientName: patientName,
        clinicName: clinicName,
      ),
    );
  }

  Future<bool> sendTreatmentUpdate({
    required String phone,
    required String patientName,
    required String treatmentName,
    required String status,
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.treatmentUpdate,
      components: WhatsAppTemplates.treatmentUpdateParams(
        patientName: patientName,
        treatmentName: treatmentName,
        status: status,
      ),
    );
  }

  Future<bool> sendBillSummary({
    required String phone,
    required String patientName,
    required double total,
    required double paid,
    required double balance,
  }) {
    return sendTemplateMessage(
      phoneNumber: phone,
      templateName: WhatsAppTemplates.billSummary,
      components: WhatsAppTemplates.billSummaryParams(
        patientName: patientName,
        total: total.toStringAsFixed(2),
        paid: paid.toStringAsFixed(2),
        balance: balance.toStringAsFixed(2),
      ),
    );
  }

  Future<bool> sendDailyDoctorReport({
    required String doctorPhone,
    required String doctorName,
    required String date,
    required int totalAppointments,
    required List<String> appointmentSummaries,
  }) {
    return sendTemplateMessage(
      phoneNumber: doctorPhone,
      templateName: WhatsAppTemplates.dailyDoctorReport,
      components: WhatsAppTemplates.dailyDoctorReportParams(
        doctorName: doctorName,
        date: date,
        totalCount: '$totalAppointments',
        appointmentList: appointmentSummaries.join('\n'),
      ),
    );
  }
}
