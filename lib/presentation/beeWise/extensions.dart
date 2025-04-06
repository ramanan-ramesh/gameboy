import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/beeWise/models/game_engine.dart';
import 'package:gameboy/data/beeWise/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/beeWise/bloc/bloc.dart';

extension BuildContextExt on BuildContext {
  BeeWiseGameEngine getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as BeeWiseGameEngine;
  }

  BeeWiseStatistics getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as BeeWiseStatistics;
  }

  void addGameEvent<TEvent extends GameEvent>(TEvent event) {
    _getGameBloc().add(event);
  }

  BeeWiseBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as BeeWiseBloc;
  }
}
