import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_events.dart';
import 'auth_states.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  static final Map<String, AuthenticationFailures>
      _authenticationFailuresAndMessages = {
    'invalid-email': AuthenticationFailures.invalidEmail,
    'wrong-password': AuthenticationFailures.wrongPassword,
    'user-not-found': AuthenticationFailures.noSuchUsernameExists,
    'email-already-in-use': AuthenticationFailures.usernameAlreadyExists
  };

  final String googleWebClientId;

  AuthenticationBloc(this.googleWebClientId) : super(AuthInitialState()) {
    on<AuthenticateWithUsernamePassword>(_onAuthWithUsernamePassword);
    on<AuthenticateWithGoogle>(_onAuthWithGoogle);
  }

  static AuthenticationFailures _getAuthFailureReason(
      String errorCode, String? errorMessage) {
    AuthenticationFailures authFailureReason = AuthenticationFailures.undefined;
    if (errorMessage == null) {
      var matches = _authenticationFailuresAndMessages.keys
          .where((element) => errorCode.contains(element));
      if (matches.isNotEmpty) {
        return _authenticationFailuresAndMessages[matches.first]!;
      }
    } else {
      var matches = _authenticationFailuresAndMessages.keys.where((element) =>
          errorCode.contains(element) || errorMessage.contains(element));
      if (matches.isNotEmpty) {
        return _authenticationFailuresAndMessages[matches.first]!;
      }
    }
    return authFailureReason;
  }

  Future<FutureOr<void>> _onAuthWithUsernamePassword(
      AuthenticateWithUsernamePassword event,
      Emitter<AuthenticationState> emit) async {
    emit(Authenticating());
    try {
      UserCredential userCredential;
      if (event.isLogin) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: event.userName, password: event.passWord);
      } else {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: event.userName, password: event.passWord);
      }
      emit(AuthenticationSuccess(authProviderUser: userCredential.user!));
    } on FirebaseAuthException catch (exception) {
      emit(AuthenticationFailure(
          failureReason:
              _getAuthFailureReason(exception.code, exception.message)));
    }
  }

  FutureOr<void> _onAuthWithGoogle(
      AuthenticateWithGoogle event, Emitter<AuthenticationState> emit) async {
    var googleSignIn = GoogleSignIn(clientId: googleWebClientId);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    var userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCredential.user != null) {
      emit(AuthenticationSuccess(authProviderUser: userCredential.user!));
    }
  }
}
