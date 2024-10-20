import 'package:flutter/material.dart';

import 'game.dart';
import 'language_metadata.dart';
import 'platform_user.dart';

abstract class AppDataFacade {
  PlatformUserFacade? get activeUser;

  String get activeLanguage;

  ThemeMode get activeThemeMode;

  Iterable<LanguageMetadata> get languageMetadatas;

  bool get isBigLayout;

  Iterable<Game> get games;
}
