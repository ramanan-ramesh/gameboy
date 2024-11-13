import 'package:flutter/material.dart';

import 'game.dart';
import 'platform_user.dart';

abstract class AppDataFacade {
  PlatformUserFacade? get activeUser;

  ThemeMode get activeThemeMode;

  bool get isBigLayout;

  Iterable<Game> get games;
}
