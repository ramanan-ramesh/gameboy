import 'package:flutter/material.dart';

import 'game.dart';
import 'platform_user.dart';

abstract class AppDataFacade {
  PlatformUser? get activeUser;

  ThemeMode get activeThemeMode;

  Iterable<Game> get games;
}
