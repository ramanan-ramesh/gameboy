import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/data/wordle/models/game__engine_data.dart';

import 'bloc.dart';
import 'events.dart';

extension WordleExt on BuildContext {
  GameEngineData getGameEngineData() {
    return RepositoryProvider.of<GameEngineData>(this);
  }

  void addGameEvent(WordleEvent event) {
    BlocProvider.of<WordleGameBloc>(this).add(event);
  }
}
