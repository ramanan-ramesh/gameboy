import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/data/app/models/repository_pattern.dart';

class PlatformUserImpl extends PlatformUserFacade
    implements RepositoryPattern<PlatformUserFacade> {
  static const String _userData = 'userData';
  static const String _userNameKey = 'userName';
  static const String _userIDKey = 'userID';
  static const String _photoUrlKey = 'photoUrl';
  static const String _displayNameKey = 'displayName';

  PlatformUserImpl(
      {required super.userName,
      required super.userID,
      super.photoUrl,
      super.displayName});

  @override
  String? id;

  @override
  DatabaseReference get documentReference =>
      FirebaseDatabase.instance.ref(_userData).child(userID);

  @override
  PlatformUserFacade get facade => PlatformUserFacade(
      userName: userName,
      userID: userID,
      photoUrl: photoUrl,
      displayName: displayName);

  @override
  Map<String, dynamic> toJson() {
    return {
      _userNameKey: userName,
      _photoUrlKey: photoUrl,
      _displayNameKey: displayName,
    };
  }

  @override
  FutureOr<bool> tryUpdate(toUpdate) {
    throw UnimplementedError();
  }
}
