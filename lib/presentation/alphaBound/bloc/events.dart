import 'package:gameboy/presentation/app/blocs/game/events.dart';

class SubmitGuessWord extends GameEvent {
  String guessWord;

  SubmitGuessWord(this.guessWord);
}
