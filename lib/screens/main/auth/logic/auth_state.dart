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
