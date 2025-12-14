import 'package:gameboy/data/auth/models/status.dart';

import 'platform_user.dart';

abstract interface class UserManagementFacade {
  PlatformUser? get activeUser;
}

abstract interface class UserManagementModifier extends UserManagementFacade {
  Future<void> initialize();

  Future<AuthStatus> trySignInWithGoogle();

  Future<bool> trySignOut();
}
