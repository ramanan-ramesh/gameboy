import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';

import 'game_event.dart';
import 'game_state.dart';

class _LoadGame extends GameEvent {
  final String userId;

  _LoadGame(this.userId);
}

abstract class GameBloc<
    TEvent extends GameEvent,
    TState extends GameState,
    TStats extends Statistics,
    TGameEngine extends GameEngine> extends Bloc<GameEvent, GameState> {
  final String userId;
  late TGameEngine gameEngine;
  late TStats stats;

  Future<TStats> statisticsCreator();

  Future<TGameEngine> gameEngineCreator(TStats stats);

  FutureOr<TState?> getGameStateOnStartup();

  GameBloc({required this.userId}) : super(GameLoading()) {
    on<_LoadGame>(_onLoadGame);
    on<RequestStats>(_onRequestStats);
    add(_LoadGame(userId));
  }

  FutureOr<void> _onRequestStats(RequestStats event, Emitter<GameState> emit) {
    emit(ShowStats());
  }

  FutureOr<void> _onLoadGame(_LoadGame event, Emitter<GameState> emit) async {
    stats = await statisticsCreator();
    await stats.reCalculate();
    gameEngine = await gameEngineCreator(stats);
    emit(GameLoaded<TGameEngine, TStats>(gameEngine, stats));
    var gameResultOnStartup = await getGameStateOnStartup();
    if (gameResultOnStartup != null) {
      emit(gameResultOnStartup);
    }
  }
}
