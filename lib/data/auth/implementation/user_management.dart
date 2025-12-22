import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:gameboy/data/auth/models/platform_user.dart';
import 'package:gameboy/data/auth/models/status.dart';
import 'package:gameboy/data/auth/models/user_management.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagement implements UserManagementModifier {
  static const _userNameField = 'userName';
  static const _userIDField = 'userID';
  static const String _usersDBCollectionName = 'users';
  static const _appConfigDBField = 'appConfig';
  static const String _googleWebClientIdField = 'webClientId';

  final SharedPreferences _localStorage;

  @override
  PlatformUser? activeUser;

  static UserManagementModifier create(SharedPreferences sharedPreferences) {
    var currentUser = FirebaseAuth.instance.currentUser;
    PlatformUser? platformUser;
    if (currentUser != null) {
      var userID = sharedPreferences.getString(_userIDField);
      if (userID != null) {
        platformUser = PlatformUser(
            userName: currentUser.email!,
            id: userID,
            displayName: currentUser.displayName,
            photoUrl: currentUser.photoURL);
      } else {
        FirebaseAuth.instance.signOut();
      }
    }
    return UserManagement._(
        activeUser: platformUser, localStorage: sharedPreferences);
  }

  @override
  Future<void> initialize() async {
    if (activeUser == null) {
      await _clearCache(_localStorage);
    }
  }

  @override
  Future<AuthStatus> trySignInWithGoogle() async {
    GoogleSignIn googleSignIn;
    if (kIsWeb) {
      var appConfigReference =
          FirebaseDatabase.instance.ref().child(_appConfigDBField);
      var googleWebClientIdField =
          await appConfigReference.child(_googleWebClientIdField).get();
      var googleWebClientId = googleWebClientIdField.value as String;
      googleSignIn = GoogleSignIn(clientId: googleWebClientId);
    } else {
      googleSignIn = GoogleSignIn();
    }
    var googleUser = await googleSignIn.signIn();

    var googleAuth = await googleUser?.authentication;

    var credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    var userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    var existingUserDocument =
        await _retrieveUserDocumentForUserName(userCredential.user!.email!);
    return await _signInWithCredential(userCredential, existingUserDocument);
  }

  @override
  Future<bool> trySignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      activeUser = null;
      await _persistActiveUser();
      return true;
    } on Exception {
      return false;
    }
  }

  Future<DataSnapshot?> _retrieveUserDocumentForUserName(
      String userName) async {
    var userQuery = FirebaseDatabase.instance
        .ref(_usersDBCollectionName)
        .orderByChild(_userNameField)
        .equalTo(userName);
    var userQuerySnapshot = await userQuery.get();
    var userDocuments = userQuerySnapshot.children;
    if (userDocuments.isNotEmpty) {
      return userDocuments.first;
    }
    return null;
  }

  Future<AuthStatus> _signInWithCredential(
      UserCredential userCredential, DataSnapshot? existingUserDocument) async {
    if (userCredential.user != null) {
      var didUpdateUserInDB = await _tryUpdateActiveUser(
          authProviderUser: userCredential.user!,
          existingUserDocument: existingUserDocument);
      return didUpdateUserInDB ? AuthStatus.loggedIn : AuthStatus.undefined;
    }
    return AuthStatus.undefined;
  }

  Future<bool> _tryUpdateActiveUser(
      {required User authProviderUser,
      required DataSnapshot? existingUserDocument}) async {
    try {
      if (existingUserDocument == null) {
        var usersCollectionReference =
            FirebaseDatabase.instance.ref(_usersDBCollectionName);
        var addedUserDocument = usersCollectionReference.push();
        await addedUserDocument.set(_userToJsonDocument(authProviderUser));
        activeUser = PlatformUser(
            userName: authProviderUser.email!,
            id: addedUserDocument.key!,
            photoUrl: authProviderUser.photoURL);
      } else {
        activeUser = PlatformUser(
            userName: authProviderUser.email!,
            id: existingUserDocument.key!,
            photoUrl: authProviderUser.photoURL);
      }
      await _persistActiveUser();
      return true;
    } on Exception {
      return false;
    }
  }

  Future _persistActiveUser() async {
    if (activeUser != null) {
      await _localStorage.setString(_userIDField, activeUser!.id);
      await _localStorage.setString(_userNameField, activeUser!.userName);
    } else {
      await _clearCache(_localStorage);
    }
  }

  static Future<void> _clearCache(SharedPreferences localStorage) async {
    await localStorage.remove(_userIDField);
    await localStorage.remove(_userNameField);
  }

  static Map<String, dynamic> _userToJsonDocument(User authProviderUser) => {
        _userNameField: authProviderUser.email,
      };

  UserManagement._(
      {required this.activeUser, required SharedPreferences localStorage})
      : _localStorage = localStorage;
}
