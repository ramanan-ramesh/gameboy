import 'package:flutter/material.dart';
import 'package:gameboy/data/app/models/platform_user.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';

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

class LoadedGame<TGameBloc extends GameBloc> extends MasterPageState {
  GameData<TGameBloc> gameData;

  LoadedGame({required this.gameData});
}
