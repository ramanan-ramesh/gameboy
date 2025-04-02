import 'dart:async';

import 'package:gameboy/data/alphaBound/models/game_status.dart';
import 'package:gameboy/data/app/models/game_engine.dart';

abstract class AlphaBoundGameEngine extends GameEngine {
  AlphaBoundGameStatus get currentState;

  String get wordOfTheDay;

  int get numberOfWordsGuessedToday;

  double get wordOfTheDayProximityRatio;
}

abstract class AlphaBoundGameEngineDriver extends AlphaBoundGameEngine {
  Future<AlphaBoundGameStatus> trySubmitGuess(String guess);
}
