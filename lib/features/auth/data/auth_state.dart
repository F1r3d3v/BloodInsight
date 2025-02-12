import 'package:equatable/equatable.dart';

sealed class AuthState with EquatableMixin {}

class SignedInState extends AuthState {
  SignedInState({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

enum SignInMethod { email, google }

class SigningInState extends AuthState {
  SigningInState({required this.method});

  final SignInMethod method;

  @override
  List<Object?> get props => [method];
}

class SignedOutState extends AuthState {
  SignedOutState({this.error});

  final String? error;

  @override
  List<Object?> get props => [error];
}

class SignedUpState extends AuthState {
  SignedUpState({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class SigningUpState extends AuthState {
  @override
  List<Object?> get props => [];
}
