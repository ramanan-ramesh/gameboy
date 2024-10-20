import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/data/app/models/platform_user.dart';

abstract class MasterPageState {}

class Startup extends MasterPageState {}

class ActiveLanguageChanged extends MasterPageState {
  String language;

  ActiveLanguageChanged({required this.language});
}

class ActiveThemeModeChanged extends MasterPageState {
  ThemeMode themeMode;

  ActiveThemeModeChanged({required this.themeMode});
}

class ActiveUserChanged extends MasterPageState {
  PlatformUserFacade? user;

  ActiveUserChanged({required this.user});
}

class LoadedGame extends MasterPageState {
  Game game;

  LoadedGame({required this.game});
}
