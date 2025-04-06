import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/wordsy/models/game__engine_data.dart';
import 'package:gameboy/data/wordsy/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game/bloc.dart';
import 'package:gameboy/presentation/app/blocs/game/events.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

import 'bloc/bloc.dart';

extension BuildContextExt on BuildContext {
  WordsyGameEngine getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as WordsyGameEngine;
  }

  GameState getCurrentWordsyState() {
    return _getGameBloc().state;
  }

  WordsyStatistics getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as WordsyStatistics;
  }

  void addGameEvent(GameEvent event) {
    _getGameBloc().add(event);
  }

  WordsyGameBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as WordsyGameBloc;
  }
}
