import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationState {}

class AuthInitialState extends AuthenticationState {}

class Authenticating extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final User authProviderUser;

  AuthenticationSuccess({required this.authProviderUser});
}

class AuthenticationFailure extends AuthenticationState {
  final AuthenticationFailures failureReason;

  AuthenticationFailure({required this.failureReason});
}

enum AuthenticationFailures {
  usernameAlreadyExists,
  wrongPassword,
  noSuchUsernameExists,
  invalidEmail,
  undefined,
  weakPassword
}
