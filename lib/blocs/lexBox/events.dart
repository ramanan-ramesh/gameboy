import 'package:gameboy/blocs/game/events.dart';

abstract class LexBoxEvent extends GameEvent {}

class SubmitWord extends LexBoxEvent {
  String word;

  SubmitWord(this.word);
}

class EraseLastWord extends LexBoxEvent {}
