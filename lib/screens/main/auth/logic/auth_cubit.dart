import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../../../core/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthRegisterLoading());
    try {
      final response = await authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success == true && response.data?.token != null) {
        emit(AuthRegisterSuccess(message: 'Registration successful!'));
      } else {
        emit(
          AuthRegisterError(
            error: response.message ?? 'Unknown error occurred',
          ),
        );
      }
    } catch (e) {
      emit(AuthRegisterError(error: e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoginLoading());
    try {
      final response = await authRepository.login(
        email: email,
        password: password,
      );

      if (response.success == true && response.data?.token != null) {
        emit(AuthLoginSuccess(message: 'Login successful!'));
      } else {
        emit(
          AuthLoginError(error: response.message ?? 'Unknown error occurred'),
        );
      }
    } catch (e) {
      emit(AuthLoginError(error: e.toString()));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(AuthForgotPasswordLoading());
    try {
      final response = await authRepository.forgotPassword(email: email);

      if (response.success == true) {
        emit(AuthForgotPasswordSuccess(
            message: response.message ?? 'Password reset link sent!'));
      } else {
        emit(AuthForgotPasswordError(
            error: response.message ?? 'Failed to send reset link'));
      }
    } catch (e) {
      emit(AuthForgotPasswordError(error: e.toString()));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthResetPasswordLoading());
    try {
      final response = await authRepository.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.success == true) {
        emit(AuthResetPasswordSuccess(
            message: response.message ?? 'Password reset successful!'));
      } else {
        emit(AuthResetPasswordError(
            error: response.message ?? 'Failed to reset password'));
      }
    } catch (e) {
      emit(AuthResetPasswordError(error: e.toString()));
    }
  }
}
