import 'package:gameboy/presentation/app/blocs/game_event.dart';

abstract class AlphaBoundEvent extends GameEvent {}

class SubmitGuessWord extends AlphaBoundEvent {
  String guessWord;
  SubmitGuessWord(this.guessWord);
}
