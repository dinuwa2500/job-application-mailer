import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailSendResult {
  final bool success;
  final String message;
  final bool requiresManualAttachment;

  EmailSendResult({
    required this.success,
    required this.message,
    this.requiresManualAttachment = false,
  });
}

class EmailService {
  /// Send email via native mail intent (e.g. Gmail App / Mail App with attachment support)
  static Future<EmailSendResult> sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
    String? attachmentPath,
  }) async {
    // Check if attachment exists and try native flutter_email_sender first
    try {
      final Email email = Email(
        body: body,
        subject: subject,
        recipients: recipientEmail.isNotEmpty ? [recipientEmail] : [],
        attachmentPaths: attachmentPath != null && attachmentPath.isNotEmpty
            ? [attachmentPath]
            : [],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      return EmailSendResult(
        success: true,
        message: 'Email client opened successfully!',
      );
    } catch (error) {
      // Fallback to mailto URI launcher if native intent fails or on desktop/web
      try {
        final Uri mailUri = Uri(
          scheme: 'mailto',
          path: recipientEmail,
          queryParameters: {
            'subject': subject,
            'body': body,
          },
        );

        if (await canLaunchUrl(mailUri)) {
          await launchUrl(mailUri);
          return EmailSendResult(
            success: true,
            message: attachmentPath != null
                ? 'Opened Mail app. Standard mailto does not auto-attach files—please select your PDF manually if needed, or copy content.'
                : 'Mail app opened successfully!',
            requiresManualAttachment: attachmentPath != null,
          );
        } else {
          // If mailto URL cannot be launched, copy content to clipboard
          await copyToClipboard(subject: subject, body: body);
          return EmailSendResult(
            success: false,
            message: 'Could not launch mail client. Subject and body copied to clipboard!',
          );
        }
      } catch (fallbackError) {
        await copyToClipboard(subject: subject, body: body);
        return EmailSendResult(
          success: false,
          message: 'Error launching mail app. Text copied to clipboard instead.',
        );
      }
    }
  }

  /// Launch Gmail directly via URL scheme if installed or fallback to browser Gmail web
  static Future<EmailSendResult> sendViaGmailWeb({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    final Uri gmailUri = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=${Uri.encodeComponent(recipientEmail)}&su=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        return EmailSendResult(
          success: true,
          message: 'Opened Gmail web composer in browser!',
        );
      } else {
        await copyToClipboard(subject: subject, body: body);
        return EmailSendResult(
          success: false,
          message: 'Could not open Gmail. Content copied to clipboard.',
        );
      }
    } catch (e) {
      await copyToClipboard(subject: subject, body: body);
      return EmailSendResult(
        success: false,
        message: 'Content copied to clipboard!',
      );
    }
  }

  /// Copy formatted email text (subject + body) to clipboard
  static Future<void> copyToClipboard({
    required String subject,
    required String body,
  }) async {
    final fullText = 'Subject: $subject\n\n$body';
    await Clipboard.setData(ClipboardData(text: fullText));
  }
}
