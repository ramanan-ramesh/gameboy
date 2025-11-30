import 'package:gameboy/bloc/game/events.dart';

abstract class WordsyEvent extends GameEvent {}

class SubmitLetter extends WordsyEvent {
  final String letter;

  SubmitLetter({required this.letter});
}

class RemoveLetter extends WordsyEvent {}

class SubmitWord extends WordsyEvent {}
