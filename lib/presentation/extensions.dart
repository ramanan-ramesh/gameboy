import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/game__engine_data.dart';
import 'package:gameboy/data/wordle/models/stats.dart';
import 'package:gameboy/presentation/wordle/bloc/states.dart';

import 'wordle/bloc/bloc.dart';
import 'wordle/bloc/events.dart';

extension BuildContextExt on BuildContext {
  GameEngineData getGameEngineData() {
    return RepositoryProvider.of<GameEngineData>(this);
  }

  WordleState getCurrentWordleState() {
    return BlocProvider.of<WordleGameBloc>(this).state;
  }

  Stats getStatsRepository() {
    return RepositoryProvider.of<Stats>(this);
  }

  void addGameEvent(WordleEvent event) {
    BlocProvider.of<WordleGameBloc>(this).add(event);
  }
}
