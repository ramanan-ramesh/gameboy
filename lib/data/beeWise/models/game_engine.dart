import 'package:gameboy/data/app/models/game_engine.dart';

import 'guessed_word_state.dart';
import 'score.dart';

abstract class BeeWiseGameEngine extends GameEngine {
  Score get currentScore;
  String get lettersOfTheDay;
  Iterable<String> get guessedWords;
}

abstract class BeeWiseGameEngineDriver extends BeeWiseGameEngine {
  GuessedWordState trySubmitWord(String word);
}
