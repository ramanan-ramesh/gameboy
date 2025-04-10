import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/implementations/app_data_repository.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/alphaBound/bloc/bloc.dart';
import 'package:gameboy/presentation/alphaBound/pages/game_layout.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/bloc.dart';
import 'package:gameboy/presentation/spelling_bee/pages/game_layout.dart';
import 'package:gameboy/presentation/wordle/bloc/bloc.dart';
import 'package:gameboy/presentation/wordle/pages/game_layout.dart';

import 'master_page_events.dart';
import 'master_page_states.dart';

class _LoadRepository extends MasterPageEvent {}

class MasterPageBloc extends Bloc<MasterPageEvent, MasterPageState> {
  AppDataModifier? _appDataRepository;

  MasterPageBloc() : super(LoadingAppDataRepository()) {
    on<ChangeTheme>(_onThemeChange);
    on<ChangeUser>(_onUserChange);
    on<Logout>(_onLogout);
    on<LoadGame>(_onLoadGame);
    on<_LoadRepository>(_onLoadRepository);
    add(_LoadRepository());
  }

  FutureOr<void> _onLoadRepository(
      _LoadRepository event, Emitter<MasterPageState> emit) async {
    _appDataRepository ??= await AppDataRepository.create();
    emit(LoadedAppDataRepository(appData: _appDataRepository!));
  }

  FutureOr<void> _onThemeChange(
      ChangeTheme event, Emitter<MasterPageState> emit) {
    emit(ActiveThemeModeChanged(themeMode: event.themeModeToChangeTo));
  }

  FutureOr<void> _onUserChange(
      ChangeUser event, Emitter<MasterPageState> emit) async {
    if (event.authProviderUser != null) {
      await _appDataRepository!.updateActiveUser(event.authProviderUser!);
      emit(ActiveUserChanged(user: _appDataRepository!.activeUser));
    }
  }

  FutureOr<void> _onLogout(Logout event, Emitter<MasterPageState> emit) async {
    await _appDataRepository!.updateActiveUser(null);
    emit(ActiveUserChanged(user: null));
  }

  FutureOr<void> _onLoadGame(LoadGame event, Emitter<MasterPageState> emit) {
    var gameData = _getGameData(event.game);
    if (gameData != null) {
      emit(LoadedGame(gameData: gameData));
    }
  }

  GameData? _getGameData(Game game) {
    var userId = _appDataRepository!.activeUser!.id;
    switch (game.name) {
      case AppConstants.wordleGameIdentifier:
        return GameData<WordleGameBloc>(
            gameBloc: WordleGameBloc(userId),
            gameLayout: WordleLayout(),
            game: game);
      case AppConstants.spellingBeeGameIdentifier:
        return GameData<SpellingBeeBloc>(
            gameBloc: SpellingBeeBloc(userId),
            gameLayout: SpellingBeeLayout(),
            game: game);
      case AppConstants.alphaBoundGameIdentifier:
        return GameData<AlphaBoundBloc>(
            gameBloc: AlphaBoundBloc(userId),
            gameLayout: AlphaBoundLayout(),
            game: game);
      default:
        return null;
    }
  }
}
