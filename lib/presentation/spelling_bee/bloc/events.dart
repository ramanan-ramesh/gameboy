import 'package:gameboy/presentation/app/blocs/game_event.dart';

abstract class SpellingBeeEvent extends GameEvent {}

class SubmitWord extends SpellingBeeEvent {
  String word;
  SubmitWord(this.word);
}
