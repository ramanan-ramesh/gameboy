import 'package:gameboy/presentation/app/blocs/game_event.dart';

class SubmitGuessWord extends GameEvent {
  String guessWord;

  SubmitGuessWord(this.guessWord);
}
