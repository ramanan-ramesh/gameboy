import 'package:gameboy/data/app/models/game_engine.dart';
import 'package:gameboy/data/wordle/models/guess_word.dart';

import 'guess_letter.dart';

abstract class GameEngineData extends GameEngine {
  String get wordOfTheDay;

  GuessWord? get guessWordUnderEdit;

  GuessWord getAttemptedGuessWord(int guessIndex);

  Iterable<GuessLetter> get allGuessedLetters;
}
