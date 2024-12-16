import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_state.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/presentation/alphaBound/bloc/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_event.dart';

extension BuildContextExt on BuildContext {
  GameEngineData getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as GameEngineData;
  }

  GameState getCurrentAplhaBoundGameState() {
    return getGameEngineData().currentState;
  }

  AlphaBoundStats getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as AlphaBoundStats;
  }

  void addGameEvent<TEvent extends GameEvent>(TEvent event) {
    _getGameBloc().add(event);
  }

  AlphaBoundBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as AlphaBoundBloc;
  }
}
