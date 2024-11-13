import 'package:gameboy/data/app/models/game_engine.dart';

import 'score.dart';

abstract class GameEngineData extends GameEngine {
  Score get currentScore;
  String get lettersOfTheDay;
  Iterable<String> get guessedWords;
}
