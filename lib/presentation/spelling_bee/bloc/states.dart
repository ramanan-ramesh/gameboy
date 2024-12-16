import 'package:gameboy/data/spelling_bee/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/blocs/game_state.dart';

abstract class SpellingBeeState extends GameState {}

class GuessedWordResult extends SpellingBeeState {
  GuessedWordState guessedWordState;
  GuessedWordResult(this.guessedWordState);
}

class GuessWordAccepted extends GuessedWordResult {
  int score;
  GuessWordAccepted(super.guessedWordState, this.score);
}
