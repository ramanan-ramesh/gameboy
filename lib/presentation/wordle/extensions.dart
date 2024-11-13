import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/wordle/models/game__engine_data.dart';
import 'package:gameboy/data/wordle/models/stats.dart';
import 'package:gameboy/presentation/app/blocs/game_bloc.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';

import 'bloc/bloc.dart';
import 'bloc/events.dart';

extension BuildContextExt on BuildContext {
  GameEngineData getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as GameEngineData;
  }

  WordleState getCurrentWordleState() {
    return _getGameBloc().state;
  }

  Stats getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as Stats;
  }

  void addGameEvent(WordleEvent event) {
    _getGameBloc().add(event);
  }

  WordleGameBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as WordleGameBloc;
  }
}
