import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/wordle/models/game__engine_data.dart';
import 'package:gameboy/data/wordle/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

import 'bloc/bloc.dart';

extension BuildContextExt on BuildContext {
  WordleGameEngine getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as WordleGameEngine;
  }

  GameState getCurrentWordleState() {
    return _getGameBloc().state;
  }

  WordleStatistics getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as WordleStatistics;
  }

  void addGameEvent(GameEvent event) {
    _getGameBloc().add(event);
  }

  WordleGameBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as WordleGameBloc;
  }
}
