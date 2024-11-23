import 'package:firebase_auth/firebase_auth.dart';
import 'package:gameboy/data/app/implementations/user_management.dart';

import 'platform_user.dart';

abstract class UserManagementFacade {
  PlatformUserFacade? get activeUser;
  Future<bool> tryUpdateActiveUser({required User authProviderUser});
  Future<bool> trySignOut();

  static Future<UserManagementFacade> create() async {
    return await UserManagementImpl.create();
  }
}
