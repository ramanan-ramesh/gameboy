import 'package:flutter/material.dart';
import 'package:gameboy/data/auth/models/user_management.dart';

import '../../auth/models/platform_user.dart';
import 'game.dart';

abstract class AppDataFacade {
  PlatformUser? get activeUser;

  Iterable<Game> get games;

  UserManagementFacade get userManagement;

  ThemeMode get activeThemeMode;
}

abstract class AppDataModifier extends AppDataFacade {
  UserManagementModifier get userManagement;

  Future toggleThemeMode();
}
