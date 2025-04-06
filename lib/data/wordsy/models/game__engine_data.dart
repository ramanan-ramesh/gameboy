import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/wordsy/models/guess_word.dart';

import 'guess_letter.dart';

abstract class WordsyGameEngine extends GameEngine {
  String get wordOfTheDay;

  GuessWord? get guessWordUnderEdit;

  GuessWord getAttemptedGuessWord(int guessIndex);

  Iterable<GuessLetter> get allGuessedLetters;
}
