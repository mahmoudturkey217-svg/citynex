// No-op email sender for UI-only mode
Future<bool> sendEmailViaSMTP({
  required String senderEmail,
  required String senderPassword,
  required String toEmail,
  required String otp,
}) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return true;
}
