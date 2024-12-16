import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/spelling_bee/models/game_engine.dart';
import 'package:gameboy/data/spelling_bee/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/app/blocs/game_event.dart';
import 'package:gameboy/presentation/spelling_bee/bloc/bloc.dart';

extension BuildContextExt on BuildContext {
  GameEngineData getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as GameEngineData;
  }

  Stats getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as Stats;
  }

  void addGameEvent<TEvent extends GameEvent>(TEvent event) {
    _getGameBloc().add(event);
  }

  SpellingBeeBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as SpellingBeeBloc;
  }
}
