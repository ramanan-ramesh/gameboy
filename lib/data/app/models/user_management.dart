import 'package:firebase_auth/firebase_auth.dart';

import 'platform_user.dart';

abstract class UserManagementFacade {
  PlatformUser? get activeUser;

  Future<bool> tryUpdateActiveUser({required User authProviderUser});

  Future<bool> trySignOut();
}
