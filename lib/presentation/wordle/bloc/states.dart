import 'package:gameboy/presentation/app/blocs/game_state.dart';

abstract class WordleState extends GameState {}

class GuessEdited extends WordleState {}

class SubmissionNotInDictionary extends WordleState {}

class GuessWordSubmitted extends WordleState {
  int guessIndex;

  GuessWordSubmitted({required this.guessIndex});
}

class GameWon extends WordleState {
  int guessedIndex;
  bool isStartup;
  GameWon({required this.guessedIndex, this.isStartup = false});
}

class GameLost extends WordleState {
  bool isStartup;
  GameLost({this.isStartup = false});
}
