import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/constants.dart';
import 'package:gameboy/data/app/implementations/app_data_repository.dart';
import 'package:gameboy/data/app/models/app_data_modifier.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/alphaBound/bloc/bloc.dart';
import 'package:gameboy/presentation/alphaBound/pages/game_layout.dart';
import 'package:gameboy/presentation/app/blocs/game_data.dart';
import 'package:gameboy/presentation/beeWise/bloc/bloc.dart';
import 'package:gameboy/presentation/beeWise/pages/game_layout.dart';
import 'package:gameboy/presentation/wordsy/bloc/bloc.dart';
import 'package:gameboy/presentation/wordsy/pages/game_layout.dart';

import 'master_page_events.dart';
import 'master_page_states.dart';

class _LoadRepository extends MasterPageEvent {}

class MasterPageBloc extends Bloc<MasterPageEvent, MasterPageState> {
  AppDataModifier? _appDataRepository;

  MasterPageBloc() : super(LoadingAppDataRepository()) {
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
      case AppConstants.wordsyGameIdentifier:
        return GameData<WordsyGameBloc>(
            gameBloc: WordsyGameBloc(userId),
            gameLayout: WordsyLayout(),
            game: game);
      case AppConstants.beeWiseGameIdentifier:
        return GameData<BeeWiseBloc>(
            gameBloc: BeeWiseBloc(userId),
            gameLayout: BeeWiseLayout(),
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
