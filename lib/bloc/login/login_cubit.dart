import 'package:bloc/bloc.dart';
import 'package:avg_mart/service/api_exception_service.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:avg_mart/service/storege_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final ApiService _apiService;
  final StorageService _storageService;
  final GoogleSignIn _googleSignIn;

  /// Web OAuth client ID (public, safe in the app). Needed to receive an idToken.
  static const String _googleWebClientId =
      '1048161544436-e706jj3kh1sppr2q7r7f5ac76egnnd75.apps.googleusercontent.com';

  LoginCubit({
    ApiService? apiService,
    StorageService? storageService,
    GoogleSignIn? googleSignIn,
  }) : _apiService = apiService ?? ApiService(),
       _storageService = storageService ?? StorageService(),
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: const ['email', 'profile'],
             serverClientId: _googleWebClientId,
           ),
       super(LoginInitial());

  // ---------------------------------------------------------------------------
  // Shared helper: save token + emit success/failure
  // ---------------------------------------------------------------------------
  Future<void> _handleAuthResponse(
    Map<String, dynamic> response, {
    required String invalidTokenMessage,
  }) async {
    final token = response['token'] as String?;
    final user = (response['user'] as Map<String, dynamic>?) ?? response;

    if (token != null && token.isNotEmpty) {
      await _storageService.saveToken('auth_token', token);
      await _apiService.addToken();
      emit(LoginSuccess(user));
    } else {
      emit(LoginFailure(invalidTokenMessage));
    }
  }

  // ---------------------------------------------------------------------------
  // Email / password login
  // ---------------------------------------------------------------------------
  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(const LoginFailure('Please enter email and password'));
      return;
    }

    emit(LoginLoading());

    try {
      final response = await _apiService.login(
        email: email.trim(),
        password: password,
      );
      await _handleAuthResponse(
        response,
        invalidTokenMessage: 'Login failed: invalid token received from server',
      );
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('Something went wrong. Please try again.'));
    }
  }

  // ---------------------------------------------------------------------------
  // Signup
  // ---------------------------------------------------------------------------
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      emit(const LoginFailure('Please fill in all fields'));
      return;
    }

    emit(LoginLoading());

    try {
      final response = await _apiService.signup(
        name: name.trim(),
        email: email.trim(),
        password: password,
        role: role,
      );

      final token = response['token'] as String?;
      final user = (response['user'] as Map<String, dynamic>?) ?? response;

      if (token != null && token.isNotEmpty) {
        await _storageService.saveToken('auth_token', token);
        await _apiService.addToken();
        emit(LoginSuccess(user));
      } else {
        // Backend requires email OTP verification first.
        emit(SignupOtpRequired(email.trim()));
      }
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('Something went wrong. Please try again.'));
    }
  }

  // ---------------------------------------------------------------------------
  // Signup OTP
  // ---------------------------------------------------------------------------
  Future<void> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    if (otp.trim().isEmpty) {
      emit(const LoginFailure('Please enter the OTP'));
      return;
    }
    if (otp.trim().length < 4) {
      emit(const LoginFailure('Please enter the complete OTP'));
      return;
    }

    emit(LoginLoading());

    try {
      final response = await _apiService.verifySignupOtp(
        email: email.trim(),
        otp: otp.trim(),
      );
      await _handleAuthResponse(
        response,
        invalidTokenMessage: 'OTP verification failed: invalid token received',
      );
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('OTP verification failed. Please try again.'));
    }
  }

  Future<void> resendSignupOtp({required String email}) async {
    emit(LoginLoading());

    try {
      await _apiService.resendSignupOtp(email: email.trim());
      emit(OtpResent(email.trim()));
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('Could not resend OTP. Please try again.'));
    }
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In (ID token -> backend POST /auth/google)
  // ---------------------------------------------------------------------------
  Future<void> loginWithGoogle() async {
    emit(LoginLoading());

    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(LoginInitial()); // user cancelled the picker
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        emit(const LoginFailure('Could not get Google ID token'));
        return;
      }

      final response = await _apiService.googleAuth(accessToken: idToken);
      await _handleAuthResponse(
        response,
        invalidTokenMessage: 'Google login failed: invalid token received',
      );
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(
        'GOOGLE SIGN-IN PlatformException: code=${e.code}, '
        'message=${e.message}, details=${e.details}',
      );
      emit(LoginFailure(_mapGoogleError(e.code)));
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      // ignore: avoid_print
      print('GOOGLE SIGN-IN unexpected error: $e');
      emit(const LoginFailure('Google sign-in failed. Please try again.'));
    }
  }

  String _mapGoogleError(String code) {
    switch (code) {
      case 'sign_in_failed':
        return 'Google sign-in setup issue (SHA-1/package mismatch). Contact support.';
      case 'network_error':
        return 'No internet connection. Please check your network.';
      case 'sign_in_canceled':
        return 'Sign-in cancelled.';
      default:
        return 'Google sign-in failed ($code). Please try again.';
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot password
  // ---------------------------------------------------------------------------
  Future<void> requestForgotPasswordOtp({required String email}) async {
    if (email.trim().isEmpty) {
      emit(const LoginFailure('Please enter your email'));
      return;
    }
    if (!RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    ).hasMatch(email.trim())) {
      emit(const LoginFailure('Please enter a valid email'));
      return;
    }

    emit(LoginLoading());

    try {
      await _apiService.forgotPasswordRequestOtp(email: email.trim());
      emit(ForgotPasswordOtpRequested(email.trim()));
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> resendForgotPasswordOtp({required String email}) async {
    emit(LoginLoading());

    try {
      await _apiService.forgotPasswordRequestOtp(email: email.trim());
      emit(ForgotPasswordOtpRequested(email.trim()));
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('Could not resend OTP. Please try again.'));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (otp.trim().isEmpty) {
      emit(const LoginFailure('Please enter the OTP'));
      return;
    }
    if (otp.trim().length < 4) {
      emit(const LoginFailure('Please enter the complete OTP'));
      return;
    }
    if (newPassword.isEmpty || newPassword.length < 6) {
      emit(const LoginFailure('Password must be at least 6 characters'));
      return;
    }

    emit(LoginLoading());

    try {
      await _apiService.forgotPasswordResetPassword(
        email: email.trim(),
        otp: otp.trim(),
        newPassword: newPassword,
      );
      emit(PasswordResetSuccess());
    } on ApiExceptionService catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(const LoginFailure('Reset failed. Please try again.'));
    }
  }
}
