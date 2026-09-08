import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// OtpVerificationResult
// ---------------------------------------------------------------------------
enum OtpVerificationResult {
  success,
  invalid,
  expired,
  tooManyAttempts,
  notFound,
  error,
}

// ---------------------------------------------------------------------------
// OtpService
// ---------------------------------------------------------------------------
//
// Email delivery relies on the Firebase "Trigger Email from Firestore"
// Extension.  Install it once in your Firebase console:
//   Firebase Console → Extensions → "Trigger Email from Firestore"
//   Configure it to watch the `mail` collection.
//
// During development the OTP is ALWAYS printed to the debug console so you
// can test without the extension being configured.
// ---------------------------------------------------------------------------
class OtpService {
  static const _otpCollection = 'otp_verifications';
  static const _mailCollection = 'mail';
  static const _otpExpireMinutes = 5;
  static const _maxAttempts = 3;

  // ─── OTP Generation ───────────────────────────────────────────────────────

  /// Generates a cryptographically secure 6-digit OTP string.
  static String _generateOtp() {
    final random = Random.secure();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Creates a new OTP for [email], stores it in Firestore, sends the email,
  /// and returns the plaintext OTP (useful for debug assertions).
  static Future<String> createAndSendOtp(
    String email, {
    String purpose = 'verification',
  }) async {
    final otp = _generateOtp();
    final normalised = email.trim().toLowerCase();
    final expiresAt =
        DateTime.now().add(const Duration(minutes: _otpExpireMinutes));

    // Store in Firestore — overwrite any existing pending OTP for this email.
    await FirebaseFirestore.instance
        .collection(_otpCollection)
        .doc(normalised)
        .set({
      'otp': otp,
      'email': normalised,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Always log to debug console for development convenience.
    debugPrint('═══════════════════════════════════════════');
    debugPrint('  OTP for $email  →  $otp');
    debugPrint('  Expires at: $expiresAt');
    debugPrint('═══════════════════════════════════════════');

    // Send via Firebase Email Trigger Extension (mail collection write).
    await _sendOtpEmail(normalised, otp, purpose: purpose);

    return otp;
  }

  /// Verifies [enteredOtp] for [email] against the Firestore record.
  /// Deletes the record on success or after too many failed attempts.
  static Future<OtpVerificationResult> verifyOtp(
    String email,
    String enteredOtp,
  ) async {
    final normalised = email.trim().toLowerCase();

    try {
      final ref = FirebaseFirestore.instance
          .collection(_otpCollection)
          .doc(normalised);

      final snap = await ref.get();

      if (!snap.exists) {
        return OtpVerificationResult.notFound;
      }

      final data = snap.data()!;
      final storedOtp = data['otp'] as String?;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = (data['attempts'] as int?) ?? 0;

      // Expiry check.
      if (DateTime.now().isAfter(expiresAt)) {
        await ref.delete();
        return OtpVerificationResult.expired;
      }

      // Attempt-count guard — prevents brute force.
      if (attempts >= _maxAttempts) {
        await ref.delete();
        return OtpVerificationResult.tooManyAttempts;
      }

      if (storedOtp == enteredOtp.trim()) {
        // ✅ Correct — delete the record immediately.
        await ref.delete();
        return OtpVerificationResult.success;
      } else {
        // ❌ Wrong — increment attempts.
        await ref.update({'attempts': attempts + 1});
        return OtpVerificationResult.invalid;
      }
    } catch (e) {
      debugPrint('OtpService.verifyOtp error: $e');
      return OtpVerificationResult.error;
    }
  }

  /// Deletes a pending OTP record (called before re-sending).
  static Future<void> deletePendingOtp(String email) async {
    try {
      await FirebaseFirestore.instance
          .collection(_otpCollection)
          .doc(email.trim().toLowerCase())
          .delete();
    } catch (e) {
      debugPrint('OtpService.deletePendingOtp error: $e');
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Writes to the `mail` collection which triggers the Firebase Email
  /// Extension to send the OTP email.  Errors are caught and logged so that
  /// the flow does not fail when the extension is not yet configured.
  static Future<void> _sendOtpEmail(
    String email,
    String otp, {
    required String purpose,
  }) async {
    final isReset = purpose == 'forgotPassword';
    final subject =
        isReset ? 'Reset your Noorva password' : 'Verify your Noorva account';

    try {
      await FirebaseFirestore.instance.collection(_mailCollection).add({
        'to': email,
        'message': {
          'subject': subject,
          'html': _buildEmailHtml(otp, isReset: isReset),
          'text':
              'Your ${isReset ? 'password reset' : 'verification'} code for Noorva is: $otp\n'
              'This code is valid for $_otpExpireMinutes minutes. Do not share it with anyone.',
        },
      });
      debugPrint('OtpService: mail document written for $email');
    } catch (e) {
      // The Firebase Email Extension is likely not configured.
      // The OTP has already been printed to the debug console above.
      debugPrint(
          'OtpService: could not write to mail collection (extension may not be installed): $e');
    }
  }

  static String _buildEmailHtml(String otp, {required bool isReset}) {
    final purpose = isReset ? 'reset your password' : 'verify your email';
    final heading = isReset ? 'Password Reset' : 'Email Verification';

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>$heading — Noorva</title>
</head>
<body style="margin:0;padding:0;background:#0D0D0F;font-family:'Inter',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#0D0D0F;padding:40px 0;">
    <tr>
      <td align="center">
        <table width="480" cellpadding="0" cellspacing="0"
               style="background:linear-gradient(135deg,#1a1a2e 0%,#16213e 100%);
                      border-radius:16px;border:1px solid rgba(255,255,255,0.08);
                      overflow:hidden;">
          <!-- Header -->
          <tr>
            <td align="center" style="padding:36px 40px 24px;">
              <p style="margin:0;font-size:28px;font-weight:700;color:#FFFFFF;letter-spacing:-0.5px;">
                Noorva
              </p>
              <p style="margin:8px 0 0;font-size:13px;color:rgba(255,255,255,0.5);letter-spacing:2px;text-transform:uppercase;">
                $heading
              </p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:0 40px 40px;">
              <p style="margin:0 0 16px;font-size:15px;color:rgba(255,255,255,0.7);line-height:1.6;">
                Use the code below to $purpose. This code is valid for
                <strong style="color:#FFFFFF;">$_otpExpireMinutes minutes</strong>.
              </p>
              <!-- OTP Box -->
              <div style="background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.1);
                          border-radius:12px;padding:24px;text-align:center;margin:24px 0;">
                <p style="margin:0;font-size:42px;font-weight:700;color:#FFFFFF;
                           letter-spacing:12px;font-family:'Courier New',monospace;">
                  $otp
                </p>
              </div>
              <p style="margin:0;font-size:13px;color:rgba(255,255,255,0.4);line-height:1.6;">
                If you did not request this, please ignore this email. Do not share
                this code with anyone — Noorva will never ask for it.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="padding:20px 40px;border-top:1px solid rgba(255,255,255,0.06);">
              <p style="margin:0;font-size:12px;color:rgba(255,255,255,0.3);text-align:center;">
                © 2024 Noorva · All rights reserved
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>''';
  }
}
