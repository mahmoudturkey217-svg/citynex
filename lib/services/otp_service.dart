class OtpService {
  // In UI mode, OTP is always "123456" for demo purposes
  static const String _demoOtp = '123456';

  String generateOTP() => _demoOtp;

  Future<void> storeOTP(String email, String otp) async {
    // no-op in UI mode
  }

  Future<bool> verifyOTP(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return otp == _demoOtp;
  }

  Future<bool> sendOTPEmail(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Pretend success — OTP is shown in a hint in forgot_password_screen
    return true;
  }
}
