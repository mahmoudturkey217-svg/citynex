// Stub for web — no-op in UI-only mode
Future<bool> sendEmailViaSMTP({
  required String senderEmail,
  required String senderPassword,
  required String toEmail,
  required String otp,
}) async {
  return true;
}
