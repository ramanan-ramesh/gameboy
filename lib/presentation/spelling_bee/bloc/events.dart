import 'package:gameboy/presentation/app/blocs/game/events.dart';

abstract class SpellingBeeEvent extends GameEvent {}

class SubmitWord extends SpellingBeeEvent {
  String word;

  SubmitWord(this.word);
}
