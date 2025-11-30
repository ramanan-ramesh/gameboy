import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/bloc/alphaBound/bloc.dart';
import 'package:gameboy/bloc/game/bloc.dart';
import 'package:gameboy/bloc/game/events.dart';
import 'package:gameboy/data/alphaBound/models/game_engine.dart';
import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/alphaBound/models/stats.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';

extension BuildContextExt on BuildContext {
  AlphaBoundGameEngine getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as AlphaBoundGameEngine;
  }

  AlphaBoundGameStatus getCurrentAlphaBoundGameStatus() {
    return getGameEngineData().currentState;
  }

  AlphaBoundStatistics getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as AlphaBoundStatistics;
  }

  void addGameEvent<TEvent extends GameEvent>(TEvent event) {
    _getGameBloc().add(event);
  }

  AlphaBoundBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as AlphaBoundBloc;
  }
}
