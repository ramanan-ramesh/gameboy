import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/data/app/models/user_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementImpl extends UserManagementFacade {
  static const _userDataField = 'userData';
  static const _userNameField = 'userName';
  static const _userIDField = 'userID';
  static const _displayNameField = 'displayName';
  static const _isLoggedInField = 'isLoggedIn';
  static const _photoUrlField = 'photoUrl';

  final SharedPreferences _sharedPreferences;

  @override
  PlatformUser? get activeUser => _activeUser;
  PlatformUser? _activeUser;

  static Future<UserManagementFacade> create(
      SharedPreferences sharedPreferences) async {
    var userFromCache = await _getUserFromCache(sharedPreferences);
    return UserManagementImpl(
        initialUser: userFromCache, sharedPreferences: sharedPreferences);
  }

  UserManagementImpl(
      {PlatformUser? initialUser, required SharedPreferences sharedPreferences})
      : _activeUser = initialUser,
        _sharedPreferences = sharedPreferences;

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
  static Future<PlatformUser?> _getUserFromCache(
      SharedPreferences sharedPreferences) async {
    var isLoggedInValue = sharedPreferences.getBool(_isLoggedInField) ?? false;
    if (isLoggedInValue) {
      var userID = sharedPreferences.getString(_userIDField)!;
      var userName = sharedPreferences.getString(_userNameField)!;
      var photoUrl = sharedPreferences.getString(_photoUrlField);
      var displayName = sharedPreferences.getString(_displayNameField);
      return PlatformUser(
          userName: userName,
          id: userID,
          photoUrl: photoUrl,
          displayName: displayName);
    }

    return null;
  }

  Future _persistUser() async {
    if (activeUser != null) {
      await _sharedPreferences.setString(_userIDField, activeUser!.id);
      await _sharedPreferences.setString(_userNameField, activeUser!.userName);
      var displayName = activeUser!.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        await _sharedPreferences.setString(_displayNameField, displayName);
      }
      await _sharedPreferences.setBool(_isLoggedInField, true);
      if (_activeUser!.photoUrl != null) {
        await _sharedPreferences.setString(
            _photoUrlField, _activeUser!.photoUrl!);
      }
    } else {
      await _sharedPreferences.setBool(_isLoggedInField, false);
    }
  }
}
