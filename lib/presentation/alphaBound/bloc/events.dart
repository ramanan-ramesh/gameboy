abstract class AlphaBoundEvent {}

class SubmitGuessWord extends AlphaBoundEvent {
  String guessWord;
  SubmitGuessWord(this.guessWord);
}

class RequestStats extends AlphaBoundEvent {}
