import 'package:gameboy/blocs/game/states.dart';
import 'package:gameboy/data/lexBox/models/guessed_word_state.dart';

abstract class LexBoxState extends GameState {}

class LexBoxWinOnStartup extends LexBoxState {}

class GuessedWordResult extends LexBoxState {
  LexBoxGuessedWordState guessedWordState;

  GuessedWordResult(this.guessedWordState);
}

class GuessWordAccepted extends GuessedWordResult {
  int wordCount;

  GuessWordAccepted(super.guessedWordState, this.wordCount);
}

class WordErased extends LexBoxState {
  String erasedWord;

  WordErased(this.erasedWord);
}
