import 'package:gameboy/data/app/models/game_engine.dart';

import 'guessed_word_state.dart';

abstract class LexBoxGameEngine extends GameEngine {
  String get lettersOfTheDay;
  Iterable<String> get guessedWords;
  int get currentWordCount => guessedWords.length;
  bool get isWon;
}

abstract class LexBoxGameEngineDriver extends LexBoxGameEngine {
  Future<LexBoxGuessedWordState> trySubmitWord(String word);
  String? eraseLastWord();
}
