import 'package:gameboy/data/alphaBound/models/game_state.dart';
import 'package:gameboy/data/app/models/game_engine.dart';

abstract class GameEngineData extends GameEngine {
  GameState get currentState;
  String get wordOfTheDay;
  int get numberOfWordsGuessed;
  double get distanceOfWordOfTheDayFromBounds;
}
