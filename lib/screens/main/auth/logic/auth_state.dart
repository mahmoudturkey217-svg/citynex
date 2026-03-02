abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthRegisterLoading extends AuthState {}

class AuthRegisterSuccess extends AuthState {
  final String message;

  AuthRegisterSuccess({required this.message});
}

class AuthRegisterError extends AuthState {
  final String error;

  AuthRegisterError({required this.error});
}

class AuthLoginLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final String message;

  AuthLoginSuccess({required this.message});
}

class AuthLoginError extends AuthState {
  final String error;

  AuthLoginError({required this.error});
}

// ─── Forgot Password States ───
class AuthForgotPasswordLoading extends AuthState {}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;

  AuthForgotPasswordSuccess({required this.message});
}

class AuthForgotPasswordError extends AuthState {
  final String error;

  AuthForgotPasswordError({required this.error});
}

// ─── Reset Password States ───
class AuthResetPasswordLoading extends AuthState {}

class AuthResetPasswordSuccess extends AuthState {
  final String message;

  AuthResetPasswordSuccess({required this.message});
}

class AuthResetPasswordError extends AuthState {
  final String error;

  AuthResetPasswordError({required this.error});
}
