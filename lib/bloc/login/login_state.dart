part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Map<String, dynamic> user;
  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SignupOtpRequired extends LoginState {
  final String email;
  const SignupOtpRequired(this.email);

  @override
  List<Object?> get props => [email];
}

class OtpResent extends LoginState {
  final String email;
  const OtpResent(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOtpRequested extends LoginState {
  final String email;
  const ForgotPasswordOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordResetSuccess extends LoginState {}
