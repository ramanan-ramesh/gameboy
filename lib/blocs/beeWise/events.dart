import 'package:gameboy/blocs/game/events.dart';

abstract class BeeWiseEvent extends GameEvent {}

class SubmitWord extends BeeWiseEvent {
  String word;

  SubmitWord(this.word);
}
