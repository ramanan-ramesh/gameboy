import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/events.dart';
import 'package:gameboy/blocs/lexBox/bloc.dart';
import 'package:gameboy/blocs/lexBox/states.dart' as lexBoxStates;
import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/app/models/stats.dart';
import 'package:gameboy/data/lexBox/models/game_engine.dart';
import 'package:gameboy/data/lexBox/models/stats.dart';

extension BuildContextExt on BuildContext {
  LexBoxGameEngine getGameEngineData() {
    return RepositoryProvider.of<GameEngine>(this) as LexBoxGameEngine;
  }

  LexBoxStatistics getStatsRepository() {
    return RepositoryProvider.of<Statistics>(this) as LexBoxStatistics;
  }

  void addGameEvent<TEvent extends GameEvent>(TEvent event) {
    _getGameBloc().add(event);
  }

  LexBoxBloc _getGameBloc() {
    return BlocProvider.of<GameBloc>(this) as LexBoxBloc;
  }

  lexBoxStates.LexBoxState? getCurrentLexBoxState() {
    var state = _getGameBloc().state;
    if (state is lexBoxStates.LexBoxState) {
      return state;
    }
    return null;
  }
}
