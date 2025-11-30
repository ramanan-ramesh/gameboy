import 'package:gameboy/bloc/game/events.dart';

class SubmitGuessWord extends GameEvent {
  String guessWord;

  SubmitGuessWord(this.guessWord);
}
