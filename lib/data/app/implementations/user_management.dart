import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/data/app/models/user_management.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserManagementImpl extends UserManagementFacade {
  static const _userDataField = 'userData';
  static const _userNameField = 'userName';
  static const _userIDField = 'userID';
  static const _displayNameField = 'displayName';
  static const _isLoggedInField = 'isLoggedIn';
  static const _photoUrlField = 'photoUrl';

  @override
  PlatformUser? get activeUser => _activeUser;
  PlatformUser? _activeUser;

  static Future<UserManagementFacade> create() async {
    var userFromCache = await _getUserFromCache();
    return UserManagementImpl(initialUser: userFromCache);
  }

  UserManagementImpl({PlatformUser? initialUser}) : _activeUser = initialUser;

  @override
  Future<bool> tryUpdateActiveUser({required User authProviderUser}) async {
    try {
      var usersCollectionReference =
          FirebaseDatabase.instance.ref(_userDataField);
      var userQuery = usersCollectionReference
          .orderByChild(_userNameField)
          .equalTo(authProviderUser.email);
      var queryResult = await userQuery.get();
      if (queryResult.exists &&
          queryResult.value != null &&
          queryResult.children.isNotEmpty) {
        var userDocument = queryResult.children.first;
        var userDocumentData = userDocument.value as Map;
        _activeUser = PlatformUser(
            userName: userDocumentData[_userNameField],
            id: userDocument.key!,
            photoUrl: userDocumentData[_photoUrlField],
            displayName: userDocumentData[_displayNameField]);
      } else {
        var addedUserDocument = usersCollectionReference.push();
        await addedUserDocument.set({
          _userNameField: authProviderUser.email!,
          if (authProviderUser.photoURL != null)
            _photoUrlField: authProviderUser.photoURL,
          if (authProviderUser.displayName != null)
            _displayNameField: authProviderUser.displayName,
        });
        _activeUser = PlatformUser(
            userName: authProviderUser.email!,
            id: addedUserDocument.key!,
            photoUrl: authProviderUser.photoURL,
            displayName: authProviderUser.displayName);
      }
      await _persistUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> trySignOut() async {
    try {
      _activeUser = null;
      await _persistUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  //TODO: Should ideally attach AuthProviderUser here(if it persists)?
  static Future<PlatformUser?> _getUserFromCache() async {
    var usersBox = await Hive.openBox(_userDataField);
    var isLoggedInValue = usersBox.get(_isLoggedInField) ?? '';
    if (bool.tryParse(isLoggedInValue) == true) {
      var userID = await usersBox.get(_userIDField) as String;
      var userName = await usersBox.get(_userNameField) as String;
      var photoUrl = await usersBox.get(_photoUrlField) as String?;
      var displayName = await usersBox.get(_displayNameField) as String?;
      return PlatformUser(
          userName: userName,
          id: userID,
          photoUrl: photoUrl,
          displayName: displayName);
    }
    await usersBox.close();

    return null;
  }

  Future _persistUser() async {
    var usersBox = await Hive.openBox(_userDataField);
    if (activeUser != null) {
      await usersBox.put(_userIDField, activeUser!.id);
      await usersBox.put(_userNameField, activeUser!.userName);
      var displayName = activeUser!.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        await usersBox.put(_displayNameField, displayName);
      }
      await usersBox.put(_isLoggedInField, true.toString());
      if (_activeUser!.photoUrl != null) {
        await usersBox.put(_photoUrlField, activeUser!.photoUrl);
      }
    } else {
      await usersBox.clear();
      await usersBox.put(_isLoggedInField, false.toString());
    }
    await usersBox.close();
  }
}
