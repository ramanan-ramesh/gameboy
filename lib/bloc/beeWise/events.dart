import 'package:gameboy/bloc/game/events.dart';

abstract class BeeWiseEvent extends GameEvent {}

class SubmitWord extends BeeWiseEvent {
  String word;

  SubmitWord(this.word);
}
