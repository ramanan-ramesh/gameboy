import 'package:gameboy/presentation/app/blocs/game/states.dart';

abstract class WordsyState extends GameState {}

class GuessEdited extends WordsyState {}

class SubmissionNotInDictionary extends WordsyState {}

class GuessWordSubmitted extends WordsyState {
  int guessIndex;

  GuessWordSubmitted({required this.guessIndex});
}

class GameWon extends WordsyState {
  int guessedIndex;
  bool isStartup;

  GameWon({required this.guessedIndex, this.isStartup = false});
}

class GameLost extends WordsyState {
  bool isStartup;

  GameLost({this.isStartup = false});
}
