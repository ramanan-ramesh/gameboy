import 'package:gameboy/presentation/app/blocs/game_event.dart';

abstract class WordleEvent extends GameEvent {}

class SubmitLetter extends WordleEvent {
  final String letter;
  SubmitLetter({required this.letter});
}

class RemoveLetter extends WordleEvent {}

class SubmitWord extends WordleEvent {}
