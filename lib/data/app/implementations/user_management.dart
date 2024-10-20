import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gameboy/data/app/implementations/platform_user.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/data/app/models/user_management.dart';
import 'package:hive/hive.dart';

class UserManagementImpl extends UserManagementFacade {
  static const String _userData = 'userData';

  static const _userName = 'userName';
  static const _userID = 'userID';
  static const _displayName = 'displayName';
  static const _isLoggedIn = 'isLoggedIn';
  static const _photoUrl = 'photoUrl';

  PlatformUserFacade? _activeUser;

  @override
  PlatformUserFacade? get activeUser {
    return _activeUser;
  }

  static Future<UserManagementImpl> create() async {
    var userFromCache = await _getUserFromCache();
    return UserManagementImpl(initialUser: userFromCache);
  }

  UserManagementImpl({PlatformUserFacade? initialUser})
      : _activeUser = initialUser;

  @override
  Future<bool> tryUpdateActiveUser({required User authProviderUser}) async {
    try {
      var usersCollectionReference = FirebaseDatabase.instance.ref(_userData);
      var userQuery = usersCollectionReference
          .orderByChild(_userName)
          .equalTo(authProviderUser.email);
      var queryResult = await userQuery.get();
      if (queryResult.exists &&
          queryResult.value != null &&
          queryResult.children.isNotEmpty) {
        var userDocument = queryResult.children.first;
        var userDocumentData = userDocument.value as Map;
        _activeUser = PlatformUserImpl(
            userName: userDocumentData[_userName],
            userID: userDocument.key!,
            photoUrl: userDocumentData[_photoUrl],
            displayName: userDocumentData[_displayName]);
      } else {
        var platformUser = PlatformUserImpl(
            userName: authProviderUser.email!,
            userID: '',
            photoUrl: authProviderUser.photoURL,
            displayName: authProviderUser.displayName);
        var addedUserDocument = usersCollectionReference.push();
        await addedUserDocument.set(platformUser.toJson());
        _activeUser = PlatformUserImpl(
            userName: authProviderUser.email!,
            userID: addedUserDocument.key!,
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
  static Future<PlatformUserFacade?> _getUserFromCache() async {
    var usersBox = await Hive.openBox(_userData);
    var isLoggedInValue = usersBox.get(_isLoggedIn) ?? '';
    if (bool.tryParse(isLoggedInValue) == true) {
      var userID = await usersBox.get(_userID) as String;
      var userName = await usersBox.get(_userName) as String;
      var photoUrl = await usersBox.get(_photoUrl) as String?;
      var displayName = await usersBox.get(_displayName) as String?;
      return PlatformUserFacade(
          userName: userName,
          userID: userID,
          photoUrl: photoUrl,
          displayName: displayName);
    }
    await usersBox.close();

    return null;
  }

  Future _persistUser() async {
    var usersBox = await Hive.openBox(_userData);
    if (activeUser != null) {
      await _writeRecordToLocalStorage(usersBox, _userID, activeUser!.userID);
      await _writeRecordToLocalStorage(
          usersBox, _userName, activeUser!.userName);
      var displayName = activeUser!.displayName;
      if (displayName != null && displayName.isNotEmpty) {
        await _writeRecordToLocalStorage(usersBox, _displayName, displayName);
      }
      await _writeRecordToLocalStorage(usersBox, _isLoggedIn, true.toString());
      if (_activeUser!.photoUrl != null) {
        await _writeRecordToLocalStorage(
            usersBox, _photoUrl, _activeUser!.photoUrl!);
      }
    } else {
      await usersBox.clear();
      await _writeRecordToLocalStorage(usersBox, _isLoggedIn, false.toString());
    }
    await usersBox.close();
  }

  Future _writeRecordToLocalStorage(
      Box hiveBox, String recordKey, String recordValue) async {
    await hiveBox.put(recordKey, recordValue);
  }
}
