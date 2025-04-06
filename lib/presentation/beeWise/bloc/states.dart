import 'package:gameboy/data/beeWise/models/guessed_word_state.dart';
import 'package:gameboy/presentation/app/blocs/game/states.dart';

abstract class BeeWiseState extends GameState {}

class GuessedWordResult extends BeeWiseState {
  GuessedWordState guessedWordState;

  GuessedWordResult(this.guessedWordState);
}

class GuessWordAccepted extends GuessedWordResult {
  int score;

  GuessWordAccepted(super.guessedWordState, this.score);
}
